import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/coupon_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/models/coupon.dart';
import '../../../../core/services/global_theme_service.dart';
import '../../../../core/theme/app_theme.dart';

class CustomerCouponsScreen extends StatefulWidget {
  const CustomerCouponsScreen({super.key});

  @override
  State<CustomerCouponsScreen> createState() => _CustomerCouponsScreenState();
}

class _CustomerCouponsScreenState extends State<CustomerCouponsScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().loadMyCoupons();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: GlobalThemeService.getBackgroundColor(context, pageName: 'CustomerCoupons'),
        appBar: AppBar(
          title: Text(
            'My Coupons',
            style: TextStyle(
              color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
              fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: GlobalThemeService.getAppBarColor(context) ?? Colors.transparent,
          foregroundColor: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
          elevation: GlobalThemeService.getElevation(context) ?? 0,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Available'),
              Tab(text: 'History'),
            ],
            labelColor: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
            unselectedLabelColor: GlobalThemeService.getTextSecondaryColor(context) ?? Colors.grey,
            indicatorColor: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
          ),
        ),
        body: TabBarView(
          children: [
            _buildAvailableCouponsTab(),
            _buildCouponHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCouponsTab() {
    return Consumer<CouponProvider>(
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
                  onPressed: () => couponProvider.loadMyCoupons(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final availableCoupons = couponProvider.availableCoupons;

        if (availableCoupons.isEmpty) {
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
                  'No available coupons',
                  style: TextStyle(
                    color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                    fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new offers!',
                  style: TextStyle(
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => couponProvider.loadMyCoupons(),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: availableCoupons.length,
                  onPageChanged: (index) {
                    debugPrint('[CustomerCouponsScreen] Page changed to index: $index');
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    debugPrint('[CustomerCouponsScreen] Building page $index of ${availableCoupons.length}');
                    return _buildCouponCard(availableCoupons[index], couponProvider);
                  },
                  physics: const PageScrollPhysics(),
                  allowImplicitScrolling: true,
                  padEnds: false,
                ),
              ),
              if (availableCoupons.length > 1) _buildPageIndicator(availableCoupons.length),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponHistoryTab() {
    return Consumer<CouponProvider>(
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
                  'Error loading history',
                  style: TextStyle(
                    color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                    fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => couponProvider.loadCouponHistory(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final historyCoupons = couponProvider.couponHistory;

        if (historyCoupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No coupon history',
                  style: TextStyle(
                    color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                    fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your redeemed and expired coupons will appear here',
                  style: TextStyle(
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => couponProvider.loadCouponHistory(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyCoupons.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(historyCoupons[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildCouponCard(Coupon coupon, CouponProvider couponProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          debugPrint('[CustomerCouponsScreen] Coupon card tapped: ${coupon.title}');
        },
        child: Card(
        elevation: GlobalThemeService.getElevation(context) ?? 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            GlobalThemeService.getBorderRadius(context) ?? 16,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              GlobalThemeService.getBorderRadius(context) ?? 16,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                GlobalThemeService.getSecondaryColor(context) ?? AppTheme.secondaryColor,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  coupon.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  coupon.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    coupon.discountDisplay,
                    style: TextStyle(
                      color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Code: ${coupon.code}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Min. Order: \$${coupon.minimumPurchase.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Valid until ${_formatDate(coupon.endDate)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showRedeemDialog(coupon, couponProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Redeem Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Coupon coupon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: coupon.isExpired 
            ? (GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor)
            : (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor),
          child: Icon(
            coupon.isExpired ? Icons.schedule : Icons.check,
            color: Colors.white,
          ),
        ),
        title: Text(
          coupon.title,
          style: TextStyle(
            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coupon.description,
              style: TextStyle(
                color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Code: ${coupon.code} • ${coupon.discountDisplay}',
              style: TextStyle(
                color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: coupon.isExpired 
              ? (GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor).withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            coupon.isExpired ? 'Expired' : 'Redeemed',
            style: TextStyle(
              color: coupon.isExpired 
                ? (GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor)
                : Colors.green,
              fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          return GestureDetector(
            onTap: () {
              debugPrint('[CustomerCouponsScreen] Tapped page indicator $index');
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: index == _currentIndex ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: index == _currentIndex
                  ? (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor)
                  : (GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary).withOpacity(0.5),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else {
      return 'today';
    }
  }

  void _showRedeemDialog(Coupon coupon, CouponProvider couponProvider) {
    final purchaseAmountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem Coupon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your purchase amount to calculate the discount:'),
            const SizedBox(height: 16),
            TextField(
              controller: purchaseAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Purchase Amount (\$)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(purchaseAmountController.text);
              if (amount == null || amount < coupon.minimumPurchase) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchase amount must be at least \$${coupon.minimumPurchase.toStringAsFixed(2)}'),
                    backgroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              Navigator.of(context).pop();
              await _redeemCoupon(coupon, amount, couponProvider);
            },
            child: Text('Redeem'),
          ),
        ],
      ),
    );
  }

  Future<void> _redeemCoupon(Coupon coupon, double purchaseAmount, CouponProvider couponProvider) async {
    final result = await couponProvider.redeemCoupon(coupon.id, purchaseAmount);
    
    if (result != null && mounted) {
      final discount = result['discount'] as double;
      final finalAmount = result['finalAmount'] as double;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Coupon Redeemed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text('Original Amount: \$${purchaseAmount.toStringAsFixed(2)}'),
              Text('Discount: \$${discount.toStringAsFixed(2)}'),
              Text(
                'Final Amount: \$${finalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Great!'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(couponProvider.error ?? 'Failed to redeem coupon'),
          backgroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
        ),
      );
    }
  }
} 