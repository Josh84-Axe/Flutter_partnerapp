import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import 'create_edit_plan_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadPlans();
      context.read<AppState>().loadAllConfigurations();
      context.read<AppState>().loadHotspotProfiles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filteredPlans = appState.plans.where((plan) {
      if (_searchQuery.isEmpty) return true;
      return plan.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('internet_plans'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              appState.loadPlans();
              appState.loadAllConfigurations();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_plans'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Plans List
          Expanded(
            child: appState.isLoading
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
                                        '${plan.price} ${appState.currencyCode}',
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
                                    _getDataLimitLabel(plan.dataLimit, appState),
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
                                  
                                  // Assign button
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          '/assign-user',
                                          arguments: {'planId': plan.id.toString(), 'planName': plan.name},
                                        );
                                      },
                                      icon: const Icon(Icons.person_add, size: 18),
                                      label: Text('assign_to_user'.tr()),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
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
      context.read<AppState>().loadPlans();
    });
  }

  String _getDataLimitLabel(int? dataLimitId, AppState appState) {
    if (dataLimitId == null) return 'Unlimited';
    
    // Find the configuration with this ID
    try {
      final config = appState.dataLimits.firstWhere(
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


