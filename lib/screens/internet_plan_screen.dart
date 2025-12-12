import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../models/plan_model.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadPlans();
    });
  }

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
    ).then((_) {
      // Reload plans after returning from create/edit screen
      context.read<AppState>().loadPlans();
    });
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
                await context.read<AppState>().deletePlan(plan.slug);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('plan_deleted_successfully'.tr())),
                  );
                  // Reload plans after deletion
                  context.read<AppState>().loadPlans();
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
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
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
    final partnerCountry = appState.currentUser?.country;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('internet_plans'.tr()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'no_plans_found'.tr(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${plan.dataLimit != null ? '${plan.dataLimit} GB' : 'unlimited'.tr()} | ${plan.formattedValidity}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  plan.priceDisplay,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (Permissions.canEditPlans(
                                appState.currentUser?.role ?? '',
                                appState.currentUser?.permissions,
                              ))
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7FD99A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () => _navigateToCreateEdit(plan: plan),
                                    icon: const Icon(Icons.edit, size: 20),
                                    color: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              if (Permissions.canEditPlans(
                                appState.currentUser?.role ?? '',
                                appState.currentUser?.permissions,
                              ) && Permissions.canDeletePlans(
                                appState.currentUser?.role ?? '',
                                appState.currentUser?.permissions,
                              ))
                                const SizedBox(width: 12),
                              if (Permissions.canDeletePlans(
                                appState.currentUser?.role ?? '',
                                appState.currentUser?.permissions,
                              ))
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFCDD2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () => _showDeleteDialog(plan),
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: Color(0xFFD32F2F),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: Permissions.canCreatePlans(
        appState.currentUser?.role ?? '',
        appState.currentUser?.permissions,
      )
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7FD99A).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _navigateToCreateEdit(),
                backgroundColor: const Color(0xFF7FD99A),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'new_plan'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                elevation: 0,
              ),
            )
          : null,
    );
  }
}
