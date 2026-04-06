import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/network_provider.dart';
import '../providers/split/user_provider.dart';
import '../models/plan_model.dart';
import 'create_edit_plan_screen.dart';
import '../utils/permissions.dart';
import '../utils/permission_mapping.dart';
import '../widgets/permission_denied_dialog.dart';

class InternetPlansSettingsScreen extends StatefulWidget {
  const InternetPlansSettingsScreen({super.key});

  @override
  State<InternetPlansSettingsScreen> createState() => _InternetPlansSettingsScreenState();
}

class _InternetPlansSettingsScreenState extends State<InternetPlansSettingsScreen> {
  String _selectedRouter = 'all';
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final networkProvider = context.read<NetworkProvider>();
      networkProvider.loadPlans();
      networkProvider.loadAllConfigurations();
      networkProvider.loadHotspotProfiles();
    });
  }

  void _navigateToCreateEdit({PlanModel? plan}) {
    final user = context.read<UserProvider>().currentUser;
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
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditPlanScreen(planData: plan?.toJson()),
      ),
    ).then((_) {
      // Reload plans after returning from create/edit screen
      context.read<NetworkProvider>().loadPlans();
    });
  }

  void _showDeleteDialog(PlanModel plan) {
    final user = context.read<UserProvider>().currentUser;
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
                await context.read<NetworkProvider>().deletePlan(plan.slug);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('plan_deleted_successfully'.tr())),
                  );
                  // Reload plans after deletion
                  context.read<NetworkProvider>().loadPlans();
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
    final networkProvider = context.watch<NetworkProvider>();
    final userProvider = context.watch<UserProvider>();
    
    // Filter logic
    final plans = networkProvider.plans.where((plan) {
      final matchesSearch = _searchQuery.isEmpty || 
          plan.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRouter = _selectedRouter == 'all' || 
          plan.routers.any((r) => r.name == _selectedRouter);
      return matchesSearch && matchesRouter;
    }).toList();

    // Unique router names for filtering
    final allRouterNames = networkProvider.plans
        .expand((plan) => plan.routers.map((r) => r.name))
        .toSet()
        .toList()
      ..sort();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('internet_plans'.tr()),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Search
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'search_plans'.tr(),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                // Router Filter
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRouter,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black, fontSize: 13),
                        items: [
                          DropdownMenuItem(value: 'all', child: Text('all_routers'.tr())),
                          ...allRouterNames.map((name) => DropdownMenuItem(value: name, child: Text(name))),
                        ],
                        onChanged: (val) => setState(() => _selectedRouter = val ?? 'all'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: networkProvider.isLoading
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
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Left: Name and Price
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plan.priceDisplay,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Middle: Data and Validity
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    Icons.cloud_download_outlined,
                                    _getDataLimitLabel(plan.dataLimit, networkProvider),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildInfoRow(
                                    Icons.calendar_today_outlined,
                                    plan.formattedValidity,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Right: Actions
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _navigateToCreateEdit(plan: plan),
                                  icon: const Icon(Icons.edit_outlined),
                                  color: colorScheme.primary,
                                  tooltip: 'edit'.tr(),
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _showDeleteDialog(plan),
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  tooltip: 'delete'.tr(),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        userProvider.currentUser?.role ?? '',
        userProvider.currentUser?.permissions,
      )
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateEdit(),
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  String _getDataLimitLabel(int? dataLimitId, NetworkProvider networkProvider) {
    if (dataLimitId == null) return 'Unlimited';
    
    // Find the configuration with this ID
    try {
      final config = networkProvider.dataLimits.firstWhere(
        (limit) => limit is Map && limit['id'] == dataLimitId,
        orElse: () => null,
      );
      
      if (config != null) {
        if (config['gb'] != null) return '${config['gb']} GB';
        if (config['value'] != null) return config['value'].toString();
        if (config['limit'] != null) return config['limit'].toString();
      }
    } catch (e) {
      // Ignore error and fallback
    }
    
    // Fallback if not found (might be legacy value or just the ID)
    return '$dataLimitId GB'; 
  }
}
