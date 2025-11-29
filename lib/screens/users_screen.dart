import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../models/worker_model.dart';
import '../utils/app_theme.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/create_worker_dialog.dart';
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
    
    // Restore tab index if saved
    // We use a post-frame callback to set the index to avoid initial animation glitches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedIndex = PageStorage.of(context).readState(context, identifier: 'users_tab_index') as int?;
      if (savedIndex != null && savedIndex != _tabController.index) {
        _tabController.animateTo(savedIndex);
      }
    });

    _tabController.addListener(() {
      // Save tab index
      if (!_tabController.indexIsChanging) {
        PageStorage.of(context).writeState(context, _tabController.index, identifier: 'users_tab_index');
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadUsers();
      context.read<AppState>().loadWorkers();
      context.read<AppState>().loadRoles();
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
    final firstNameController = TextEditingController(text: userData?['first_name'] ?? userData?['name']);
    final phoneController = TextEditingController(text: userData?['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(userData == null ? 'add_user'.tr() : 'edit_user'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
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
            onPressed: () {
              final data = {
                'first_name': firstNameController.text,
                'phone': phoneController.text,
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
                      _buildUserList(users, isCustomers: true),
                      _buildWorkerList(appState.workers),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(appState),
    );
  }

  Widget? _buildFAB(AppState appState) {
    final canCreate = Permissions.canCreateUsers(
      appState.currentUser?.role ?? '',
      appState.currentUser?.permissions,
    );
    
    if (!canCreate) return null;

    return FloatingActionButton.extended(
      onPressed: () {
        if (_tabController.index == 0) {
          // Customers tab - create user
          _showUserDialog();
        } else {
          // Workers tab - create worker
          showDialog(
            context: context,
            builder: (context) => const CreateWorkerDialog(),
          );
        }
      },
      icon: Icon(_tabController.index == 0 ? Icons.person_add : Icons.badge),
      label: Text(_tabController.index == 0 ? 'add_user'.tr() : 'create_worker'.tr()),
    );
  }

  Widget _buildUserList(List users, {bool isCustomers = false}) {
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
    
    // Debug logging
    if (kDebugMode) {
      print('🔍 [UsersScreen] Current user role: ${currentUser.role}');
      print('🔍 [UsersScreen] Current user permissions: ${currentUser.permissions}');
      print('🔍 [UsersScreen] canEditUsers: ${Permissions.canEditUsers(currentUser.role, currentUser.permissions)}');
      print('🔍 [UsersScreen] canViewUsers: ${Permissions.canViewUsers(currentUser.role, currentUser.permissions)}');
      print('🔍 [UsersScreen] canDeleteUsers: ${Permissions.canDeleteUsers(currentUser.role, currentUser.permissions)}');
    }
    
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
            // Show message if no permissions
            if (!Permissions.canEditUsers(currentUser.role, currentUser.permissions) &&
                !Permissions.canViewUsers(currentUser.role, currentUser.permissions) &&
                !Permissions.canDeleteUsers(currentUser.role, currentUser.permissions))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'You don\'t have permission to manage users',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerList(List workers) {
    if (workers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No workers found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: workers.length,
      itemBuilder: (context, index) {
        final worker = workers[index];
        final colorScheme = Theme.of(context).colorScheme;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.badge,
                color: colorScheme.secondary,
              ),
            ),
            title: Text(
              worker.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(worker.email),
                const SizedBox(height: 4),
                if (worker.roleName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      worker.roleName!,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'No Role',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showWorkerMenu(context, worker);
              },
            ),
          ),
        );
      },
    );
  }

  void _showWorkerMenu(BuildContext context, worker) {
    final currentUser = context.read<AppState>().currentUser;
    if (currentUser == null) return;
    
    // Debug logging
    if (kDebugMode) {
      print('🔍 [UsersScreen] Worker menu - Current user role: ${currentUser.role}');
      print('🔍 [UsersScreen] Worker menu - Current user permissions: ${currentUser.permissions}');
    }
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // View Details
            if (Permissions.canViewUsers(currentUser.role, currentUser.permissions))
              ListTile(
                leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showWorkerDetailsDialog(context, worker);
                },
              ),
            // Edit Worker
            if (Permissions.canEditUsers(currentUser.role, currentUser.permissions))
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Worker'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWorkerDialog(context, worker);
                },
              ),
            // Assign/Change Role
            ListTile(
              leading: Icon(Icons.badge, color: Theme.of(context).colorScheme.primary),
              title: Text(worker.roleName != null ? 'Change Role' : 'Assign Role'),
              onTap: () {
                Navigator.pop(context);
                _showAssignRoleDialog(context, worker);
              },
            ),
            // Assign Router
            if (Permissions.canAssignRouters(currentUser.role))
              ListTile(
                leading: Icon(Icons.router, color: Theme.of(context).colorScheme.secondary),
                title: const Text('Assign Router'),
                onTap: () {
                  Navigator.pop(context);
                  _showAssignRouterDialog(context, worker);
                },
              ),
            // Delete Worker
            if (Permissions.canDeleteUsers(currentUser.role, currentUser.permissions))
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorRed),
                title: Text('remove_worker'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('remove_worker'.tr()),
                      content: Text('Are you sure you want to remove ${worker.fullName}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () async {
                            try {
                              await context.read<AppState>().deleteWorker(worker.username);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Worker removed successfully')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
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

  void _showAssignRoleDialog(BuildContext context, worker) {
    final appState = context.read<AppState>();
    final roles = appState.roles;
    String? selectedRole = worker.roleSlug;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(worker.roleName != null ? 'Change Role' : 'Assign Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'role'.tr(),
                  border: const OutlineInputBorder(),
                ),
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role.slug,
                      child: Text(role.name),
                    );
                  }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () async {
                if (selectedRole != null) {
                  try {
                    if (worker.roleSlug == null) {
                      await appState.assignRoleToWorker(worker.username, selectedRole!);
                    } else {
                      await appState.updateWorkerRole(worker.username, selectedRole!);
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Role ${worker.roleSlug == null ? "assigned" : "updated"} successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkerDetailsDialog(BuildContext context, WorkerModel worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Worker Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', worker.fullName),
              _buildDetailRow('Email', worker.email),
              _buildDetailRow('Username', worker.username),
              _buildDetailRow('Role', worker.roleName ?? 'No role'),
              _buildDetailRow('Status', worker.isActive ? 'Active' : 'Inactive'),
              if (worker.assignedRouters != null && worker.assignedRouters!.isNotEmpty)
                _buildDetailRow('Assigned Routers', worker.assignedRouters!.join(', ')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditWorkerDialog(BuildContext context, WorkerModel worker) {
    final firstNameController = TextEditingController(text: worker.fullName.split(' ').first);
    final lastNameController = TextEditingController(text: worker.fullName.split(' ').skip(1).join(' '));
    final emailController = TextEditingController(text: worker.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Worker'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
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
              try {
                await context.read<AppState>().updateWorker(worker.username, {
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'email': emailController.text,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Worker updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignRouterDialog(BuildContext context, WorkerModel worker) {
    final appState = context.read<AppState>();
    final routers = appState.routers;
    String? selectedRouter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign Router to ${worker.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (routers.isEmpty)
                const Text('No routers available')
              else
                DropdownButtonFormField<String>(
                  value: selectedRouter,
                  decoration: const InputDecoration(
                    labelText: 'Select Router',
                    border: OutlineInputBorder(),
                  ),
                  items: routers.map((router) {
                    return DropdownMenuItem(
                      value: router.id,
                      child: Text(router.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRouter = value;
                    });
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: selectedRouter == null
                  ? null
                  : () async {
                      try {
                        await appState.assignRouterToWorker(worker.username, selectedRouter!);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Router assigned successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }


}
