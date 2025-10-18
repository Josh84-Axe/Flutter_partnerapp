import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class UserRoleScreen extends StatelessWidget {
  const UserRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final roles = appState.roles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Roles & Permissions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Manage Roles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...roles.map((role) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                role.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${role.permissions.values.where((v) => v).length} permissions enabled',
                style: TextStyle(color: AppTheme.textLight),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/create-role',
                        arguments: role.toJson(),
                      );
                    },
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(context, role),
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/create-role');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Role'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().deleteRole(role.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Role deleted')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
