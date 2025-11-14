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
  List<Map<String, dynamic>> _hotspotUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHotspotUsers();
  }

  Future<void> _loadHotspotUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load hotspot users from HotspotRepository.fetchUsers()
      // For now, use empty list
      setState(() {
        _hotspotUsers = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_loading_users'.tr())),
        );
      }
    }
  }

  void _showCreateUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String? selectedProfile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('create_hotspot_user'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'username'.tr(),
                    hintText: 'enter_username'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'password'.tr(),
                    hintText: 'enter_password'.tr(),
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
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () async {
                if (usernameController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    selectedProfile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('fill_required_fields'.tr())),
                  );
                  return;
                }

                // TODO: Create hotspot user using HotspotRepository.createUser()
                Navigator.pop(context);
                _loadHotspotUsers();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('hotspot_user_created'.tr()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('create'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredUsers = _hotspotUsers.where((user) {
      return user['username']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('hotspot_users'.tr()),
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
            child: _isLoading
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
                              subtitle: Text(user['profile']?.toString() ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      // TODO: Edit user
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: AppTheme.errorRed,
                                    onPressed: () {
                                      // TODO: Delete user
                                    },
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
