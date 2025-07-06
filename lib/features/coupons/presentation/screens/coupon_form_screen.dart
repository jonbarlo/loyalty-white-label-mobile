import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/coupon_provider.dart';
import '../../../../core/models/coupon.dart';
import '../../../../core/services/global_theme_service.dart';
import '../../../../core/theme/app_theme.dart';

class CouponFormScreen extends StatefulWidget {
  final Coupon? coupon;

  const CouponFormScreen({super.key, this.coupon});

  @override
  State<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _maxUsesController = TextEditingController();
  final _perCustomerLimitController = TextEditingController();
  final _maximumDiscountController = TextEditingController();

  String _discountType = 'percentage';
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      _populateForm(widget.coupon!);
    } else {
      _generateCouponCode();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _discountAmountController.dispose();
    _minimumOrderController.dispose();
    _maxUsesController.dispose();
    _perCustomerLimitController.dispose();
    _maximumDiscountController.dispose();
    super.dispose();
  }

  void _populateForm(Coupon coupon) {
    _titleController.text = coupon.title;
    _descriptionController.text = coupon.description;
    _codeController.text = coupon.code;
    _discountAmountController.text = coupon.discountValue.toString();
    _discountType = coupon.discountType;
    _minimumOrderController.text = coupon.minimumPurchase.toString();
    _maxUsesController.text = coupon.totalQuantity.toString();
    _validFrom = coupon.startDate;
    _validUntil = coupon.endDate;
  }

  void _generateCouponCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 8; i++) {
      code += chars[random % chars.length];
    }
    _codeController.text = code;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.coupon != null;
    
    return Scaffold(
      backgroundColor: GlobalThemeService.getBackgroundColor(context, pageName: 'CouponForm'),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Coupon' : 'Create Coupon',
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
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _generateCouponCode,
              tooltip: 'Generate New Code',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Coupon Title',
              hint: 'e.g., Welcome Discount',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe what this coupon offers',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _codeController,
              label: 'Coupon Code',
              hint: 'e.g., WELCOME20',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a coupon code';
                }
                if (value.length < 3) {
                  return 'Code must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDiscountSection(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _minimumOrderController,
              label: 'Minimum Order Amount (\$)',
              hint: '0.00',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter minimum order amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _maxUsesController,
              label: 'Maximum Uses',
              hint: '100',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter maximum uses';
                }
                final uses = int.tryParse(value);
                if (uses == null || uses <= 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _perCustomerLimitController,
              label: 'Per Customer Limit (optional)',
              hint: '1',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final limit = int.tryParse(value);
                  if (limit == null || limit <= 0) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_discountType == 'percentage')
              _buildTextField(
                controller: _maximumDiscountController,
                label: 'Maximum Discount (\$) (optional)',
                hint: '10.00',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                  }
                  return null;
                },
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Coupon' : 'Create Coupon',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            GlobalThemeService.getBorderRadius(context) ?? 8,
          ),
        ),
        filled: true,
        fillColor: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
      ),
      validator: validator,
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discount Type',
          style: TextStyle(
            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Percentage'),
                value: 'percentage',
                groupValue: _discountType,
                onChanged: (value) {
                  setState(() {
                    _discountType = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Fixed Amount'),
                value: 'fixed',
                groupValue: _discountType,
                onChanged: (value) {
                  setState(() {
                    _discountType = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _discountAmountController,
          label: _discountType == 'percentage' ? 'Discount Percentage (%)' : 'Discount Amount (\$)',
          hint: _discountType == 'percentage' ? '20' : '5.00',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter discount amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (_discountType == 'percentage' && amount > 100) {
              return 'Percentage cannot exceed 100%';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valid Period',
          style: TextStyle(
            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date',
                value: _validFrom,
                onChanged: (date) {
                  setState(() {
                    _validFrom = date;
                    if (_validUntil.isBefore(_validFrom)) {
                      _validUntil = _validFrom.add(const Duration(days: 1));
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'End Date',
                value: _validUntil,
                onChanged: (date) {
                  setState(() {
                    _validUntil = date;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
          ),
          borderRadius: BorderRadius.circular(
            GlobalThemeService.getBorderRadius(context) ?? 8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.month}/${value.day}/${value.year}',
              style: TextStyle(
                color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCoupon() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final couponData = {
        'name': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'couponCode': _codeController.text.trim().toUpperCase(),
        'discountType': _discountType,
        'discountValue': double.parse(_discountAmountController.text),
        'minimumPurchase': double.parse(_minimumOrderController.text),
        'startDate': _validFrom.toIso8601String(),
        'endDate': _validUntil.toIso8601String(),
        'totalQuantity': int.parse(_maxUsesController.text),
        if (_perCustomerLimitController.text.isNotEmpty)
          'perCustomerLimit': int.parse(_perCustomerLimitController.text),
        if (_discountType == 'percentage' && _maximumDiscountController.text.isNotEmpty)
          'maximumDiscount': double.parse(_maximumDiscountController.text),
      };

      final couponProvider = context.read<CouponProvider>();
      bool success;

      if (widget.coupon != null) {
        success = await couponProvider.updateCoupon(widget.coupon!.id, couponData);
      } else {
        success = await couponProvider.createCoupon(couponData);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.coupon != null ? 'Coupon updated successfully' : 'Coupon created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(couponProvider.error ?? 'Failed to save coupon'),
            backgroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 