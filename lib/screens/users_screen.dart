import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/search_bar_widget.dart';
import '../utils/permissions.dart';
import '../utils/permission_mapping.dart';
import '../widgets/permission_denied_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showUserDialog({Map<String, dynamic>? userData}) {
    final currentUser = context.read<AppState>().currentUser;
    if (currentUser == null) return;
    // Permission check for create vs edit
    final hasPermission = userData == null
        ? Permissions.canCreateUsers(currentUser.role, currentUser.permissions)
        : Permissions.canEditUsers(currentUser.role, currentUser.permissions);
    if (!hasPermission) {
      PermissionDeniedDialog.show(
        context,
        requiredPermission: userData == null ? PermissionConstants.createUsers : PermissionConstants.editUsers,
      );
      return;
    }
    final nameController = TextEditingController(text: userData?['name']);
    final emailController = TextEditingController(text: userData?['email']);
    final phoneController = TextEditingController(text: userData?['phone']);
    String selectedRole = userData?['role'] ?? 'user';
    final Set<String> selectedPermissions = userData?['permissions'] != null 
        ? Set<String>.from(userData!['permissions']) 
        : {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(userData == null ? 'add_user'.tr() : 'edit_user'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'name'.tr()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'email'.tr()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'phone'.tr()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(labelText: 'role'.tr()),
                items: ['user', 'worker', 'owner', 'admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.tr()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                    if (selectedRole != 'worker') {
                      selectedPermissions.clear();
                    }
                  });
                },
              ),
              if (selectedRole == 'worker') ...[
                const SizedBox(height: 12),
                Text(
                  'worker_permissions'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: Text('create_plans'.tr()),
                  value: selectedPermissions.contains('create_plans'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('create_plans');
                      } else {
                        selectedPermissions.remove('create_plans');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('manage_users'.tr()),
                  value: selectedPermissions.contains('view_users'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('view_users');
                      } else {
                        selectedPermissions.remove('view_users');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('view_reports'.tr()),
                  value: selectedPermissions.contains('view_transactions'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('view_transactions');
                      } else {
                        selectedPermissions.remove('view_transactions');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('configure_routers'.tr()),
                  value: selectedPermissions.contains('view_routers'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('view_routers');
                      } else {
                        selectedPermissions.remove('view_routers');
                      }
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              final data = {
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'role': selectedRole,
                'permissions': selectedRole == 'worker' 
                    ? selectedPermissions.toList() 
                    : null,
                if (userData != null) 'createdAt': userData['createdAt'],
                if (userData != null) 'isActive': userData['isActive'],
              };

              if (userData == null) {
                context.read<AppState>().createUser(data);
              } else {
                context.read<AppState>().updateUser(userData['id'], data);
              }

              Navigator.pop(context);
            },
            child: Text(userData == null ? 'add_user'.tr() : 'edit_user'.tr()),
          ),
        ],
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allUsers = appState.users.where((user) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.phone?.toLowerCase().contains(query) ?? false);
    }).toList();

    final users = allUsers.where((u) => u.role == 'user').toList();
    final workers = allUsers.where((u) => u.role == 'worker' || u.role == 'admin').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'users'.tr(),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'Bulk Actions',
            onPressed: () {
              Navigator.of(context).pushNamed('/bulk-actions');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadUsers(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.pureWhite,
          tabs: [
            Tab(text: 'users'.tr()),
            Tab(text: 'workers'.tr()),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'search_users'.tr(),
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: appState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUserList(users),
                      _buildUserList(workers),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Permissions.canCreateUsers(appState.currentUser?.role ?? '', appState.currentUser?.permissions)
          ? FloatingActionButton(
              onPressed: () => _showUserDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildUserList(List users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'no_users_found'.tr(),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isConnected = user.isActive && index % 2 == 0;
        final connectionType = index % 3 == 0 ? 'Gateway' : 'Assigned';
        
        final colorScheme = Theme.of(context).colorScheme;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                user.name[0].toUpperCase(),
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.isActive 
                            ? AppTheme.successGreen.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: user.isActive ? AppTheme.successGreen : Colors.grey[700],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isConnected) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Connected — $connectionType',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ] else if (user.isActive) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Disconnected',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showUserMenu(context, user);
              },
            ),
          ),
        );
      },
    );
  }

  void _showUserMenu(BuildContext context, user) {
    final currentUser = context.read<AppState>().currentUser;
    if (currentUser == null) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Permissions.canEditUsers(currentUser.role, currentUser.permissions))
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text('edit_user'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _showUserDialog(userData: user.toJson());
                },
              ),
            if (Permissions.canViewUsers(currentUser.role, currentUser.permissions))
              ListTile(
                leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                title: Text('view_details'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/user-details', arguments: user);
                },
              ),
            // Block/Unblock action (requires edit permission)
            if (Permissions.canEditUsers(currentUser.role, currentUser.permissions))
              ListTile(
                leading: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  color: user.isActive ? AppTheme.errorRed : AppTheme.successGreen,
                ),
                title: Text(user.isActive ? 'block_device'.tr() : 'unblock_device'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        user.isActive ? 'device_blocked'.tr() : 'device_unblocked'.tr(),
                      ),
                    ),
                  );
                },
              ),
            if (Permissions.canDeleteUsers(currentUser.role, currentUser.permissions))
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorRed),
                title: Text('remove_user'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('remove_user'.tr()),
                      content: Text('remove_user_confirm'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () {
                            context.read<AppState>().deleteUser(user.id);
                            Navigator.pop(context);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                          ),
                          child: Text('remove'.tr()),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }



}
