import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/punch_card_provider.dart';
import '../../../../core/providers/point_transaction_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/punch_card.dart';
import '../../../../core/models/point_transaction.dart';
import '../../../../core/models/notification.dart';
import '../../../../core/services/global_theme_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final punchCardProvider = context.read<PunchCardProvider>();
    final pointProvider = context.read<PointTransactionProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    await Future.wait([
      punchCardProvider.fetchMyPunchCards(),
      pointProvider.fetchMyPointTransactions(),
      notificationProvider.fetchMyNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get dynamic background color from theme
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'Dashboard');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[DashboardScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.green, // Fallback to green if no theme
          appBar: AppBar(
            title: Text(
              'Dashboard',
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsSection(),
                      const SizedBox(height: 32),
                      _buildQuickActions(),
                      const SizedBox(height: 32),
                      _buildRecentActivities(),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
            fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Consumer<PointTransactionProvider>(
                builder: (context, pointProvider, child) {
                  return _buildStatCard(
                    icon: Icons.stars,
                    title: 'Total Points',
                    value: '${pointProvider.getTotalPoints()}',
                    color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Consumer<PunchCardProvider>(
                builder: (context, punchCardProvider, child) {
                  final activeCards = punchCardProvider.myPunchCards
                      .where((card) => !card.redeemed)
                      .length;
                  return _buildStatCard(
                    icon: Icons.card_giftcard,
                    title: 'Active Cards',
                    value: '$activeCards',
                    color: GlobalThemeService.getSecondaryColor(context) ?? AppTheme.secondaryColor,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
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
              icon,
              size: GlobalThemeService.getIconSize(context) ?? 32,
              color: color,
            ),
            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
            fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.card_giftcard,
                title: 'Punch Cards',
                subtitle: 'View your cards',
                onTap: () => context.go('/punch-cards'),
                color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.stars,
                title: 'Points',
                subtitle: 'Check balance',
                onTap: () => context.go('/points'),
                color: GlobalThemeService.getSecondaryColor(context) ?? AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.redeem,
                title: 'Rewards',
                subtitle: 'Available rewards',
                onTap: () => context.go('/rewards'),
                color: GlobalThemeService.getErrorColor(context) ?? AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Account settings',
                onTap: () => context.go('/profile'),
                color: GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
        child: Padding(
          padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 20),
          child: Column(
            children: [
              Icon(
                icon,
                size: GlobalThemeService.getIconSize(context) ?? 32,
                color: color,
              ),
              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                  fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                  fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
            fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<PointTransactionProvider>(
          builder: (context, pointProvider, child) {
            final recentTransactions = pointProvider.getRecentTransactions(limit: 5);
            
            if (recentTransactions.isEmpty) {
              return Card(
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
                        'No recent activities',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your recent point transactions will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textTertiary,
                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: recentTransactions.map((transaction) {
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
            );
          },
        ),
      ],
    );
  }
} 