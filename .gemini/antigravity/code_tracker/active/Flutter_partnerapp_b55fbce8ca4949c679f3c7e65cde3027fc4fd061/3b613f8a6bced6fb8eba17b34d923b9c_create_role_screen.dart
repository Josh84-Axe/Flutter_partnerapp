é9import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';

class CreateRoleScreen extends StatefulWidget {
  final Map<String, dynamic>? roleData;

  const CreateRoleScreen({super.key, this.roleData});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final Set<int> _selectedPermissionIds = {};
  List<dynamic> _availablePermissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.roleData?['name'] ?? '');
    _loadPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await context.read<AppState>().fetchPermissions();
      if (mounted) {
        setState(() {
          _availablePermissions = permissions;
          _isLoading = false;
          
          // If editing, pre-select permissions
          if (widget.roleData != null && widget.roleData!['permissions'] != null) {
            final currentPerms = widget.roleData!['permissions'] as List;
            for (var perm in currentPerms) {
              if (perm is int) {
                _selectedPermissionIds.add(perm);
              } else if (perm is Map && perm['id'] != null) {
                _selectedPermissionIds.add(perm['id']);
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading permissions: $e')),
        );
      }
    }
  }

  void _saveRole() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'name': _nameController.text,
      'permissions': _selectedPermissionIds.toList(),
    };

    if (widget.roleData != null) {
      context.read<AppState>().updateRole(widget.roleData!['slug'] ?? widget.roleData!['id'], data);
    } else {
      context.read<AppState>().createRole(data);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.roleData != null ? 'role_updated'.tr() : 'role_created'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roleData != null ? 'edit_role'.tr() : 'create_new_role'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'role_name'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please_enter_role_name'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'permissions'.tr(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (_availablePermissions.isEmpty)
                            Text('no_permissions_available'.tr())
                          else
                            ..._availablePermissions.map((perm) {
                              final id = perm['id'] as int;
                              final name = perm['name'] as String;
                              final codename = perm['codename'] as String;
                              
                              return CheckboxListTile(
                                title: Text(name),
                                subtitle: Text(codename),
                                value: _selectedPermissionIds.contains(id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedPermissionIds.add(id);
                                    } else {
                                      _selectedPermissionIds.remove(id);
                                    }
                                  });
                                },
                              );
                            }),
                        ],
                      ),
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
}
Œ ŒŒ*cascade08
ŒÜ ÜÕ9*cascade08
Õ9é9 "(b55fbce8ca4949c679f3c7e65cde3027fc4fd0612lfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/create_role_screen.dart:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp