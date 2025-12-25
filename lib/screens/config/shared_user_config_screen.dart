import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/split/network_provider.dart';

class SharedUserConfigScreen extends StatefulWidget {
  const SharedUserConfigScreen({super.key});

  @override
  State<SharedUserConfigScreen> createState() => _SharedUserConfigScreenState();
}

class _SharedUserConfigScreenState extends State<SharedUserConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkProvider>().loadAllConfigurations();
    });
  }

  void _showAddDialog() {
    final valueController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Shared Users Config'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Number of Users',
                hintText: 'e.g., 3',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., 3 users',
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
            onPressed: () async {
              if (valueController.text.isNotEmpty && labelController.text.isNotEmpty) {
                try {
                  await context.read<NetworkProvider>().createSharedUsersConfig({
                    'value': int.tryParse(valueController.text) ?? 1,
                    'label': labelController.text,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shared users config added')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic item) {
    final id = item['id'] as int;
    final label = item['label']?.toString() ?? item['value']?.toString() ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete "$label"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<NetworkProvider>().deleteSharedUsersConfig(id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
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

  void _showEditDialog(dynamic item) {
    final id = item['id'] as int;
    final currentValue = item['value']?.toString() ?? '';
    final currentLabel = item['label']?.toString() ?? '';
    
    final valueController = TextEditingController(text: currentValue);
    final labelController = TextEditingController(text: currentLabel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Shared Users Config'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Number of Users',
                hintText: 'e.g., 3',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., 3 users',
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
            onPressed: () async {
              if (valueController.text.isNotEmpty && labelController.text.isNotEmpty) {
                try {
                  await context.read<NetworkProvider>().updateSharedUsersConfig(id, {
                    'value': int.tryParse(valueController.text) ?? 1,
                    'label': labelController.text,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shared users config updated')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final networkProvider = context.watch<NetworkProvider>();
    final configs = networkProvider.sharedUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Users Configuration'),
      ),
      body: Column(
        children: [
          Expanded(
            child: networkProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : configs.isEmpty
                    ? const Center(child: Text('No shared users configs'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: configs.length,
                        itemBuilder: (context, index) {
                          final config = configs[index];
                          final label = config['label']?.toString() ?? '${config['value']} users';
                          
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
                                          label,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _showEditDialog(config),
                                    icon: const Icon(Icons.edit),
                                    color: colorScheme.primary,
                                  ),
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
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Shared Users Config'),
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
