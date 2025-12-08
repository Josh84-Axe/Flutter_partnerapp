import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class HotspotUsersManagementScreen extends StatefulWidget {
  const HotspotUsersManagementScreen({super.key});

  @override
  State<HotspotUsersManagementScreen> createState() => _HotspotUsersManagementScreenState();
}

class _HotspotUsersManagementScreenState extends State<HotspotUsersManagementScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final appState = context.read<AppState>();
    await appState.loadHotspotUsers();
    await appState.loadHotspotProfiles();
  }

  void _showCreateUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedProfile;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('create_hotspot_user'.tr()),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'username'.tr(),
                      hintText: 'enter_username'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'required_field'.tr() : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      hintText: 'enter_password'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => value?.isEmpty ?? true ? 'required_field'.tr() : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedProfile,
                    decoration: InputDecoration(
                      labelText: 'hotspot_profile'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    hint: Text('select_profile'.tr()),
                    items: context.watch<AppState>().hotspotProfiles.map((profile) {
                      return DropdownMenuItem(
                        value: profile.id,
                        child: Text(profile.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedProfile = value),
                    validator: (value) => value == null ? 'required_field'.tr() : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    await context.read<AppState>().createHotspotUser({
                      'username': usernameController.text,
                      'password': passwordController.text,
                      'profile': selectedProfile,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('hotspot_user_created'.tr()),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('error_generic'.tr(namedArgs: {'error': e.toString()}))),
                      );
                    }
                  }
                }
              },
              child: Text('create'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final usernameController = TextEditingController(text: user['username']?.toString() ?? '');
    final passwordController = TextEditingController();
    String? selectedProfile = user['profile']?.toString();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('edit_hotspot_user'.tr()),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'username'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    enabled: false, // Username cannot be changed
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'new_password'.tr(),
                      hintText: 'leave_blank_to_keep_current'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedProfile,
                    decoration: InputDecoration(
                      labelText: 'hotspot_profile'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    hint: Text('select_profile'.tr()),
                    items: context.watch<AppState>().hotspotProfiles.map((profile) {
                      return DropdownMenuItem(
                        value: profile.id,
                        child: Text(profile.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedProfile = value),
                    validator: (value) => value == null ? 'required_field'.tr() : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    final updateData = <String, dynamic>{
                      'profile': selectedProfile,
                    };
                    
                    // Only include password if it was changed
                    if (passwordController.text.isNotEmpty) {
                      updateData['password'] = passwordController.text;
                    }
                    
                    await context.read<AppState>().updateHotspotUser(
                      user['username'],
                      updateData,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('hotspot_user_updated'.tr()),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('error_generic'.tr(namedArgs: {'error': e.toString()}))),
                      );
                    }
                  }
                }
              },
              child: Text('update'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser(Map<String, dynamic> user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_user'.tr()),
        content: Text('delete_user_confirmation'.tr(args: [user['username'] ?? ''])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AppState>().deleteHotspotUser(user['username']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('user_deleted'.tr())),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('error_generic'.tr(namedArgs: {'error': e.toString()}))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final colorScheme = Theme.of(context).colorScheme;
    
    final filteredUsers = appState.hotspotUsers.where((user) {
      final username = user['username']?.toString().toLowerCase() ?? '';
      return username.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('hotspot_users'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_users'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: appState.isLoading && appState.hotspotUsers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_hotspot_users'.tr(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'create_first_hotspot_user'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  color: colorScheme.primary,
                                ),
                              ),
                              title: Text(user['username']?.toString() ?? ''),
                              subtitle: Text(user['profile']?.toString() ?? 'no_profile'.tr()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: colorScheme.primary,
                                    onPressed: () => _showEditUserDialog(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: AppTheme.errorRed,
                                    onPressed: () => _confirmDeleteUser(user),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _showCreateUserDialog,
                  icon: const Icon(Icons.add),
                  label: Text('create_hotspot_user'.tr()),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
