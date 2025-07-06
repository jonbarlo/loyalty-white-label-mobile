import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/coupon_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/coupon.dart';
import '../../../../core/services/global_theme_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'coupon_form_screen.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().loadBusinessCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemeService.getBackgroundColor(context, pageName: 'AdminCoupons'),
      appBar: AppBar(
        title: Text(
          'Manage Coupons',
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
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCouponForm(),
            tooltip: 'Add New Coupon',
          ),
        ],
      ),
      body: Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          if (couponProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (couponProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading coupons',
                    style: TextStyle(
                      color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                      fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    couponProvider.error!,
                    style: TextStyle(
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => couponProvider.loadBusinessCoupons(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (couponProvider.businessCoupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No coupons yet',
                    style: TextStyle(
                      color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                      fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first coupon to start offering discounts',
                    style: TextStyle(
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCouponForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Coupon'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => couponProvider.loadBusinessCoupons(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: couponProvider.businessCoupons.length,
              itemBuilder: (context, index) {
                final coupon = couponProvider.businessCoupons[index];
                return _buildCouponCard(coupon, couponProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCouponForm(),
        backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon, CouponProvider couponProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.title,
                        style: TextStyle(
                          color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                          fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.description,
                        style: TextStyle(
                          color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(coupon),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    coupon.discountDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Code: ${coupon.code}',
                  style: TextStyle(
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${coupon.usedQuantity}/${coupon.totalQuantity} used',
                  style: TextStyle(
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                    fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expires ${_formatDate(coupon.endDate)}',
                  style: TextStyle(
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                    fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToCouponForm(coupon: coupon),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleCouponStatus(coupon, couponProvider),
                    icon: Icon(coupon.isActive ? Icons.pause : Icons.play_arrow),
                    label: Text(coupon.isActive ? 'Pause' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: coupon.isActive 
                        ? (GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor)
                        : (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteCoupon(coupon, couponProvider),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Coupon coupon) {
    Color color;
    String text;
    IconData icon;

    if (coupon.isExpired) {
      color = GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor;
      text = 'Expired';
      icon = Icons.schedule;
    } else if (!coupon.isActive) {
      color = GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary;
      text = 'Inactive';
      icon = Icons.pause;
    } else if (coupon.usedQuantity >= coupon.totalQuantity) {
      color = GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor;
      text = 'Used Up';
      icon = Icons.block;
    } else {
      color = Colors.green;
      text = 'Active';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hours';
    } else {
      return 'today';
    }
  }

  void _navigateToCouponForm({Coupon? coupon}) {
    context.push('/coupon-form', extra: coupon);
  }

  Future<void> _toggleCouponStatus(Coupon coupon, CouponProvider couponProvider) async {
    final success = await couponProvider.toggleCouponStatus(coupon.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon ${coupon.isActive ? 'paused' : 'activated'} successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(couponProvider.error ?? 'Failed to update coupon status'),
          backgroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _deleteCoupon(Coupon coupon, CouponProvider couponProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete "${coupon.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await couponProvider.deleteCoupon(coupon.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(couponProvider.error ?? 'Failed to delete coupon'),
            backgroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
          ),
        );
      }
    }
  }
} 