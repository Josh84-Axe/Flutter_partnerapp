import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late Map<String, bool> _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final appState = context.read<AppState>();
    _settings = appState.getNotificationSettings();
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final appState = context.read<AppState>();
    await appState.updateNotificationSettings(_settings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('notification_settings_saved'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('notification_settings'.tr()),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('notification_settings'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationToggle(
            icon: Icons.payment,
            title: 'transaction_notifications'.tr(),
            description: 'transaction_notifications_desc'.tr(),
            value: _settings['transactions'] ?? true,
            onChanged: (value) => setState(() => _settings['transactions'] = value),
          ),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            icon: Icons.account_balance_wallet,
            title: 'payout_notifications'.tr(),
            description: 'payout_notifications_desc'.tr(),
            value: _settings['payouts'] ?? true,
            onChanged: (value) => setState(() => _settings['payouts'] = value),
          ),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            icon: Icons.warning,
            title: 'low_balance_alerts'.tr(),
            description: 'low_balance_alerts_desc'.tr(),
            value: _settings['balance'] ?? true,
            onChanged: (value) => setState(() => _settings['balance'] = value),
          ),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            icon: Icons.person_add,
            title: 'new_user_notifications'.tr(),
            description: 'new_user_notifications_desc'.tr(),
            value: _settings['users'] ?? true,
            onChanged: (value) => setState(() => _settings['users'] = value),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: FilledButton(
            onPressed: _saveSettings,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('save_changes'.tr()),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
