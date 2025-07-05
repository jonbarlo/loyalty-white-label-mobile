import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/reward_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/global_theme_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<RewardProvider>();
    await provider.fetchRewards();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'Rewards');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[RewardsScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.teal,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Rewards',
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
                  child: Consumer<RewardProvider>(
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
                                'Error loading rewards',
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
                      if (provider.rewards.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.redeem_outlined,
                                size: GlobalThemeService.getIconSize(context) ?? 64,
                                color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textTertiary,
                              ),
                              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                              Text(
                                'No rewards available',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                                  fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
                                ),
                              ),
                              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                              Text(
                                'Check back later for new rewards!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                                  fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
                        itemCount: provider.rewards.length,
                        itemBuilder: (context, index) {
                          final reward = provider.rewards[index];
                          return _buildRewardItem(reward);
                        },
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildRewardItem(reward) {
    return Card(
      color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      margin: EdgeInsets.only(bottom: GlobalThemeService.getDefaultMargin(context) ?? 16),
      child: InkWell(
        onTap: () {}, // Implement reward details if needed
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
        child: Padding(
          padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
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
                          reward.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                          ),
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 4),
                        Text(
                          'Program ID: ${reward.rewardProgramId}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                            fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: GlobalThemeService.getDefaultPadding(context) ?? 12,
                      vertical: GlobalThemeService.getDefaultPadding(context) ?? 6,
                    ),
                    decoration: BoxDecoration(
                      color: reward.isActive 
                          ? (GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor)
                          : (GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor),
                      borderRadius: BorderRadius.circular(
                        GlobalThemeService.getBorderRadius(context) ?? 16,
                      ),
                    ),
                    child: Text(
                      reward.isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 12),
              if (reward.description.isNotEmpty) ...[
                Text(
                  reward.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type: ${reward.type}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                            fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                          ),
                        ),
                        Text(
                          'Value: ${reward.value}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                            fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    reward.isActive ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: reward.isActive 
                          ? (GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor)
                          : (GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor),
                      fontWeight: FontWeight.bold,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 