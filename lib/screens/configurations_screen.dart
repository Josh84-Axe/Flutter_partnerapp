import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_theme.dart';

class ConfigurationsScreen extends StatelessWidget {
  const ConfigurationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('configurations'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConfigCard(
            context,
            icon: Icons.speed,
            title: 'rate_limit'.tr(),
            subtitle: 'configure_speeds_desc'.tr(),
            onTap: () {
              Navigator.of(context).pushNamed('/config/rate-limit');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.timer,
            title: 'idle_timeout'.tr(),
            subtitle: 'duration_disconnect_desc'.tr(),
            onTap: () {
              Navigator.of(context).pushNamed('/config/idle-time');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.calendar_today,
            title: 'validity'.tr(),
            subtitle: 'plan_duration_desc'.tr(),
            onTap: () {
              Navigator.of(context).pushNamed('/config/plan-validity');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.data_usage,
            title: 'data_limit'.tr(),
            subtitle: 'gb_allowance_desc'.tr(),
            onTap: () {
              Navigator.of(context).pushNamed('/config/data-limit');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.group,
            title: 'shared_users'.tr(),
            subtitle: 'concurrent_users_desc'.tr(),
            onTap: () {
              Navigator.of(context).pushNamed('/config/shared-users');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.devices,
            title: 'additional_devices'.tr(),
            subtitle: 'extra_device_desc'.tr(),
            onTap: () {
              Navigator.of(context).pushNamed('/config/additional-devices');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
          child: Icon(icon, color: AppTheme.primaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

}
