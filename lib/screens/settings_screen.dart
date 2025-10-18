import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'Account',
            items: [
              _buildSettingItem(
                context,
                icon: Icons.router_outlined,
                title: 'Hotspot Management',
                subtitle: 'Manage hotspot users and configurations',
                onTap: () {
                  _showHotspotManagementDialog(context);
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.wifi,
                title: 'Internet Plan',
                subtitle: 'Manage internet plans and pricing',
                onTap: () {
                  Navigator.of(context).pushNamed('/internet-plan');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.card_membership_outlined,
                title: 'Subscription Management',
                subtitle: _getSubscriptionTier(appState),
                onTap: () {
                  Navigator.of(context).pushNamed('/subscription-management');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.settings_input_antenna,
                title: 'Router Settings',
                subtitle: 'Configure router connections',
                onTap: () {
                  Navigator.of(context).pushNamed('/router-settings');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications Preferences',
                subtitle: 'Configure notification settings',
                onTap: () {
                  Navigator.of(context).pushNamed('/notifications');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: appState.selectedLanguage.nativeName,
                onTap: () {
                  Navigator.of(context).pushNamed('/language');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  activeColor: AppTheme.primaryGreen,
                ),
                onTap: () => themeProvider.toggleTheme(),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Security',
            items: [
              _buildSettingItem(
                context,
                icon: Icons.security_outlined,
                title: 'Security Settings',
                subtitle: '2FA, password management',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.admin_panel_settings_outlined,
                title: 'User Roles & Permissions',
                subtitle: 'Manage user access levels',
                onTap: () {
                  Navigator.of(context).pushNamed('/user-roles');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Data Privacy',
                subtitle: 'Privacy policy and settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening https://tiknet.africa.com/privacy')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Data & Tools',
            items: [
              _buildSettingItem(
                context,
                icon: Icons.download_outlined,
                title: 'Data Export & Reporting',
                subtitle: 'Export your data',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Transactions',
                subtitle: 'View revenue breakdown',
                onTap: () {
                  Navigator.of(context).pushNamed('/revenue-breakdown');
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Help & Information',
            items: [
              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                title: 'Support & Help',
                subtitle: 'Get help and contact support',
                onTap: () {
                  Navigator.of(context).pushNamed('/support');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.replay_outlined,
                title: 'Replay Onboarding Tour',
                subtitle: 'View the app tour again',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.info_outlined,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: () async {
                await appState.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...items,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showHotspotManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hotspot Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Hotspot User'),
              subtitle: const Text('Manage router profiles and settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/hotspot-user');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurations'),
              subtitle: const Text('Rate limits, timeouts, and limits'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/configurations');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getSubscriptionTier(AppState appState) {
    final routerCount = appState.currentUser?.numberOfRouters ?? 0;
    if (routerCount == 1) return 'Basic (15% fee)';
    if (routerCount >= 2 && routerCount <= 4) return 'Standard (12% fee)';
    if (routerCount >= 5) return 'Premium (10% fee)';
    return 'No subscription';
  }
}
