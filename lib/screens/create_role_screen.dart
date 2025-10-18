import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class CreateRoleScreen extends StatefulWidget {
  final Map<String, dynamic>? roleData;

  const CreateRoleScreen({super.key, this.roleData});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _nameController = TextEditingController();
  final Map<String, bool> _permissions = {
    'dashboard_access': false,
    'user_create': false,
    'user_read': false,
    'user_update': false,
    'user_delete': false,
    'plan_create': false,
    'plan_read': false,
    'plan_update': false,
    'plan_delete': false,
    'transaction_viewing': false,
    'router_management': false,
    'settings_access': false,
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
    final isEdit = widget.roleData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Role' : 'Create New Role'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Role Name',
                      hintText: 'e.g., Support Agent',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Permissions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'Dashboard Access',
                    {'dashboard_access': 'Dashboard Access'},
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'User Management',
                    {
                      'user_create': 'Create Users',
                      'user_read': 'Read Users',
                      'user_update': 'Update Users',
                      'user_delete': 'Delete Users',
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'Plan Management',
                    {
                      'plan_create': 'Create Plans',
                      'plan_read': 'Read Plans',
                      'plan_update': 'Update Plans',
                      'plan_delete': 'Delete Plans',
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'Transaction Viewing',
                    {'transaction_viewing': 'Transaction Viewing'},
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'Router Management',
                    {'router_management': 'Router Management'},
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionSection(
                    'Settings Access',
                    {'settings_access': 'Settings Access'},
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
                  color: Colors.black.withOpacity(0.1),
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
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveRole,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Role'),
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
              activeColor: AppTheme.primaryGreen,
              contentPadding: permissions.length == 1 ? EdgeInsets.zero : null,
            )),
          ],
        ),
      ),
    );
  }

  void _saveRole() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a role name')),
      );
      return;
    }

    final data = {
      'id': widget.roleData?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text,
      'permissions': _permissions,
    };

    if (widget.roleData != null) {
      context.read<AppState>().updateRole(data['id'] as String, data);
    } else {
      context.read<AppState>().createRole(data);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.roleData != null ? 'Role updated' : 'Role created')),
    );
  }
}
