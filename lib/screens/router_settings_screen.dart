import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/router_configuration_model.dart';
import '../utils/app_theme.dart';

class RouterSettingsScreen extends StatefulWidget {
  const RouterSettingsScreen({super.key});

  @override
  State<RouterSettingsScreen> createState() => _RouterSettingsScreenState();
}

class _RouterSettingsScreenState extends State<RouterSettingsScreen> {
  void _showDeleteDialog(RouterConfigurationModel config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete "${config.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Router configuration deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final configurations = appState.routerConfigurations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Router Configurations'),
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/add-router');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          config.ipAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                        if (config.apiPort != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Port: ${config.apiPort}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
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
                          foregroundColor: AppTheme.primaryGreen,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showDeleteDialog(config),
                        icon: const Icon(Icons.delete),
                        style: IconButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          backgroundColor: AppTheme.errorRed.withOpacity(0.1),
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
