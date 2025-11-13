import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class CollaboratorsManagementScreen extends StatefulWidget {
  const CollaboratorsManagementScreen({super.key});

  @override
  State<CollaboratorsManagementScreen> createState() => _CollaboratorsManagementScreenState();
}

class _CollaboratorsManagementScreenState extends State<CollaboratorsManagementScreen> {
  bool _isLoading = false;
  List<dynamic> _collaborators = [];
  List<dynamic> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appState = context.read<AppState>();
      final collaborators = await appState.collaboratorRepository.fetchCollaborators();
      final roles = await appState.collaboratorRepository.fetchRoles();
      
      if (mounted) {
        setState(() {
          _collaborators = collaborators;
          _roles = roles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_loading_collaborators'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCreateCollaboratorDialog() async {
    final emailController = TextEditingController();
    final usernameController = TextEditingController();
    String? selectedRole;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('add_collaborator'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'email'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'username'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'role'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role['slug'],
                      child: Text(role['name'] ?? role['slug']),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('add'.tr()),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    try {
      final appState = context.read<AppState>();
      await appState.collaboratorRepository.createCollaborator({
        'email': emailController.text,
        'username': usernameController.text,
        'role': selectedRole,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('collaborator_added_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_adding_collaborator'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCollaborator(String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_collaborator'.tr()),
        content: Text('delete_collaborator_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final appState = context.read<AppState>();
      final success = await appState.collaboratorRepository.deleteCollaborator(username);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('collaborator_deleted_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_deleting_collaborator'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('collaborators'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collaborators.isEmpty
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
                        'no_collaborators'.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'no_collaborators_desc'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textLight,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _collaborators.length,
                    itemBuilder: (context, index) {
                      final collaborator = _collaborators[index];
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
                          title: Text(
                            collaborator['username'] ?? 'unknown_user'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(collaborator['email'] ?? 'N/A'),
                              Text('${'role'.tr()}: ${collaborator['role'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () => _deleteCollaborator(collaborator['username'] ?? ''),
                            tooltip: 'delete'.tr(),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCollaboratorDialog,
        icon: const Icon(Icons.person_add),
        label: Text('add_collaborator'.tr()),
        backgroundColor: colorScheme.primary,
      ),
    );
  }
}
