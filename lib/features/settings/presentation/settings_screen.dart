import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/models/models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Profile Header
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: theme.primaryColor),
            ),
            title: Text(user?.name ?? 'Guest User', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user?.email ?? 'Sign in to sync data'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profileSettings),
          ),
          const Divider(),
          _buildSectionHeader('Inventory'),
          _buildSettingsTile(Icons.grid_view_outlined, 'Default Catalog View', () {
            _showViewModeModal(context);
          }),
          _buildSettingsTile(Icons.category_outlined, 'Category Management', () {
            Navigator.pushNamed(context, AppRoutes.categoryManagement);
          }),
          _buildSectionHeader('System'),
          _buildSettingsTile(Icons.color_lens_outlined, 'Appearance', () {
            _showAppearanceModal(context);
          }),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () async {
                await provider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showAppearanceModal(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.settings_system_daydream),
                title: const Text('System Default'),
                trailing: provider.themeMode == ThemeMode.system ? const Icon(Icons.check) : null,
                onTap: () {
                  provider.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light Mode'),
                trailing: provider.themeMode == ThemeMode.light ? const Icon(Icons.check) : null,
                onTap: () {
                  provider.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: provider.themeMode == ThemeMode.dark ? const Icon(Icons.check) : null,
                onTap: () {
                  provider.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showViewModeModal(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Default Catalog View',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.view_list),
                title: const Text('List View'),
                trailing: provider.viewMode == ViewMode.list ? const Icon(Icons.check) : null,
                onTap: () {
                  provider.setViewMode(ViewMode.list);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: const Text('Grid View'),
                trailing: provider.viewMode == ViewMode.grid ? const Icon(Icons.check) : null,
                onTap: () {
                  provider.setViewMode(ViewMode.grid);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
