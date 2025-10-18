import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../utils/currency_helper.dart';
import '../services/hotspot_configuration_service.dart';
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
    String? selectedDataLimit;
    String? selectedValidity;
    String? selectedSpeed;
    String? selectedDeviceAllowed;
    String selectedProfile = 'Basic';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '${CurrencyHelper.getCurrencySymbol(
                      CurrencyHelper.getCurrencyCode(context.read<AppState>().currentUser?.country)
                    )} ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDataLimit,
                  decoration: const InputDecoration(labelText: 'Data Limit'),
                  items: HotspotConfigurationService.getDataLimits().isEmpty
                      ? [const DropdownMenuItem(value: null, child: Text('No options configured'))]
                      : HotspotConfigurationService.getDataLimits()
                          .map((limit) => DropdownMenuItem(value: limit, child: Text(limit)))
                          .toList(),
                  onChanged: HotspotConfigurationService.getDataLimits().isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            selectedDataLimit = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedValidity,
                  decoration: const InputDecoration(labelText: 'Validity'),
                  items: HotspotConfigurationService.getValidityOptions().isEmpty
                      ? [const DropdownMenuItem(value: null, child: Text('No options configured'))]
                      : HotspotConfigurationService.getValidityOptions()
                          .map((validity) => DropdownMenuItem(value: validity, child: Text(validity)))
                          .toList(),
                  onChanged: HotspotConfigurationService.getValidityOptions().isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            selectedValidity = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSpeed,
                  decoration: const InputDecoration(labelText: 'Speed'),
                  items: HotspotConfigurationService.getSpeedOptions().isEmpty
                      ? [const DropdownMenuItem(value: null, child: Text('No options configured'))]
                      : HotspotConfigurationService.getSpeedOptions()
                          .map((speed) => DropdownMenuItem(value: speed, child: Text(speed)))
                          .toList(),
                  onChanged: HotspotConfigurationService.getSpeedOptions().isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            selectedSpeed = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDeviceAllowed,
                  decoration: const InputDecoration(labelText: 'Device Allowed'),
                  items: HotspotConfigurationService.getDeviceAllowed().isEmpty
                      ? [const DropdownMenuItem(value: null, child: Text('No options configured'))]
                      : HotspotConfigurationService.getDeviceAllowed()
                          .map((device) => DropdownMenuItem(value: device, child: Text(device)))
                          .toList(),
                  onChanged: HotspotConfigurationService.getDeviceAllowed().isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            selectedDeviceAllowed = value;
                          });
                        },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedProfile,
                  decoration: const InputDecoration(labelText: 'User Profile'),
                  items: HotspotConfigurationService.getUserProfiles()
                      .map((profile) => DropdownMenuItem(value: profile, child: Text(profile)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProfile = value!;
                    });
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
            FilledButton(
              onPressed: () {
                if (nameController.text.isEmpty || priceController.text.isEmpty ||
                    selectedDataLimit == null || selectedValidity == null ||
                    selectedSpeed == null || selectedDeviceAllowed == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final data = {
                  'name': nameController.text,
                  'price': double.parse(priceController.text),
                  'dataLimitGB': HotspotConfigurationService.isUnlimited(selectedDataLimit!)
                      ? 999999
                      : HotspotConfigurationService.extractNumericValue(selectedDataLimit!),
                  'validityDays': HotspotConfigurationService.extractNumericValue(selectedValidity!),
                  'speedMbps': HotspotConfigurationService.extractNumericValue(selectedSpeed!),
                  'deviceAllowed': HotspotConfigurationService.extractNumericValue(selectedDeviceAllowed!),
                  'userProfile': selectedProfile,
                };

                context.read<AppState>().createPlan(data);
                Navigator.pop(context);
              },
              child: const Text('Create'),
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
                                    child: FilledButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          '/assign-user',
                                          arguments: {'planId': plan.id, 'planName': plan.name},
                                        );
                                      },
                                      icon: const Icon(Icons.person_add),
                                      label: const Text('Assign to User'),
                                      style: FilledButton.styleFrom(
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
