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
              _showRateLimitDialog(context);
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.timer,
            title: 'Idle Timeout',
            subtitle: 'Duration before automatic disconnect',
            onTap: () {
              _showIdleTimeoutDialog(context);
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.calendar_today,
            title: 'Validity',
            subtitle: 'Plan duration settings',
            onTap: () {
              _showValidityDialog(context);
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.data_usage,
            title: 'Data Limit',
            subtitle: 'GB allowance configuration',
            onTap: () {
              _showDataLimitDialog(context);
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.group,
            title: 'Shared Users',
            subtitle: 'Concurrent users allowed',
            onTap: () {
              _showSharedUsersDialog(context);
            },
          ),
          const SizedBox(height: 12),
          _buildConfigCard(
            context,
            icon: Icons.devices,
            title: 'Additional Devices',
            subtitle: 'Extra device slots configuration',
            onTap: () {
              _showAdditionalDevicesDialog(context);
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

  void _showRateLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Limit Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Basic'),
              subtitle: const Text('10 Mbps Download / 5 Mbps Upload'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Standard'),
              subtitle: const Text('50 Mbps Download / 25 Mbps Upload'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Premium'),
              subtitle: const Text('100 Mbps Download / 50 Mbps Upload'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showIdleTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idle Timeout Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Short'),
              subtitle: const Text('15 minutes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Standard'),
              subtitle: const Text('30 minutes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Long'),
              subtitle: const Text('60 minutes'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validity Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Daily'),
              subtitle: const Text('1 day'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Weekly'),
              subtitle: const Text('7 days'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Monthly'),
              subtitle: const Text('30 days'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Limit Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              subtitle: const Text('10 GB'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Standard'),
              subtitle: const Text('50 GB'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Unlimited'),
              subtitle: const Text('No limit'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSharedUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shared Users Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Single User'),
              subtitle: const Text('1 concurrent user'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Family Plan'),
              subtitle: const Text('5 concurrent users'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Small Business'),
              subtitle: const Text('10 concurrent users'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdditionalDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Additional Devices Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Basic'),
              subtitle: const Text('1 device'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Standard'),
              subtitle: const Text('3 devices'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Premium'),
              subtitle: const Text('5 devices'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
