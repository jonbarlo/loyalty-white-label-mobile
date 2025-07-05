import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/global_theme_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final dynamicBg = GlobalThemeService.getBackgroundColor(context, pageName: 'Profile');
        final isLoading = GlobalThemeService.isLoading(context);
        debugPrint('[ProfileScreen] Dynamic background color: $dynamicBg, isLoading: $isLoading');
        return Scaffold(
          backgroundColor: dynamicBg ?? Colors.pink,
          appBar: AppBar(
            title: Text(
              'Profile',
              style: TextStyle(
                color: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: GlobalThemeService.getAppBarColor(context) ?? Colors.transparent,
            foregroundColor: GlobalThemeService.getTextPrimaryColor(context) ?? Colors.white,
            elevation: GlobalThemeService.getElevation(context) ?? 0,
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
              : Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.user;
                    debugPrint('ProfileScreen user: \\${user.toString()}');
                    if (user == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
                      child: Column(
                        children: [
                          _buildProfileHeader(context, user),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
                          _buildUserInfo(context, user),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
                          _buildSettingsSection(context),
                          SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 24),
                          _buildLogoutButton(context, authProvider),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
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
            CircleAvatar(
              radius: 50,
              backgroundColor: GlobalThemeService.getPrimaryColor(context) ?? AppTheme.primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 16),
            Text(
              user.name,
              style: TextStyle(
                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
                fontWeight: FontWeight.bold,
                color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
                color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: GlobalThemeService.getDefaultMargin(context) ?? 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: GlobalThemeService.getDefaultPadding(context) ?? 12,
                vertical: GlobalThemeService.getDefaultPadding(context) ?? 6,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role),
                borderRadius: BorderRadius.circular(
                  GlobalThemeService.getBorderRadius(context) ?? 16,
                ),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: GlobalThemeService.getFontSizeCaption(context) ?? 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, user) {
    return Card(
      color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
            child: Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: GlobalThemeService.getDividerColor(context) ?? AppTheme.dividerColor,
          ),
          _buildInfoItem('User ID', '${user.id}', context),
          _buildInfoItem('Business ID', user.businessId?.toString() ?? 'N/A', context),
          _buildInfoItem('Email', user.email, context),
          _buildInfoItem('Name', user.name, context),
          _buildInfoItem('Role', user.role, context),
          _buildInfoItem('Status', user.isActive ? 'Active' : 'Inactive', context),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark 
        ? Colors.white70 
        : (GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary);
    final valueColor = isDark 
        ? Colors.white 
        : (GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GlobalThemeService.getDefaultPadding(context) ?? 16,
        vertical: GlobalThemeService.getDefaultPadding(context) ?? 12,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w500,
                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w600,
                fontSize: GlobalThemeService.getFontSizeBody(context) ?? 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      color: GlobalThemeService.getSurfaceColor(context) ?? Colors.white,
      elevation: GlobalThemeService.getElevation(context) ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          GlobalThemeService.getBorderRadius(context) ?? 12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(GlobalThemeService.getDefaultPadding(context) ?? 16),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
                fontSize: GlobalThemeService.getFontSizeHeading(context) ?? 24,
              ),
            ),
          ),
          Divider(
            height: 1,
            color: GlobalThemeService.getDividerColor(context) ?? AppTheme.dividerColor,
          ),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // Implement change password
            },
            context: context,
          ),
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            onTap: () {
              // Implement delete account
            },
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
        size: GlobalThemeService.getIconSize(context) ?? 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: GlobalThemeService.getTextPrimaryColor(context) ?? AppTheme.textPrimary,
          fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: GlobalThemeService.getTextSecondaryColor(context) ?? AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.logout,
          size: GlobalThemeService.getIconSize(context) ?? 24,
        ),
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: GlobalThemeService.getFontSizeBody(context) ?? 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlobalThemeService.getErrorColor(context) ?? AppTheme.errorColor,
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
        onPressed: () => _showLogoutDialog(context, authProvider),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.deepPurple;
      case 'staff':
        return Colors.blue;
      case 'user':
      default:
        return Colors.green;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
