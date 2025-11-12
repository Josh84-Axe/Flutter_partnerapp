import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/config_item_model.dart';

class SharedUserConfigScreen extends StatefulWidget {
  const SharedUserConfigScreen({super.key});

  @override
  State<SharedUserConfigScreen> createState() => _SharedUserConfigScreenState();
}

class _SharedUserConfigScreenState extends State<SharedUserConfigScreen> {
  final List<ConfigItem> _configs = [
    ConfigItem(
      id: '1',
      name: 'Single User',
      description: '1 Shared User',
    ),
    ConfigItem(
      id: '2',
      name: 'Family Plan',
      description: '5 Shared Users',
    ),
    ConfigItem(
      id: '3',
      name: 'Small Business',
      description: '10 Shared Users',
    ),
  ];

  void _showAddEditDialog({ConfigItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final isEdit = item != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Shared User' : 'Add New Shared User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Setting Name',
                hintText: 'e.g., Family Plan',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Number of Users',
                hintText: 'e.g., 5 Shared Users',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && descController.text.isNotEmpty) {
                setState(() {
                  if (isEdit) {
                    final index = _configs.indexWhere((c) => c.id == item.id);
                    _configs[index] = ConfigItem(
                      id: item.id,
                      name: nameController.text,
                      description: descController.text,
                    );
                  } else {
                    _configs.add(ConfigItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      description: descController.text,
                    ));
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Configuration updated' : 'Configuration added')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ConfigItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _configs.removeWhere((c) => c.id == item.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared User Configuration'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _configs.length,
              itemBuilder: (context, index) {
                final config = _configs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                config.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showAddEditDialog(item: config),
                              icon: const Icon(Icons.edit),
                              style: IconButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _showDeleteDialog(config),
                              icon: const Icon(Icons.delete),
                              style: IconButton.styleFrom(
                                foregroundColor: AppTheme.errorRed,
                                backgroundColor: AppTheme.errorRed.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
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
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Setting'),
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
