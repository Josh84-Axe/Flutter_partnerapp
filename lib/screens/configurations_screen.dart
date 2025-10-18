import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ConfigurationsScreen extends StatelessWidget {
  const ConfigurationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConfigCard(
            context,
            icon: Icons.speed,
            title: 'Rate Limit',
            subtitle: 'Configure upload and download speeds',
            onTap: () {
              Navigator.of(context).pushNamed('/config/rate-limit');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.timer,
            title: 'Idle Timeout',
            subtitle: 'Duration before automatic disconnect',
            onTap: () {
              Navigator.of(context).pushNamed('/config/idle-time');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.calendar_today,
            title: 'Validity',
            subtitle: 'Plan duration settings',
            onTap: () {
              Navigator.of(context).pushNamed('/config/plan-validity');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.data_usage,
            title: 'Data Limit',
            subtitle: 'GB allowance configuration',
            onTap: () {
              Navigator.of(context).pushNamed('/config/data-limit');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.group,
            title: 'Shared Users',
            subtitle: 'Concurrent users allowed',
            onTap: () {
              Navigator.of(context).pushNamed('/config/shared-users');
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.devices,
            title: 'Additional Devices',
            subtitle: 'Extra device slots configuration',
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
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
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
