import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _newUserRegistered = true;
  bool _routerOffline = true;
  bool _payoutConfirmation = false;
  bool _lowBalanceAlert = true;
  bool _systemMaintenance = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationToggle(
            icon: Icons.person_add,
            title: 'New User Registered',
            description: 'Receive alerts when a new user joins your network.',
            value: _newUserRegistered,
            onChanged: (value) => setState(() => _newUserRegistered = value),
          ),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            icon: Icons.wifi_off,
            title: 'Router Offline',
            description: 'Get notified if a router goes offline.',
            value: _routerOffline,
            onChanged: (value) => setState(() => _routerOffline = value),
          ),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            icon: Icons.attach_money,
            title: 'Payout Confirmation',
            description: 'Receive confirmation when a payout is processed.',
            value: _payoutConfirmation,
            onChanged: (value) => setState(() => _payoutConfirmation = value),
          ),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            icon: Icons.account_balance_wallet,
            title: 'Low Balance Alert',
            description: 'Get an alert when your account balance is low.',
            value: _lowBalanceAlert,
            onChanged: (value) => setState(() => _lowBalanceAlert = value),
          ),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            icon: Icons.build,
            title: 'System Maintenance',
            description: 'Stay informed about system updates.',
            value: _systemMaintenance,
            onChanged: (value) => setState(() => _systemMaintenance = value),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification settings saved'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: AppTheme.pureWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}
