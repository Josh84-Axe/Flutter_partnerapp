import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class RolePermissionScreen extends StatelessWidget {
  const RolePermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final roles = appState.roles;

    return Scaffold(
      appBar: AppBar(
        title: Text('user_roles_permissions'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'existing_roles'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/create-role');
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text('create_new_role'.tr()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...roles.map((role) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getRoleIcon(role.name),
                      color: AppTheme.primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'team_members_count'.tr(namedArgs: {'count': _getTeamMemberCount(role.name).toString()}),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      '/create-role',
                                      arguments: role.toJson(),
                                    );
                                  },
                                  color: AppTheme.textLight,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _showDeleteDialog(context, role),
                                  color: AppTheme.errorRed,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getRoleDescription(role.name),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                        if (role.name.toLowerCase() == 'worker') ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.router, size: 18),
                            label: Text('manage_assigned_routers'.tr()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(color: AppTheme.primaryGreen),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 32),
          Text(
            'team_access_management'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/assign-role');
            },
            icon: const Icon(Icons.person_add),
            label: Text('assign_role_to_user'.tr()),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.textDark,
              side: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'assign_role_description'.tr(),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return Icons.admin_panel_settings;
      case 'manager':
        return Icons.shield;
      case 'worker':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }

  int _getTeamMemberCount(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return 2;
      case 'manager':
        return 3;
      case 'worker':
        return 5;
      default:
        return 0;
    }
  }

  String _getRoleDescription(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return 'role_admin_description'.tr();
      case 'manager':
        return 'role_manager_description'.tr();
      case 'worker':
        return 'role_worker_description'.tr();
      default:
        return '';
    }
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
