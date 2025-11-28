import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';

class CreateRoleScreen extends StatefulWidget {
  final Map<String, dynamic>? roleData;

  const CreateRoleScreen({super.key, this.roleData});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Map<String, bool> _permissions = {
    'create_plans': false,
    'view_plans': false,
    'edit_plans': false,
    'delete_plans': false,
    'view_users': false,
    'create_users': false,
    'edit_users': false,
    'delete_users': false,
    'view_routers': false,
    'assign_routers': false,
    'manage_routers': false,
    'view_transactions': false,
    'manage_roles': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.roleData != null) {
      _nameController.text = widget.roleData!['name'] ?? '';
      final perms = widget.roleData!['permissions'] as Map<String, dynamic>?;
      if (perms != null) {
        perms.forEach((key, value) {
          if (_permissions.containsKey(key)) {
            _permissions[key] = value as bool;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isEdit = widget.roleData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_role'.tr() : 'create_new_role'.tr()),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'role_name'.tr(),
                        hintText: 'role_name_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter role name';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'permissions'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'dashboard_access'.tr(),
                    {'dashboard_access': 'dashboard_access'.tr()},
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'user_management'.tr(),
                    {
                      'user_create': 'create_users'.tr(),
                      'user_read': 'read_users'.tr(),
                      'user_update': 'update_users'.tr(),
                      'user_delete': 'delete_users'.tr(),
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'plan_management'.tr(),
                    {
                      'plan_create': 'create_plans'.tr(),
                      'plan_read': 'read_plans'.tr(),
                      'plan_update': 'update_plans'.tr(),
                      'plan_delete': 'delete_plans'.tr(),
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'transaction_viewing'.tr(),
                    {'transaction_viewing': 'transaction_viewing'.tr()},
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'router_management'.tr(),
                    {'router_management': 'router_management'.tr()},
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'settings_access'.tr(),
                    {'settings_access': 'settings_access'.tr()},
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('cancel'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveRole,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('save_role'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSection(String title, Map<String, String> permissions) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (permissions.length > 1)
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            if (permissions.length > 1) const SizedBox(height: 12),
            ...permissions.entries.map((entry) => SwitchListTile(
              title: Text(entry.value),
              value: _permissions[entry.key] ?? false,
              onChanged: (value) {
                setState(() {
                  _permissions[entry.key] = value;
                });
              },
              activeTrackColor: colorScheme.primary,
              contentPadding: permissions.length == 1 ? EdgeInsets.zero : null,
            )),
          ],
        ),
      ),
    );
  }

  void _saveRole() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'name': _nameController.text,
      'permissions': _permissions,
    };

    if (widget.roleData != null) {
      context.read<AppState>().updateRole(widget.roleData!['id'], data);
    } else {
      context.read<AppState>().createRole(data);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.roleData != null ? 'role_updated'.tr() : 'role_created'.tr())),
    );
  }
}
