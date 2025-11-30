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

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                fillColor: Colors.white,
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
                            color: Colors.white,
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
                                        plan.priceDisplay,
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
                                    Icons.cloud_download,
                                    'Data Limit',
                                    plan.dataLimit != null ? '${plan.dataLimit} GB' : 'Unlimited',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoChip(
                                    Icons.devices,
                                    'Device Allowed',
                                    plan.sharedUsersLabel,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoChip(
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
                                        backgroundColor: const Color(0xFF2D5F3F),
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
        backgroundColor: const Color(0xFF7FD99A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF7FD99A).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7FD99A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
      // Reload plans after returning from create/edit screen
      context.read<AppState>().loadPlans();
    });
  }
}


