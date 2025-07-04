import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/business_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/business.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final _searchController = TextEditingController();
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().loadBusinesses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Businesses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.go('/businesses/test'),
            tooltip: 'Test API',
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAdmin) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => context.go('/businesses/create'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search businesses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _showOnlyActive,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyActive = value ?? true;
                        });
                      },
                    ),
                    const Text('Show only active businesses'),
                  ],
                ),
              ],
            ),
          ),
          
          // Business List
          Expanded(
            child: Consumer<BusinessProvider>(
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
                          'Error loading businesses',
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
                          onPressed: () => businessProvider.loadBusinesses(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                List<Business> filteredBusinesses = businessProvider.businesses;

                // Apply search filter
                if (_searchController.text.isNotEmpty) {
                  filteredBusinesses = businessProvider.searchBusinesses(_searchController.text);
                }

                // Apply active filter
                if (_showOnlyActive) {
                  filteredBusinesses = filteredBusinesses.where((b) => b.isActive).toList();
                }

                if (filteredBusinesses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No businesses found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBusinesses.length,
                  itemBuilder: (context, index) {
                    final business = filteredBusinesses[index];
                    return _BusinessCard(business: business);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final Business business;

  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: business.isActive 
              ? AppTheme.primaryColor 
              : Theme.of(context).colorScheme.onSurfaceVariant,
          child: Icon(
            Icons.business,
            color: business.isActive 
                ? Colors.white 
                : Theme.of(context).colorScheme.surface,
          ),
        ),
        title: Text(
          business.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: business.isActive 
                ? null 
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (business.description != null) ...[
              Text(
                business.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            if (business.address != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      business.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!business.isActive) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.go('/businesses/${business.id}'),
      ),
    );
  }
} 