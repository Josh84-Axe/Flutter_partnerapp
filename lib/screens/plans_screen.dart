import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/search_bar_widget.dart';

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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreatePlanDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final dataController = TextEditingController();
    final validityController = TextEditingController();
    final speedController = TextEditingController();
    final deviceController = TextEditingController(text: '1');
    String selectedProfile = 'Basic';

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
              const SizedBox(height: 12),
              TextField(
                controller: deviceController,
                decoration: const InputDecoration(
                  labelText: 'Device Allowed',
                  suffixText: 'devices',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedProfile,
                decoration: const InputDecoration(
                  labelText: 'User Profile (Predefined)',
                ),
                items: ['Basic', 'Standard', 'Premium', 'Ultra']
                    .map((profile) => DropdownMenuItem(
                          value: profile,
                          child: Text(profile),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedProfile = value!;
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
          ElevatedButton(
            onPressed: () {
              final data = {
                'name': nameController.text,
                'price': double.parse(priceController.text),
                'dataLimitGB': int.parse(dataController.text),
                'validityDays': int.parse(validityController.text),
                'speedMbps': int.parse(speedController.text),
                'deviceAllowed': int.parse(deviceController.text),
                'userProfile': selectedProfile,
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
                    .map((user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.name),
                        ))
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
                        const SnackBar(content: Text('Plan assigned successfully')),
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
    final filteredPlans = appState.plans.where((plan) {
      if (_searchQuery.isEmpty) return true;
      return plan.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'Search plans...',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
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
                              'No plans found',
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
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plan.name,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        MetricCard.formatCurrency(plan.price),
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPlanFeature(
                                    Icons.cloud_download,
                                    'Data Limit',
                                    '${plan.dataLimitGB} GB',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPlanFeature(
                                    Icons.speed,
                                    'Speed',
                                    '${plan.speedMbps} Mbps',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPlanFeature(
                                    Icons.calendar_month,
                                    'Validity',
                                    '${plan.validityDays} days',
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showAssignPlanDialog(plan.id, plan.name),
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Assign to User'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
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
        onPressed: _showCreatePlanDialog,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlanFeature(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
