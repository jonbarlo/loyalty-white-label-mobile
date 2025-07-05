import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/business_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/business.dart';
import '../../../../core/services/global_theme_service.dart';

class BusinessFormScreen extends StatefulWidget {
  final Business? business; // null for create, non-null for edit
  final int? businessId; // ID for edit mode when business object is not provided

  const BusinessFormScreen({
    super.key,
    this.business,
    this.businessId,
  });

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoUrlController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.business != null) {
      // Edit mode - populate fields from provided business object
      _populateFields(widget.business!);
    } else if (widget.businessId != null) {
      // Edit mode - load business data by ID
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BusinessProvider>().loadBusiness(widget.businessId!);
      });
    }
  }

  void _populateFields(Business business) {
    _nameController.text = business.name;
    _descriptionController.text = business.description ?? '';
    _addressController.text = business.address ?? '';
    _phoneController.text = business.phone ?? '';
    _emailController.text = business.email ?? '';
    _websiteController.text = business.website ?? '';
    _logoUrlController.text = business.logoUrl ?? '';
    _isActive = business.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final businessProvider = context.read<BusinessProvider>();
    final businessData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      'address': _addressController.text.trim().isEmpty 
          ? null 
          : _addressController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
      'website': _websiteController.text.trim().isEmpty 
          ? null 
          : _websiteController.text.trim(),
      'logoUrl': _logoUrlController.text.trim().isEmpty 
          ? null 
          : _logoUrlController.text.trim(),
      'isActive': _isActive,
    };

    bool success;
    if (widget.business != null || widget.businessId != null) {
      // Edit mode
      final businessId = widget.business?.id ?? widget.businessId!;
      success = await businessProvider.updateBusiness(businessId, businessData);
    } else {
      // Create mode
      success = await businessProvider.createBusiness(businessData);
    }

    if (success && mounted) {
      if (widget.business != null || widget.businessId != null) {
        // Go back to business detail
        final businessId = widget.business?.id ?? widget.businessId!;
        context.go('/businesses/$businessId');
      } else {
        // Go back to business list
        context.go('/businesses');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(businessProvider.error ?? 'Operation failed'),
          // backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.business != null || widget.businessId != null;
    
    // Check if user is admin
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAdmin) {
          return Scaffold(
            backgroundColor: GlobalThemeService.getBackgroundColor(context, pageName: 'BusinessForm') ?? Colors.purple,
            appBar: AppBar(
              title: Text(
                'Access Denied',
                style: TextStyle(
                  color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                  fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: GlobalThemeService.getAppBarColor(context) ?? Colors.transparent,
              foregroundColor: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
              elevation: GlobalThemeService.getElevation(context) ?? 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                ),
                onPressed: () {
                  // Use GoRouter for proper navigation
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // Fallback to business list if we can't pop
                    context.go('/businesses');
                  }
                },
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: GlobalThemeService.getIconSize(context) ?? 64,
                    color: GlobalThemeService.getErrorColor(context) ?? Colors.red,
                  ),
                  SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                  Text(
                    'Access Denied',
                    style: TextStyle(
                      color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                      fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                  Text(
                    'Only administrators can manage businesses.',
                    style: TextStyle(
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
                  ElevatedButton(
                    onPressed: () {
                      // Use GoRouter for proper navigation
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        // Fallback to business list if we can't pop
                        context.go('/businesses');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
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
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Consumer2<ThemeProvider, BusinessProvider>(
          builder: (context, themeProvider, businessProvider, child) {
            // Get dynamic background color from theme
            final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'BusinessForm');
            final isLoading = GlobalThemeService.isLoading(context);
            debugPrint('[BusinessFormScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
            
            // Populate fields when business data is loaded (for edit mode with businessId)
            if (widget.businessId != null && 
                businessProvider.selectedBusiness != null && 
                businessProvider.selectedBusiness!.id == widget.businessId &&
                _nameController.text.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _populateFields(businessProvider.selectedBusiness!);
              });
            }
            
            return Scaffold(
              backgroundColor: dynamicBg ?? Colors.purple, // Fallback to purple if no theme
              appBar: AppBar(
                title: Text(
                  isEditMode ? 'Edit Business' : 'Create Business',
                  style: TextStyle(
                    color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                    fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: GlobalThemeService.getAppBarColor(context) ?? Colors.transparent,
                foregroundColor: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                elevation: GlobalThemeService.getElevation(context) ?? 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                  ),
                  onPressed: () {
                    // Use GoRouter for proper navigation
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      // Fallback to business list if we can't pop
                      context.go('/businesses');
                    }
                  },
                ),
              ),
              body: isLoading || (widget.businessId != null && businessProvider.isLoading)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            GlobalThemeService.getPrimaryColor(context) ?? Colors.white,
                          ),
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                        Text(
                          isLoading ? 'Loading theme...' : 'Loading business...',
                          style: TextStyle(
                            color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : widget.businessId != null && businessProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: GlobalThemeService.getIconSize(context) ?? 64,
                            color: GlobalThemeService.getErrorColor(context) ?? Theme.of(context).colorScheme.error,
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                          Text(
                            'Error loading business',
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                          Text(
                            businessProvider.error!,
                            style: TextStyle(
                              color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                          ElevatedButton(
                            onPressed: () => businessProvider.loadBusiness(widget.businessId!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
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
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Business Name
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Business Name *',
                              hintText: 'Enter business name',
                              prefixIcon: Icon(
                                Icons.business,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              hintStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.5),
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              filled: true,
                              fillColor: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Business name is required';
                              }
                              if (value.trim().length < 2) {
                                return 'Business name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter business description',
                              prefixIcon: Icon(
                                Icons.description,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              hintStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.5),
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              filled: true,
                              fillColor: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

                          // Address
                          TextFormField(
                            controller: _addressController,
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Address',
                              hintText: 'Enter business address',
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              hintStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.5),
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              filled: true,
                              fillColor: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

                          // Phone
                          TextFormField(
                            controller: _phoneController,
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              hintText: 'Enter phone number',
                              prefixIcon: Icon(
                                Icons.phone,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              hintStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.5),
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              filled: true,
                              fillColor: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                // Basic phone validation
                                final phoneRegex = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
                                if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                                  return 'Please enter a valid phone number';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter email address',
                              prefixIcon: Icon(
                                Icons.email,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              hintStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.5),
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              filled: true,
                              fillColor: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

                          // Website
                          TextFormField(
                            controller: _websiteController,
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Website',
                              hintText: 'Enter website URL',
                              prefixIcon: Icon(
                                Icons.language,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              hintStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.5),
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              filled: true,
                              fillColor: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final urlRegex = RegExp(
                                  r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
                                );
                                if (!urlRegex.hasMatch(value)) {
                                  return 'Please enter a valid URL';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

                          // Logo URL
                          TextFormField(
                            controller: _logoUrlController,
                            style: TextStyle(
                              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                              fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Logo URL',
                              hintText: 'Enter logo image URL',
                              prefixIcon: Icon(
                                Icons.image,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                              ),
                              labelStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              hintStyle: TextStyle(
                                color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.5),
                                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getTextSecondaryColor(context)?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  GlobalThemeService.getBorderRadius(context) ?? 8,
                                ),
                              ),
                              filled: true,
                              fillColor: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final urlRegex = RegExp(
                                  r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
                                );
                                if (!urlRegex.hasMatch(value)) {
                                  return 'Please enter a valid URL';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

                          // Active Status
                          Card(
                            color: GlobalThemeService.getSurfaceColor(context)?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                GlobalThemeService.getBorderRadius(context) ?? 8,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                                      fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                                  SwitchListTile(
                                    title: Text(
                                      'Active',
                                      style: TextStyle(
                                        color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                                        fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Business is currently active',
                                      style: TextStyle(
                                        color: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
                                        fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 14,
                                      ),
                                    ),
                                    value: _isActive,
                                    activeColor: GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                    onChanged: (value) {
                                      setState(() {
                                        _isActive = value;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),

                          // Submit Button
                          Consumer<BusinessProvider>(
                            builder: (context, businessProvider, child) {
                              return ElevatedButton(
                                onPressed: businessProvider.isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? GlobalThemeService.getPrimaryColor(context) ?? Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: GlobalThemeService.getDefaultPadding(context) ?? 24,
                                    vertical: GlobalThemeService.getDefaultPadding(context) ?? 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      GlobalThemeService.getBorderRadius(context) ?? 8,
                                    ),
                                  ),
                                  elevation: GlobalThemeService.getElevation(context) ?? 4,
                                ),
                                child: businessProvider.isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        isEditMode ? 'Update Business' : 'Create Business',
                                        style: TextStyle(
                                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            );
          },
        );
      },
    );
  }
} 