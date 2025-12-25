import '../models/router_model.dart';
import '../providers/split/network_provider.dart';
import '../utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class RouterDetailsScreen extends StatelessWidget {
  final RouterModel router;

  const RouterDetailsScreen({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(router.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: router.status == 'ONLINE'
                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                    : AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                router.status == 'ONLINE' ? Icons.router : Icons.router_outlined,
                size: 80,
                color: router.status == 'ONLINE'
                    ? AppTheme.successGreen
                    : AppTheme.errorRed,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            router.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: router.status == 'ONLINE'
                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                    : AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                router.status,
                style: TextStyle(
                  color: router.status == 'ONLINE'
                      ? AppTheme.successGreen
                      : AppTheme.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            title: 'status_information'.tr(),
            children: [
              _buildInfoRow(context, 'uptime'.tr(), '${router.uptimeHours} ${'hours'.tr()}'),
              _buildInfoRow(context, 'firmware_version'.tr(), '2.1.0'),
              _buildInfoRow(
                context,
                'connected_devices'.tr(),
                '${router.connectedUsers}',
              ),
              _buildInfoRow(context, 'ip_address'.tr(), '192.168.1.1'),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'actions'.tr(),
            children: [
              _buildActionButton(
                context,
                icon: Icons.restart_alt,
                label: 'restart_router'.tr(),
                onTap: () async {
                  final networkProvider = context.read<NetworkProvider>();
                  final success = await networkProvider.rebootRouter(router.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'router_restart_initiated'.tr() : 'error_occurred'.tr())),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                context,
                icon: Icons.flash_on,
                label: 'restart_hotspot'.tr(),
                onTap: () async {
                  final networkProvider = context.read<NetworkProvider>();
                  final success = await networkProvider.restartHotspot(router.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'hotspot_restart_initiated'.tr() : 'error_occurred'.tr())),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                context,
                icon: Icons.delete_outline,
                label: 'delete_router'.tr(),
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_router'.tr()),
        content: Text('delete_router_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              final networkProvider = context.read<NetworkProvider>();
              Navigator.pop(context); // Close dialog
              try {
                await networkProvider.deleteRouter(router.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close details screen
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('error_occurred'.tr())),
                  );
                }
              }
            },
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
