import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadPlans();
    });
  }

  void _showCreatePlanDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final dataController = TextEditingController();
    final validityController = TextEditingController();
    final speedController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Internet Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dataController,
                decoration: const InputDecoration(
                  labelText: 'Data Limit (GB)',
                  suffixText: 'GB',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: validityController,
                decoration: const InputDecoration(
                  labelText: 'Validity (Days)',
                  suffixText: 'days',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: speedController,
                decoration: const InputDecoration(
                  labelText: 'Speed (Mbps)',
                  suffixText: 'Mbps',
                ),
                keyboardType: TextInputType.number,
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
                'price': double.parse(priceController.text),
                'dataLimitGB': int.parse(dataController.text),
                'validityDays': int.parse(validityController.text),
                'speedMbps': int.parse(speedController.text),
              };

              context.read<AppState>().createPlan(data);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAssignPlanDialog(String planId, String planName) {
    final appState = context.read<AppState>();
    String? selectedUserId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign $planName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a user to assign this plan:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUserId,
                decoration: const InputDecoration(labelText: 'User'),
                items: appState.users
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text(user.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserId = value;
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
            ElevatedButton(
              onPressed: selectedUserId == null
                  ? null
                  : () {
                      appState.assignPlan(selectedUserId!, planId);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plan assigned successfully'),
                        ),
                      );
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.loadPlans(),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appState.plans.length,
              itemBuilder: (context, index) {
                final plan = appState.plans[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              MetricCard.formatCurrency(plan.price),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppTheme.deepGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.data_usage,
                              size: 16,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(width: 8),
                            Text('${plan.dataLimitGB} GB'),
                            const SizedBox(width: 24),
                            Icon(
                              Icons.speed,
                              size: 16,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(width: 8),
                            Text('${plan.speedMbps} Mbps'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.textLight,
                            ),
                            const SizedBox(width: 8),
                            Text('${plan.validityDays} days'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showAssignPlanDialog(plan.id, plan.name),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Assign to User'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        backgroundColor: AppTheme.deepGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
