import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class UserRoleScreen extends StatelessWidget {
  const UserRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final appState = context.watch<AppState>();
    final roles = appState.roles;

    return Scaffold(
      appBar: AppBar(
        title: Text('user_roles_permissions'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'manage_roles'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                'permissions_enabled'.tr(namedArgs: {'count': '${role.permissions.values.where((v) => v).length}'}),
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
                      foregroundColor: colorScheme.primary,
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
            label: Text('create_new_role'.tr()),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_role'.tr()),
        content: Text('delete_role_confirm'.tr(namedArgs: {'name': role.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().deleteRole(role.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('role_deleted'.tr())),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }
}
