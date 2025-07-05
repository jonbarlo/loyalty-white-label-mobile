import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/punch_card_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/punch_card.dart';
import '../../../../core/services/global_theme_service.dart';

class PunchCardsScreen extends StatefulWidget {
  const PunchCardsScreen({super.key});

  @override
  State<PunchCardsScreen> createState() => _PunchCardsScreenState();
}

class _PunchCardsScreenState extends State<PunchCardsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<PunchCardProvider>();
    await provider.fetchMyPunchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get dynamic background color from theme
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'PunchCards');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[PunchCardsScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.orange, // Fallback to orange if no theme
          appBar: AppBar(
            title: Text(
              'Punch Cards',
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
                child: Consumer<PunchCardProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
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
                              'Error loading punch cards',
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

                    if (provider.myPunchCards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard_outlined,
                              size: GlobalThemeService.getIconSize(context) ?? 64,
                              color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textTertiary,
                            ),
                            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                            Text(
                              'No punch cards yet',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
                              ),
                            ),
                            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                            Text(
                              'You don\'t have any punch cards yet.\nVisit a participating business to get started!',
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
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.myPunchCards.length,
                      itemBuilder: (context, index) {
                        final punchCard = provider.myPunchCards[index];
                        return _buildPunchCardItem(punchCard, provider);
                      },
                    );
                  },
                ),
              ),
        );
      },
    );
  }

  Widget _buildPunchCardItem(PunchCard punchCard, PunchCardProvider provider) {
    final isRedeemed = punchCard.redeemed;
    final progress = punchCard.punches / 10; // Assuming 10 punches to complete

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
        onTap: () => context.go('/punch-cards/${punchCard.id}'),
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
                          'Punch Card #${punchCard.id}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                          ),
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 4),
                        Text(
                          'Program ID: ${punchCard.rewardProgramId}',
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
                      color: isRedeemed 
                          ? (GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor)
                          : (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(
                        GlobalThemeService.getBorderRadius(context) ?? 16,
                      ),
                    ),
                    child: Text(
                      isRedeemed ? 'REDEEMED' : 'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                        ),
                      ),
                      Text(
                        '${punchCard.punches}/10',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: GlobalThemeService.getDividerColor(context) ?? AppTheme.dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isRedeemed 
                          ? (GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor)
                          : (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),

              // Action Buttons
              if (!isRedeemed) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _earnPunch(punchCard.id, provider),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                          side: BorderSide(
                            color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: GlobalThemeService.getDefaultPadding(context) ?? 16,
                            vertical: GlobalThemeService.getDefaultPadding(context) ?? 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GlobalThemeService.getBorderRadius(context) ?? 8,
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.add,
                          size: GlobalThemeService.getIconSize(context) ?? 20,
                        ),
                        label: Text(
                          'Earn Punch',
                          style: TextStyle(
                            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: GlobalThemeService.getDefaultMargin(context) ?? 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: punchCard.punches >= 10 
                            ? () => _redeemCard(punchCard.id, provider)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlobalThemeService.getButtonPrimaryColor(context) ?? AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: GlobalThemeService.getDefaultPadding(context) ?? 16,
                            vertical: GlobalThemeService.getDefaultPadding(context) ?? 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              GlobalThemeService.getBorderRadius(context) ?? 8,
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.redeem,
                          size: GlobalThemeService.getIconSize(context) ?? 20,
                        ),
                        label: Text(
                          'Redeem',
                          style: TextStyle(
                            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: GlobalThemeService.getDefaultPadding(context) ?? 12,
                  ),
                  decoration: BoxDecoration(
                    color: (GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      GlobalThemeService.getBorderRadius(context) ?? 8,
                    ),
                    border: Border.all(
                      color: GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor,
                        size: GlobalThemeService.getIconSize(context) ?? 20,
                      ),
                      SizedBox(width: GlobalThemeService.getDefaultMargin(context) ?? 8),
                      Text(
                        'Card has been redeemed!',
                        style: TextStyle(
                          color: GlobalThemeService.getSecondaryColor(context) ?? AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _earnPunch(int cardId, PunchCardProvider provider) async {
    final success = await provider.earnPunch(cardId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Punch earned successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to earn punch'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _redeemCard(int cardId, PunchCardProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Punch Card'),
        content: const Text(
          'Are you sure you want to redeem this punch card? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.redeemPunchCard(cardId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Punch card redeemed successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to redeem punch card'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
} 