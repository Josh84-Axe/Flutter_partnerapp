import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../models/plan_model.dart';
import '../utils/app_theme.dart';
import '../utils/currency_utils.dart';
import '../utils/permissions.dart';
import '../utils/permission_mapping.dart';
import '../widgets/permission_denied_dialog.dart';

class InternetPlanScreen extends StatefulWidget {
  const InternetPlanScreen({super.key});

  @override
  State<InternetPlanScreen> createState() => _InternetPlanScreenState();
}

class _InternetPlanScreenState extends State<InternetPlanScreen> {
  void _navigateToCreateEdit({PlanModel? plan}) {
    final user = context.read<AppState>().currentUser;
    if (user == null) return;
    
    // Check permission based on whether creating or editing
    final hasPermission = plan == null
        ? Permissions.canCreatePlans(user.role, user.permissions)
        : Permissions.canEditPlans(user.role, user.permissions);
    
    if (!hasPermission) {
      PermissionDeniedDialog.show(
        context,
        requiredPermission: plan == null 
            ? PermissionConstants.createPlans 
            : PermissionConstants.editPlans,
      );
      return;
    }
    
    Navigator.of(context).pushNamed(
      '/create-edit-plan',
      arguments: plan?.toJson(),
    );
  }

  void _showDeleteDialog(PlanModel plan) {
    final user = context.read<AppState>().currentUser;
    if (user == null) return;
    
    if (!Permissions.canDeletePlans(user.role, user.permissions)) {
      PermissionDeniedDialog.show(
        context,
        requiredPermission: PermissionConstants.deletePlans,
      );
      return;
    }
    
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<AppState>().deletePlan(plan.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('plan_deleted_successfully'.tr())),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('error_deleting_plan'.tr())),
                  );
                }
              }
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
    final partnerCountry = appState.currentUser?.country;

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                        const SizedBox(height: 4),
                        Text(
                          '${plan.dataLimitGB} GB | ${plan.speedMbps} Mbps | ${plan.validityDays} days',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.formatPrice(plan.price, partnerCountry),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (Permissions.canEditPlans(
                        appState.currentUser?.role ?? '',
                        appState.currentUser?.permissions,
                      ))
                        IconButton(
                          onPressed: () => _navigateToCreateEdit(plan: plan),
                          icon: const Icon(Icons.edit, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF7FD99A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      if (Permissions.canEditPlans(
                        appState.currentUser?.role ?? '',
                        appState.currentUser?.permissions,
                      ) && Permissions.canDeletePlans(
                        appState.currentUser?.role ?? '',
                        appState.currentUser?.permissions,
                      ))
                        const SizedBox(width: 8),
                      if (Permissions.canDeletePlans(
                        appState.currentUser?.role ?? '',
                        appState.currentUser?.permissions,
                      ))
                        IconButton(
                          onPressed: () => _showDeleteDialog(plan),
                          icon: const Icon(Icons.delete, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.all(12),
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
      floatingActionButton: Permissions.canCreatePlans(
        appState.currentUser?.role ?? '',
        appState.currentUser?.permissions,
      )
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateEdit(),
              backgroundColor: const Color(0xFF7FD99A),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
