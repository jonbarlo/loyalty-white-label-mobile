import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/punch_card_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/punch_card.dart';

class PunchCardDetailScreen extends StatefulWidget {
  final int punchCardId;

  const PunchCardDetailScreen({
    super.key,
    required this.punchCardId,
  });

  @override
  State<PunchCardDetailScreen> createState() => _PunchCardDetailScreenState();
}

class _PunchCardDetailScreenState extends State<PunchCardDetailScreen> {
  PunchCard? _punchCard;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPunchCard();
  }

  Future<void> _loadPunchCard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<PunchCardProvider>();
      _punchCard = provider.getPunchCardById(widget.punchCardId);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Punch Card #${widget.punchCardId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPunchCard,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading punch card',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPunchCard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_punchCard == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Punch card not found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The punch card you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/punch-cards'),
              child: const Text('Back to Punch Cards'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPunchCardHeader(),
          const SizedBox(height: 24),
          _buildPunchCardDetails(),
          const SizedBox(height: 24),
          _buildProgressSection(),
          const SizedBox(height: 24),
          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildPunchCardHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: _punchCard!.redeemed ? AppTheme.successColor : AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Punch Card #${_punchCard!.id}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _punchCard!.redeemed ? AppTheme.successColor : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _punchCard!.redeemed ? 'REDEEMED' : 'ACTIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunchCardDetails() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Card Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildDetailItem('Card ID', '${_punchCard!.id}'),
          _buildDetailItem('User ID', '${_punchCard!.userId}'),
          _buildDetailItem('Business ID', '${_punchCard!.businessId}'),
          _buildDetailItem('Program ID', '${_punchCard!.rewardProgramId}'),
          _buildDetailItem('Punches', '${_punchCard!.punches}'),
          _buildDetailItem('Redeemed', _punchCard!.redeemed ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = _punchCard!.punches / 10; // Assuming 10 punches to complete
    final remainingPunches = 10 - _punchCard!.punches;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              // backgroundColor: AppTheme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                _punchCard!.redeemed ? AppTheme.successColor : AppTheme.primaryColor,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            
            // Progress Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_punchCard!.punches}/10 punches',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}% complete',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            if (!_punchCard!.redeemed && remainingPunches > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$remainingPunches more punches needed to redeem',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    if (_punchCard!.redeemed) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Card Redeemed!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This punch card has been successfully redeemed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Earn Punch Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _earnPunch(),
                icon: const Icon(Icons.add),
                label: const Text('Earn Punch'),
              ),
            ),
            const SizedBox(height: 12),
            
            // Redeem Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _punchCard!.punches >= 10 ? () => _redeemCard() : null,
                icon: const Icon(Icons.redeem),
                label: const Text('Redeem Card'),
              ),
            ),
            
            if (_punchCard!.punches < 10) ...[
              const SizedBox(height: 8),
              Text(
                'Need ${10 - _punchCard!.punches} more punches to redeem',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _earnPunch() async {
    final provider = context.read<PunchCardProvider>();
    final success = await provider.earnPunch(_punchCard!.id);
    
    if (success && mounted) {
      await _loadPunchCard(); // Refresh the card data
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

  Future<void> _redeemCard() async {
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
      final provider = context.read<PunchCardProvider>();
      final success = await provider.redeemPunchCard(_punchCard!.id);
      
      if (success && mounted) {
        await _loadPunchCard(); // Refresh the card data
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