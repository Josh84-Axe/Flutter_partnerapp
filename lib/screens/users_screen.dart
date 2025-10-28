import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadUsers();
    });
  }

  void _showUserDialog({Map<String, dynamic>? userData}) {
    final nameController = TextEditingController(text: userData?['name']);
    final emailController = TextEditingController(text: userData?['email']);
    final phoneController = TextEditingController(text: userData?['phone']);
    String selectedRole = userData?['role'] ?? 'user';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                items: ['user', 'worker', 'admin']
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedRole = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final data = {
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'role': selectedRole,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users & Workers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadUsers(),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appState.users.length,
              itemBuilder: (context, index) {
                final user = appState.users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isActive
                          ? AppTheme.deepGreen.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: user.isActive ? AppTheme.deepGreen : Colors.grey,
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.deepGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showUserDialog(userData: user.toJson());
                        } else if (value == 'delete') {
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
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<AppState>().deleteUser(
                                      user.id,
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: AppTheme.deepGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
