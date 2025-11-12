import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../models/plan_model.dart';
import '../utils/app_theme.dart';

class InternetPlanScreen extends StatefulWidget {
  const InternetPlanScreen({super.key});

  @override
  State<InternetPlanScreen> createState() => _InternetPlanScreenState();
}

class _InternetPlanScreenState extends State<InternetPlanScreen> {
  void _navigateToCreateEdit({PlanModel? plan}) {
    Navigator.of(context).pushNamed(
      '/create-edit-plan',
      arguments: plan?.toJson(),
    );
  }

  void _showDeleteDialog(PlanModel plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_plan'.tr()),
        content: Text('delete_plan_confirm'.tr(namedArgs: {'name': plan.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('plan_deleted_successfully'.tr())),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final plans = appState.plans;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('internet_plans'.tr()),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${plan.dataLimitGB} GB | ${plan.speedMbps} Mbps | ${plan.validityDays} days',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${plan.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _navigateToCreateEdit(plan: plan),
                            icon: const Icon(Icons.edit),
                            style: IconButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              backgroundColor: colorScheme.primaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showDeleteDialog(plan),
                            icon: const Icon(Icons.delete),
                            style: IconButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              backgroundColor: colorScheme.errorContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateEdit(),
        icon: const Icon(Icons.add),
        label: Text('new_plan'.tr()),
      ),
    );
  }
}
