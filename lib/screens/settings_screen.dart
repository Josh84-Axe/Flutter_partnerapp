import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text('settings_preferences'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'account'.tr(),
            items: [
              _buildSettingItem(
                context,
                icon: Icons.router_outlined,
                title: 'hotspot_management'.tr(),
                subtitle: 'manage_hotspot_desc'.tr(),
                onTap: () {
                  _showHotspotManagementDialog(context);
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.wifi,
                title: 'internet_plan'.tr(),
                subtitle: 'manage_plans_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/internet-plan');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.card_membership_outlined,
                title: 'subscription_management'.tr(),
                subtitle: _getSubscriptionTier(appState),
                onTap: () {
                  Navigator.of(context).pushNamed('/subscription-management');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.settings_input_antenna,
                title: 'router_settings'.tr(),
                subtitle: 'configure_router_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/router-settings');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.notifications_outlined,
                title: 'notifications_preferences'.tr(),
                subtitle: 'configure_notifications_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/notification-settings');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.language_outlined,
                title: 'language'.tr(),
                subtitle: appState.selectedLanguage.nativeName,
                onTap: () {
                  Navigator.of(context).pushNamed('/language');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'theme'.tr(),
                subtitle: themeProvider.isDarkMode ? 'dark_mode'.tr() : 'light_mode'.tr(),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  activeTrackColor: AppTheme.primaryGreen,
                ),
                onTap: () => themeProvider.toggleTheme(),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'security'.tr(),
            items: [
              _buildSettingItem(
                context,
                icon: Icons.person_outline,
                title: 'partner_profile'.tr(),
                subtitle: 'manage_business_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/partner-profile');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.security_outlined,
                title: 'security_settings'.tr(),
                subtitle: 'security_settings_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/security/password-2fa');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.admin_panel_settings_outlined,
                title: 'user_roles_permissions'.tr(),
                subtitle: 'manage_access_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/role-permissions');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.file_download_outlined,
                title: 'data_export_reporting'.tr(),
                subtitle: 'generate_new_report'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/reporting');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'data_privacy'.tr(),
                subtitle: 'privacy_policy_desc'.tr(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening https://tiknet.africa.com/privacy')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'data_tools'.tr(),
            items: [
              _buildSettingItem(
                context,
                icon: Icons.download_outlined,
                title: 'data_export_reporting'.tr(),
                subtitle: 'export_data_desc'.tr(),
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'help_information'.tr(),
            items: [
              _buildSettingItem(
                context,
                icon: Icons.help_outline,
                title: 'support_help'.tr(),
                subtitle: 'get_help_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/support');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.replay_outlined,
                title: 'replay_onboarding'.tr(),
                subtitle: 'view_tour_desc'.tr(),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasSeenOnboarding', false);
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
                  }
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.info_outlined,
                title: 'about'.tr(),
                subtitle: 'about_version_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/about');
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.inbox_outlined,
                title: 'empty_state_demo'.tr(),
                subtitle: 'empty_state_desc'.tr(),
                onTap: () {
                  Navigator.of(context).pushNamed('/empty-state');
                },
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
              child: Text(
                'logout'.tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
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
        title: Text(
          'hotspot_management'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('hotspot_user_profile'.tr()),
              subtitle: Text('manage_hotspot_desc'.tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/hotspot-user');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text('configurations'.tr()),
              subtitle: Text('configure_speeds_desc'.tr()),
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
            child: Text('close'.tr()),
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
