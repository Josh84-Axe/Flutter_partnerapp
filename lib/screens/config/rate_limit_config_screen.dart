import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/config_item_model.dart';

class RateLimitConfigScreen extends StatefulWidget {
  const RateLimitConfigScreen({super.key});

  @override
  State<RateLimitConfigScreen> createState() => _RateLimitConfigScreenState();
}

class _RateLimitConfigScreenState extends State<RateLimitConfigScreen> {
  final List<ConfigItem> _configs = [
    ConfigItem(
      id: '1',
      name: 'Basic Speed',
      description: '10 Mbps',
    ),
    ConfigItem(
      id: '2',
      name: 'Standard Speed',
      description: '50 Mbps',
    ),
    ConfigItem(
      id: '3',
      name: 'Premium Speed',
      description: '100 Mbps',
    ),
  ];

  void _showAddEditDialog({ConfigItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final isEdit = item != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Rate Limit' : 'Add New Rate Limit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Setting Name',
                hintText: 'e.g., Basic Speed',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Speed Limit',
                hintText: 'e.g., 10 Mbps',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Limit Configuration'),
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
                                foregroundColor: AppTheme.primaryGreen,
                                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
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
                  label: const Text('Add New Rate Limit'),
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
