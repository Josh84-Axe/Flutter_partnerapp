import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/search_bar_widget.dart';

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
          title: Text(userData == null ? 'Add User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['user', 'worker', 'owner', 'admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
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
                const Text(
                  'Worker Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: const Text('Create Plans'),
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
                  title: const Text('View Users'),
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
                  title: const Text('View Transactions'),
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
                  title: const Text('View Routers'),
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
            child: const Text('Cancel'),
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
            child: Text(userData == null ? 'Add' : 'Update'),
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
        title: const Text('Users & Workers'),
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
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Workers'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'Search by name, email, or phone...',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
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
              'No users found',
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
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
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
                            ? AppTheme.successGreen.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
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
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit User'),
              onTap: () {
                Navigator.pop(context);
                _showUserDialog(userData: user.toJson());
              },
            ),
            ListTile(
              leading: const Icon(Icons.router, color: AppTheme.primaryGreen),
              title: const Text('Assign Router'),
              onTap: () {
                Navigator.pop(context);
                _showAssignRouterDialog(context, user);
              },
            ),
            ListTile(
              leading: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
                color: user.isActive ? AppTheme.errorRed : AppTheme.successGreen,
              ),
              title: Text(user.isActive ? 'Block User' : 'Unblock User'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      user.isActive ? 'User blocked' : 'User unblocked',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorRed),
              title: const Text('Delete User'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete User'),
                    content: Text('Delete ${user.name}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          context.read<AppState>().deleteUser(user.id);
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.errorRed,
                        ),
                        child: const Text('Delete'),
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

  void _showAssignRouterDialog(BuildContext context, user) {
    final appState = context.read<AppState>();
    String? selectedRouterId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign Router to ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a router to assign:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRouterId,
                decoration: const InputDecoration(labelText: 'Router'),
                items: appState.routers
                    .map((router) => DropdownMenuItem(
                          value: router.id,
                          child: Text(router.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRouterId = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedRouterId == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Router assigned to ${user.name}')),
                      );
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}
