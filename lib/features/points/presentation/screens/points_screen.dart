import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/point_transaction_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/global_theme_service.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<PointTransactionProvider>();
    await provider.fetchMyPointTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'Points');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[PointsScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.red,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Points',
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
                onPressed: _loadData,
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
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: Consumer<PointTransactionProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: GlobalThemeService.getIconSize(context) ?? 64,
                                color: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
                              ),
                              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                              Text(
                                'Error loading points',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                                  fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
                                ),
                              ),
                              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                              Text(
                                provider.error!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                                  fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                              ElevatedButton(
                                onPressed: _loadData,
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
                        );
                      }
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPointsBalanceCard(provider),
                            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
                            _buildTransactionHistory(provider),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPointsBalanceCard(PointTransactionProvider provider) {
    final totalPoints = provider.getTotalPoints();
    return Card(
      color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  size: GlobalThemeService.getIconSize(context) ?? 48,
                  color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                ),
                SizedBox(width: GlobalThemeService.getDefaultMargin(context) ?? 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Points',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                        fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                      ),
                    ),
                    Text(
                      '$totalPoints',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                        fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Earned',
                    '${provider.getTransactionsByType('earn').fold(0, (sum, t) => sum + t.points)}',
                    GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Redeemed',
                    '${provider.getTransactionsByType('redeem').fold(0, (sum, t) => sum + t.points)}',
                    GlobalThemeService.getErrorColor(context) ?? AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 20,
          ),
        ),
        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory(PointTransactionProvider provider) {
    final transactions = provider.myPointTransactions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
            fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
          ),
        ),
        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
        if (transactions.isEmpty)
          Card(
            color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
            elevation: GlobalThemeService.getElevation(context) ?? 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                GlobalThemeService.getBorderRadius(context) ?? 12,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 20),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: GlobalThemeService.getIconSize(context) ?? 48,
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textTertiary,
                  ),
                  SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                    ),
                  ),
                  SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                  Text(
                    'Your point transactions will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textTertiary,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: transactions.map((transaction) {
              return Card(
                color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
                elevation: GlobalThemeService.getElevation(context) ?? 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    GlobalThemeService.getBorderRadius(context) ?? 8,
                  ),
                ),
                margin: EdgeInsets.only(bottom: GlobalThemeService.getDefaultMargin(context) ?? 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'earn'
                        ? (GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor)
                        : (GlobalThemeService.getErrorColor(context) ?? AppTheme.warningColor),
                    child: Icon(
                      transaction.type == 'earn' ? Icons.add : Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                    ),
                  ),
                  subtitle: Text(
                    '${transaction.type.toUpperCase()} • ${transaction.points} points',
                    style: TextStyle(
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                      fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                    ),
                  ),
                  trailing: Text(
                    '${transaction.points}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: transaction.type == 'earn'
                          ? (GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor)
                          : (GlobalThemeService.getErrorColor(context) ?? AppTheme.warningColor),
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
} 