import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/business_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/business.dart';
import '../../../../core/services/global_theme_service.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final TextEditingController _searchController = TextEditingController();
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Get dynamic background color from theme
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'Business');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[BusinessListScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.purple, // Fallback to purple if no theme
          appBar: AppBar(
            title: Text(
              'Businesses',
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
                  Icons.palette,
                  color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                ),
                onPressed: () => context.go('/theme-editor'),
                tooltip: 'Theme Editor',
              ),
              IconButton(
                icon: Icon(
                  Icons.bug_report,
                  color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                ),
                onPressed: () => context.go('/businesses/test'),
                tooltip: 'Test API',
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isAdmin) {
                    return IconButton(
                      icon: Icon(
                        Icons.add,
                        color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                      ),
                      onPressed: () => context.go('/businesses/create'),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
            : Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                    fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search businesses...',
                    hintStyle: TextStyle(
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                      fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        GlobalThemeService.getBorderRadius(context) ?? 12,
                      ),
                      borderSide: BorderSide(
                        color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        GlobalThemeService.getBorderRadius(context) ?? 12,
                      ),
                      borderSide: BorderSide(
                        color: GlobalThemeService.getDividerColor(context) ?? AppTheme.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        GlobalThemeService.getBorderRadius(context) ?? 12,
                      ),
                      borderSide: BorderSide(
                        color: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                Row(
                  children: [
                    Checkbox(
                      value: _showOnlyActive,
                      activeColor: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyActive = value ?? true;
                        });
                      },
                    ),
                    Text(
                      'Show only active businesses',
                      style: TextStyle(
                        color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                        fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                      ),
                    ),
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
                          size: GlobalThemeService.getIconSize(context) ?? 64,
                          color: GlobalThemeService.getErrorColor(context) ?? Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                        Text(
                          'Error loading businesses',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                            fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 20,
                          ),
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                        Text(
                          businessProvider.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                        ElevatedButton(
                          onPressed: () => businessProvider.loadBusinesses(),
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
                          size: GlobalThemeService.getIconSize(context) ?? 64,
                          color: GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
                        Text(
                          'No businesses found',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                            fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 20,
                          ),
                        ),
                        SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                          ),
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
  },
);
  }
}

class _BusinessCard extends StatelessWidget {
  final Business business;

  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      margin: EdgeInsets.only(bottom: GlobalThemeService.getDefaultMargin(context) ?? 12),
      child: ListTile(
        leading: business.logoUrl != null && business.logoUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  business.logoUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return CircleAvatar(
                      backgroundColor: business.isActive 
                          ? (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor)
                          : (GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant),
                      child: Icon(
                        Icons.business,
                        color: business.isActive 
                            ? Colors.white 
                            : (GlobalThemeService.getSurfaceColor(context) ?? Theme.of(context).colorScheme.surface),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircleAvatar(
                      backgroundColor: business.isActive 
                          ? (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor)
                          : (GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant),
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          business.isActive 
                              ? Colors.white 
                              : (GlobalThemeService.getSurfaceColor(context) ?? Theme.of(context).colorScheme.surface),
                        ),
                      ),
                    );
                  },
                ),
              )
            : CircleAvatar(
                backgroundColor: business.isActive 
                    ? (GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor)
                    : (GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant),
                child: Icon(
                  Icons.business,
                  color: business.isActive 
                      ? Colors.white 
                      : (GlobalThemeService.getSurfaceColor(context) ?? Theme.of(context).colorScheme.surface),
                ),
              ),
        title: Text(
          business.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: business.isActive 
                ? (GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary)
                : (GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant),
            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
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
                style: TextStyle(
                  color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
                  fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
                ),
              ),
              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 4),
            ],
            if (business.address != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: GlobalThemeService.getIconSize(context) ?? 16,
                    color: GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: GlobalThemeService.getDefaultMargin(context) ?? 4),
                  Expanded(
                    child: Text(
                      business.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!business.isActive) ...[
              SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: GlobalThemeService.getDefaultPadding(context) ?? 8,
                  vertical: GlobalThemeService.getDefaultPadding(context) ?? 2,
                ),
                decoration: BoxDecoration(
                  color: GlobalThemeService.getErrorColor(context) ?? Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(
                    GlobalThemeService.getBorderRadius(context) ?? 12,
                  ),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: GlobalThemeService.getTextSecondaryColor(context) ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: () => context.go('/businesses/${business.id}'),
      ),
    );
  }
} 