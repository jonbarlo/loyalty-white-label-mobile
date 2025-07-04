import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          debugPrint('ProfileScreen user: ' + user.toString());
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),

                // User Information
                _buildUserInfo(context, user),
                const SizedBox(height: 24),

                // Settings Section
                _buildSettingsSection(context),
                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // User Email
            Text(
              user.email,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // User Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
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

  Widget _buildInfoItem(String label, String value, [BuildContext? context]) {
    final isDark = context != null && Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : AppTheme.textSecondary;
    final valueColor = isDark ? Colors.white : AppTheme.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w500,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          _buildSettingItem(
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            subtitle: 'Manage your privacy settings',
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // Navigate to help screen
            },
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              // Show about dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppTheme.errorColor;
      case 'business_owner':
        return AppTheme.warningColor;
      case 'customer':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
} 