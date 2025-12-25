import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/split/network_provider.dart';
import '../../utils/app_theme.dart';

class PlanValidityConfigScreen extends StatefulWidget {
  const PlanValidityConfigScreen({super.key});

  @override
  State<PlanValidityConfigScreen> createState() => _PlanValidityConfigScreenState();
}

class _PlanValidityConfigScreenState extends State<PlanValidityConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkProvider>().loadAllConfigurations();
    });
  }

  void _showAddDialog() {
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Validity Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Validity Period',
                hintText: 'e.g., 1d or 30m',
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
              if (valueController.text.isNotEmpty) {
                try {
                  await context.read<NetworkProvider>().createValidityPeriod({
                    'value': valueController.text,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Validity period added')),
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
                await context.read<NetworkProvider>().deleteValidityPeriod(id);
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
    final valueController = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Validity Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Validity Period',
                hintText: 'e.g., 1d or 30m',
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
              if (valueController.text.isNotEmpty) {
                try {
                  await context.read<NetworkProvider>().updateValidityPeriod(id, {
                    'value': valueController.text,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Validity period updated')),
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
    final validityPeriods = networkProvider.validityPeriods;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Validity Configuration'),
      ),
      body: Column(
        children: [
          Expanded(
            child: networkProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : validityPeriods.isEmpty
                    ? const Center(child: Text('No validity periods configured'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: validityPeriods.length,
                        itemBuilder: (context, index) {
                          final config = validityPeriods[index];
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
                  label: const Text('Add New Validity Period'),
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
