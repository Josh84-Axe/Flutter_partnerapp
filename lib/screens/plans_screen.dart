import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/split/network_provider.dart';
import '../providers/split/user_provider.dart';
import '../providers/split/auth_provider.dart';
import 'create_edit_plan_screen.dart';

class PlansScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const PlansScreen({super.key, this.onBack});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRouter = 'all'; // Filter state

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = userProvider.currentUser;
    final allPlans = networkProvider.getPlansForUser(user?.role, user?.assignedRouters);
    final filteredPlans = allPlans.where((plan) {
      // Apply Search filter
      bool matchesSearch = _searchQuery.isEmpty || 
          plan.name.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply Router filter
      bool matchesRouter = _selectedRouter == 'all' || 
          plan.routers.any((r) => r.name == _selectedRouter);
          
      return matchesSearch && matchesRouter;
    }).toList();

    // Group unique router names for filter dropdown
    final allRouterNames = networkProvider.plans
        .expand((plan) => plan.routers.map((r) => r.name))
        .toSet()
        .toList()
      ..sort();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('internet_plans'.tr()),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final networkProvider = context.read<NetworkProvider>();
              networkProvider.loadPlans();
              networkProvider.loadAllConfigurations();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'search_plans'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 8),
                // Router Dropdown
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRouter,
                        isExpanded: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
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
          const SizedBox(height: 8),

          // Plans List
          Expanded(
            child: networkProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPlans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off, size: 64, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              'no_plans_found'.tr(),
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredPlans.length,
                        itemBuilder: (context, index) {
                          final plan = filteredPlans[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: isDark ? colorScheme.surfaceContainer : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Plan name and price
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plan.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${plan.price} ${userProvider.currencyCode}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Info chips
                                  _buildInfoChip(
                                    context,
                                    Icons.cloud_download,
                                    'Data Limit',
                                    _getDataLimitLabel(plan.dataLimit, networkProvider),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoChip(
                                    context,
                                    Icons.devices,
                                    'Device Allowed',
                                    plan.sharedUsersLabel,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoChip(
                                    context,
                                    Icons.calendar_month,
                                    'Validity',
                                    plan.formattedValidity,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Actions row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                              '/assign-user',
                                              arguments: {'planId': plan.id.toString(), 'planName': plan.name},
                                            );
                                          },
                                          icon: const Icon(Icons.person_add, size: 18),
                                          label: Text('assign'.tr()),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: colorScheme.primary,
                                            foregroundColor: colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Opacity(
                                          opacity: authProvider.currentUser?.isVoucherEnabled == true ? 1.0 : 0.5,
                                          child: OutlinedButton.icon(
                                            onPressed: authProvider.currentUser?.isVoucherEnabled == true 
                                              ? () {
                                                Navigator.of(context).pushNamed(
                                                  '/vouchers',
                                                  arguments: {'planId': plan.id.toString(), 'planName': plan.name},
                                                );
                                              }
                                              : null,
                                            icon: const Icon(Icons.vpn_key, size: 18),
                                            label: Text('vouchers'.tr()),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              side: BorderSide(
                                                color: authProvider.currentUser?.isVoucherEnabled == true 
                                                  ? colorScheme.primary 
                                                  : colorScheme.outline,
                                              ),
                                            ),
                                          ),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditPlan(null),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToEditPlan(Map<String, dynamic>? planData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditPlanScreen(planData: planData),
      ),
    ).then((_) {
      if (!mounted) return;
      // Reload plans after returning fromcreate/edit screen
      context.read<NetworkProvider>().loadPlans();
    });
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


