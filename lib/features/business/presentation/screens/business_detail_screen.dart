import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/business_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/business.dart';

class BusinessDetailScreen extends StatefulWidget {
  final int businessId;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().loadBusiness(widget.businessId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer2<BusinessProvider, AuthProvider>(
            builder: (context, businessProvider, authProvider, child) {
              if (authProvider.isAdmin && businessProvider.selectedBusiness != null) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.go('/businesses/${widget.businessId}/edit');
                        break;
                      case 'delete':
                        _showDeleteDialog(context, businessProvider);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, child) {
          if (businessProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (businessProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading business',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    businessProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => businessProvider.loadBusiness(widget.businessId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final business = businessProvider.selectedBusiness;
          if (business == null) {
            return const Center(
              child: Text('Business not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Header
                _BusinessHeader(business: business),
                const SizedBox(height: 24),

                // Business Information
                _BusinessInfo(business: business),
                const SizedBox(height: 24),

                // Contact Information
                _ContactInfo(business: business),
                const SizedBox(height: 24),

                // Status and Actions
                _StatusAndActions(business: business),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BusinessProvider businessProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business'),
        content: Text(
          'Are you sure you want to delete "${businessProvider.selectedBusiness?.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await businessProvider.deleteBusiness(widget.businessId);
              if (success && mounted) {
                context.go('/businesses');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BusinessHeader extends StatelessWidget {
  final Business business;

  const _BusinessHeader({required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: business.isActive 
                  ? AppTheme.primaryColor 
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              child: Icon(
                Icons.business,
                size: 40,
                color: business.isActive 
                    ? Colors.white 
                    : Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (business.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      business.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: business.isActive 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: business.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      business.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: business.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessInfo extends StatelessWidget {
  final Business business;

  const _BusinessInfo({required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Created',
              value: _formatDate(business.createdAt),
            ),
            _InfoRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDate(business.updatedAt),
            ),
            if (business.website != null) ...[
              _InfoRow(
                icon: Icons.language,
                label: 'Website',
                value: business.website!,
                isLink: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ContactInfo extends StatelessWidget {
  final Business business;

  const _ContactInfo({required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (business.address != null) ...[
              _InfoRow(
                icon: Icons.location_on,
                label: 'Address',
                value: business.address!,
              ),
            ],
            if (business.phone != null) ...[
              _InfoRow(
                icon: Icons.phone,
                label: 'Phone',
                value: business.phone!,
                isPhone: true,
              ),
            ],
            if (business.email != null) ...[
              _InfoRow(
                icon: Icons.email,
                label: 'Email',
                value: business.email!,
                isEmail: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusAndActions extends StatelessWidget {
  final Business business;

  const _StatusAndActions({required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/punch-cards?businessId=${business.id}'),
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('View Punch Cards'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/rewards?businessId=${business.id}'),
                    icon: const Icon(Icons.redeem),
                    label: const Text('View Rewards'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/theme-editor?businessId=${business.id}'),
                    icon: const Icon(Icons.palette),
                    label: const Text('Theme Editor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/businesses/test'),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Test API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLink;
  final bool isPhone;
  final bool isEmail;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
    this.isPhone = false,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                if (isLink)
                  InkWell(
                    onTap: () {
                      // Handle link tap
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else if (isPhone)
                  InkWell(
                    onTap: () {
                      // Handle phone tap
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else if (isEmail)
                  InkWell(
                    onTap: () {
                      // Handle email tap
                    },
                    child: Text(
                      value,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 