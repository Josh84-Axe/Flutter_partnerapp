import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/split/network_provider.dart';
import '../models/router_configuration_model.dart';
import '../utils/app_theme.dart';

class RouterSettingsScreen extends StatefulWidget {
  const RouterSettingsScreen({super.key});

  @override
  State<RouterSettingsScreen> createState() => _RouterSettingsScreenState();
}

class _RouterSettingsScreenState extends State<RouterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkProvider>().loadRouters();
    });
  }

  void _showDeleteDialog(RouterConfigurationModel config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_configuration'.tr()),
        content: Text('delete_configuration_confirm'.tr(namedArgs: {'name': config.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              context.read<NetworkProvider>().deleteRouter(config.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('router_configuration_deleted'.tr())),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final networkProvider = context.watch<NetworkProvider>();
    final configurations = networkProvider.routerConfigurations;

    return Scaffold(
      appBar: AppBar(
        title: Text('router_configurations'.tr()),
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/add-router');
            },
            icon: const Icon(Icons.add),
            label: Text('add_new'.tr()),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: networkProvider.isLoading && configurations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : configurations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.router, size: 64, color: colorScheme.secondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'no_routers_found'.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: configurations.length,
        itemBuilder: (context, index) {
          final config = configurations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Router icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.router,
                        color: colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (config.isActive ?? true)
                                    ? Colors.green.withValues(alpha: 0.12)
                                    : Colors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (config.isActive ?? true)
                                    ? 'active'.tr()
                                    : 'inactive'.tr(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: (config.isActive ?? true)
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'API: ${config.apiPort ?? 8728}  •  CoA: ${config.coaPort ?? 3799}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/add-router',
                            arguments: config,
                          );
                        },
                        icon: const Icon(Icons.edit),
                        style: IconButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showDeleteDialog(config),
                        icon: const Icon(Icons.delete),
                        style: IconButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          backgroundColor: AppTheme.errorRed.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
