import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_state.dart';

class DataLimitConfigScreen extends StatefulWidget {
  const DataLimitConfigScreen({super.key});

  @override
  State<DataLimitConfigScreen> createState() => _DataLimitConfigScreenState();
}

class _DataLimitConfigScreenState extends State<DataLimitConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadAllConfigurations();
    });
  }

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Data Limit'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Data Limit Value',
                  hintText: 'e.g., 10GB',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a data limit value';
                  }
                  return null;
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
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await context.read<AppState>().createDataLimit({
                    'value': valueController.text,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data limit added')),
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
    final value = item['value']?.toString() ?? 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete "$value"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<AppState>().deleteDataLimit(id);
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
    final formKey = GlobalKey<FormState>();
    final id = item['id'] as int;
    final currentValue = item['value']?.toString() ?? '';
    final valueController = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Data Limit'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Data Limit Value',
                  hintText: 'e.g., 10GB',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a data limit value';
                  }
                  return null;
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
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await context.read<AppState>().updateDataLimit(id, {
                    'value': valueController.text,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data limit updated')),
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
    final appState = context.watch<AppState>();
    final configs = appState.dataLimits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Limit Configuration'),
      ),
      body: Column(
        children: [
          Expanded(
            child: appState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : configs.isEmpty
                    ? const Center(child: Text('No data limits configured'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: configs.length,
                        itemBuilder: (context, index) {
                          final config = configs[index];
                          final value = config['value']?.toString() ?? 'Unknown';
                          
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
                                          value,
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
                  label: const Text('Add New Data Limit'),
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
