import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/global_theme_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/business_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import 'package:dio/dio.dart';

class ThemeEditorScreen extends StatefulWidget {
  final String? businessId;
  
  const ThemeEditorScreen({
    super.key,
    this.businessId,
  });

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for theme attributes
  final _primaryColorController = TextEditingController();
  final _secondaryColorController = TextEditingController();
  final _backgroundColorController = TextEditingController();
  final _textPrimaryColorController = TextEditingController();
  final _textSecondaryColorController = TextEditingController();
  final _fontSizeBodyController = TextEditingController();
  final _fontSizeHeadingController = TextEditingController();
  final _borderRadiusController = TextEditingController();
  final _elevationController = TextEditingController();
  final _defaultPaddingController = TextEditingController();
  final _defaultMarginController = TextEditingController();

  // Store original values for change detection
  late Map<String, String> _originalValues;

  // Color picker state
  Color _currentColor = Colors.blue;
  TextEditingController? _activeColorController;
  
  // Loading state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  @override
  void dispose() {
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _backgroundColorController.dispose();
    _textPrimaryColorController.dispose();
    _textSecondaryColorController.dispose();
    _fontSizeBodyController.dispose();
    _fontSizeHeadingController.dispose();
    _borderRadiusController.dispose();
    _elevationController.dispose();
    _defaultPaddingController.dispose();
    _defaultMarginController.dispose();
    super.dispose();
  }

  void _loadCurrentTheme() {
    final themeProvider = context.read<ThemeProvider>();
    final currentTheme = themeProvider.theme;
    
    if (currentTheme != null) {
      _primaryColorController.text = _colorToHex(currentTheme.primaryColor);
      _secondaryColorController.text = _colorToHex(currentTheme.secondaryColor);
      _backgroundColorController.text = _colorToHex(currentTheme.backgroundColor);
      _textPrimaryColorController.text = _colorToHex(currentTheme.textPrimaryColor);
      _textSecondaryColorController.text = _colorToHex(currentTheme.textSecondaryColor);
      _fontSizeBodyController.text = currentTheme.fontSizeBody.toString();
      _fontSizeHeadingController.text = currentTheme.fontSizeHeading.toString();
      _borderRadiusController.text = currentTheme.borderRadius.toString();
      _elevationController.text = currentTheme.elevation.toString();
      _defaultPaddingController.text = currentTheme.defaultPadding.toString();
      _defaultMarginController.text = currentTheme.defaultMargin.toString();
      // Store original values for change detection
      _originalValues = {
        'primaryColor': _primaryColorController.text,
        'secondaryColor': _secondaryColorController.text,
        'backgroundColor': _backgroundColorController.text,
        'textPrimaryColor': _textPrimaryColorController.text,
        'textSecondaryColor': _textSecondaryColorController.text,
        'fontSizeBody': _fontSizeBodyController.text,
        'fontSizeHeading': _fontSizeHeadingController.text,
        'borderRadius': _borderRadiusController.text,
        'elevation': _elevationController.text,
        'defaultPadding': _defaultPaddingController.text,
        'defaultMargin': _defaultMarginController.text,
      };
    }
  }

  String _colorToHex(Color? color) {
    if (color == null) return '#000000';
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Color? _hexToColor(String hex) {
    if (hex.isEmpty) return null;
    if (!hex.startsWith('#')) hex = '#$hex';
    if (hex.length != 7) return null;
    
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return null;
    }
  }

  void _showColorPicker(TextEditingController controller, String title) {
    _activeColorController = controller;
    _currentColor = _hexToColor(controller.text) ?? Colors.blue;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Pick $title',
            style: TextStyle(
              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.black,
              fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  _currentColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsvWithHue,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                  fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_activeColorController != null) {
                  _activeColorController!.text = _colorToHex(_currentColor);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Select',
                style: TextStyle(
                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                  fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _previewTheme() {
    if (!_formKey.currentState!.validate()) return;

    final previewTheme = BusinessTheme(
      primaryColor: _hexToColor(_primaryColorController.text) ?? AppTheme.primaryColor,
      secondaryColor: _hexToColor(_secondaryColorController.text) ?? AppTheme.secondaryColor,
      backgroundColor: _hexToColor(_backgroundColorController.text) ?? AppTheme.backgroundColor,
      textPrimaryColor: _hexToColor(_textPrimaryColorController.text) ?? AppTheme.textPrimary,
      textSecondaryColor: _hexToColor(_textSecondaryColorController.text) ?? AppTheme.textSecondary,
      fontSizeBody: double.tryParse(_fontSizeBodyController.text) ?? 16.0,
      fontSizeHeading: double.tryParse(_fontSizeHeadingController.text) ?? 24.0,
      borderRadius: double.tryParse(_borderRadiusController.text) ?? 8.0,
      elevation: double.tryParse(_elevationController.text) ?? 2.0,
      defaultPadding: double.tryParse(_defaultPaddingController.text) ?? 16.0,
      defaultMargin: double.tryParse(_defaultMarginController.text) ?? 16.0,
      fontFamily: 'Roboto',
    );

    // For now, just show a preview message
    // In a real implementation, you would apply the theme here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme preview would be applied here!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Helper to format color as 6-digit hex with # (no alpha)
  String _formatColor(String hex) {
    // Accepts #AARRGGBB, #RRGGBB, or RRGGBB
    String cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 8) {
      // Remove alpha
      cleaned = cleaned.substring(2);
    }
    return '#${cleaned.toUpperCase()}';
  }

  Future<void> _saveTheme() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.businessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No business ID provided. Cannot save theme.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      // Build payload with only changed fields
      final payload = <String, dynamic>{
        'id': int.parse(widget.businessId!),
      };
      if (_primaryColorController.text != _originalValues['primaryColor']) {
        payload['primaryColor'] = _formatColor(_primaryColorController.text);
      }
      if (_secondaryColorController.text != _originalValues['secondaryColor']) {
        payload['secondaryColor'] = _formatColor(_secondaryColorController.text);
      }
      if (_backgroundColorController.text != _originalValues['backgroundColor']) {
        payload['backgroundColor'] = _formatColor(_backgroundColorController.text);
      }
      if (_textPrimaryColorController.text != _originalValues['textPrimaryColor']) {
        payload['textPrimaryColor'] = _formatColor(_textPrimaryColorController.text);
      }
      if (_textSecondaryColorController.text != _originalValues['textSecondaryColor']) {
        payload['textSecondaryColor'] = _formatColor(_textSecondaryColorController.text);
      }
      if (_fontSizeBodyController.text != _originalValues['fontSizeBody']) {
        payload['fontSizeBody'] = double.tryParse(_fontSizeBodyController.text);
      }
      if (_fontSizeHeadingController.text != _originalValues['fontSizeHeading']) {
        payload['fontSizeHeading'] = double.tryParse(_fontSizeHeadingController.text);
      }
      if (_borderRadiusController.text != _originalValues['borderRadius']) {
        payload['borderRadius'] = double.tryParse(_borderRadiusController.text);
      }
      if (_elevationController.text != _originalValues['elevation']) {
        payload['elevation'] = double.tryParse(_elevationController.text);
      }
      if (_defaultPaddingController.text != _originalValues['defaultPadding']) {
        payload['defaultPadding'] = double.tryParse(_defaultPaddingController.text);
      }
      if (_defaultMarginController.text != _originalValues['defaultMargin']) {
        payload['defaultMargin'] = double.tryParse(_defaultMarginController.text);
      }
      if (payload.length == 1) {
        // Only id, nothing changed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes to save.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      // Use Dio directly for this custom payload
      final themeProvider = context.read<ThemeProvider>();
      final dio = themeProvider.dio;
      final url = '/businesses/${widget.businessId}/theme';
      // Get token from AuthProvider
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;
      await dio.put(
        url,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Update originals
      _originalValues = {
        'primaryColor': _primaryColorController.text,
        'secondaryColor': _secondaryColorController.text,
        'backgroundColor': _backgroundColorController.text,
        'textPrimaryColor': _textPrimaryColorController.text,
        'textSecondaryColor': _textSecondaryColorController.text,
        'fontSizeBody': _fontSizeBodyController.text,
        'fontSizeHeading': _fontSizeHeadingController.text,
        'borderRadius': _borderRadiusController.text,
        'elevation': _elevationController.text,
        'defaultPadding': _defaultPaddingController.text,
        'defaultMargin': _defaultMarginController.text,
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save theme: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetToDefault() {
    _primaryColorController.text = _colorToHex(AppTheme.primaryColor);
    _secondaryColorController.text = _colorToHex(AppTheme.secondaryColor);
    _backgroundColorController.text = _colorToHex(AppTheme.backgroundColor);
    _textPrimaryColorController.text = _colorToHex(AppTheme.textPrimary);
    _textSecondaryColorController.text = _colorToHex(AppTheme.textSecondary);
    _fontSizeBodyController.text = '16.0';
    _fontSizeHeadingController.text = '24.0';
    _borderRadiusController.text = '8.0';
    _elevationController.text = '2.0';
    _defaultPaddingController.text = '16.0';
    _defaultMarginController.text = '16.0';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'ThemeEditor');
        final isLoading = GlobalThemeService.isLoading(context);
        
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.purple,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Theme Editor${widget.businessId != null ? ' (Business ${widget.businessId})' : ''}',
              style: TextStyle(
                color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: GlobalThemeService.getAppBarColor(context) ?? Colors.transparent,
            foregroundColor: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
            elevation: GlobalThemeService.getElevation(context) ?? 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                ),
                onPressed: _resetToDefault,
                tooltip: 'Reset to Default',
              ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading theme...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('Colors'),
                        _buildColorField('Primary Color', _primaryColorController, Icons.palette),
                        _buildColorField('Secondary Color', _secondaryColorController, Icons.color_lens),
                        _buildColorField('Background Color', _backgroundColorController, Icons.format_color_fill),
                        _buildColorField('Text Primary Color', _textPrimaryColorController, Icons.text_fields),
                        _buildColorField('Text Secondary Color', _textSecondaryColorController, Icons.text_format),
                        
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
                        _buildSectionTitle('Typography'),
                        _buildNumberField('Font Size Body', _fontSizeBodyController, Icons.text_fields),
                        _buildNumberField('Font Size Heading', _fontSizeHeadingController, Icons.title),
                        
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
                        _buildSectionTitle('Layout'),
                        _buildNumberField('Border Radius', _borderRadiusController, Icons.rounded_corner),
                        _buildNumberField('Elevation', _elevationController, Icons.layers),
                        _buildNumberField('Default Padding', _defaultPaddingController, Icons.space_bar),
                        _buildNumberField('Default Margin', _defaultMarginController, Icons.margin),
                        
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 32),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.visibility,
                                  size: GlobalThemeService.getIconSize(context) ?? 24,
                                ),
                                label: Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlobalThemeService.getButtonSecondaryColor(context) ?? AppTheme.secondaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: GlobalThemeService.getDefaultPadding(context) ?? 24,
                                    vertical: GlobalThemeService.getDefaultPadding(context) ?? 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      GlobalThemeService.getBorderRadius(context) ?? 8,
                                    ),
                                  ),
                                ),
                                onPressed: _previewTheme,
                              ),
                            ),
                            SizedBox(width: GlobalThemeService.getDefaultMargin(context) ?? 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: _isSaving 
                                  ? SizedBox(
                                      width: GlobalThemeService.getIconSize(context) ?? 24,
                                      height: GlobalThemeService.getIconSize(context) ?? 24,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Icon(
                                      Icons.save,
                                      size: GlobalThemeService.getIconSize(context) ?? 24,
                                    ),
                                label: Text(
                                  _isSaving ? 'Saving...' : 'Save',
                                  style: TextStyle(
                                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: GlobalThemeService.getDefaultPadding(context) ?? 24,
                                    vertical: GlobalThemeService.getDefaultPadding(context) ?? 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      GlobalThemeService.getBorderRadius(context) ?? 8,
                                    ),
                                  ),
                                ),
                                onPressed: _isSaving ? null : _saveTheme,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: GlobalThemeService.getDefaultMargin(context) ?? 8,
        top: GlobalThemeService.getDefaultMargin(context) ?? 16,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 20,
          fontWeight: FontWeight.bold,
          color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildColorField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: GlobalThemeService.getDefaultMargin(context) ?? 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(
                  icon,
                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                ),
                suffixIcon: Container(
                  margin: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 8),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _hexToColor(controller.text) ?? Colors.grey,
                    borderRadius: BorderRadius.circular(
                      GlobalThemeService.getBorderRadius(context) ?? 4,
                    ),
                    border: Border.all(
                      color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
                    ),
                  ),
                ),
                filled: true,
                fillColor: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    GlobalThemeService.getBorderRadius(context) ?? 8,
                  ),
                  borderSide: BorderSide(
                    color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    GlobalThemeService.getBorderRadius(context) ?? 8,
                  ),
                  borderSide: BorderSide(
                    color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    GlobalThemeService.getBorderRadius(context) ?? 8,
                  ),
                  borderSide: BorderSide(
                    color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a color';
                }
                if (_hexToColor(value) == null) {
                  return 'Please select a valid color';
                }
                return null;
              },
            ),
          ),
          SizedBox(width: GlobalThemeService.getDefaultMargin(context) ?? 8),
          Container(
            decoration: BoxDecoration(
              color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
              borderRadius: BorderRadius.circular(
                GlobalThemeService.getBorderRadius(context) ?? 8,
              ),
              border: Border.all(
                color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.colorize,
                color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
              ),
              onPressed: () => _showColorPicker(controller, label),
              tooltip: 'Pick Color',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: GlobalThemeService.getDefaultMargin(context) ?? 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
          ),
          filled: true,
          fillColor: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              GlobalThemeService.getBorderRadius(context) ?? 8,
            ),
            borderSide: BorderSide(
              color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              GlobalThemeService.getBorderRadius(context) ?? 8,
            ),
            borderSide: BorderSide(
              color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              GlobalThemeService.getBorderRadius(context) ?? 8,
            ),
            borderSide: BorderSide(
              color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
} 