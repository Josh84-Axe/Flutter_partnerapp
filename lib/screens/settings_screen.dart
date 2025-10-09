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
                icon: Icons.person_outline,
                title: 'Profile Management',
                subtitle: 'Edit your profile information',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.card_membership_outlined,
                title: 'Subscription Management',
                subtitle: 'Manage your subscription plan',
                onTap: () {},
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
                  activeColor: AppTheme.deepGreen,
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
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Data Privacy',
                subtitle: 'Privacy policy and settings',
                onTap: () {},
              ),
              _buildSettingItem(
                context,
                icon: Icons.vpn_key_outlined,
                title: 'API Key Management',
                subtitle: 'Manage API keys',
                onTap: () {},
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
                icon: Icons.info_outline,
                title: 'System Status',
                subtitle: 'Check system health',
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
            child: ElevatedButton(
              onPressed: () async {
                await appState.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              style: ElevatedButton.styleFrom(
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
                  color: AppTheme.deepGreen,
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
          color: AppTheme.deepGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.deepGreen, size: 24),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
