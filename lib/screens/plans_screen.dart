import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
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
      context.read<AppState>().loadAllConfigurations();
      context.read<AppState>().loadHotspotProfiles();
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
    dynamic selectedDataLimit;
    dynamic selectedValidity;
    dynamic selectedDeviceAllowed;
    String? selectedProfile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final appState = context.read<AppState>();
          
          return AlertDialog(
            title: Text('create_internet_plan'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'plan_name'.tr()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'price'.tr(),
                      prefixText: '${appState.currencySymbol} ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  // Data Limit Dropdown
                  DropdownButtonFormField<dynamic>(
                    value: selectedDataLimit,
                    decoration: InputDecoration(labelText: 'data_limit'.tr()),
                    items: appState.dataLimits.isEmpty
                        ? (HotspotConfigurationService.getDataLimits().isNotEmpty 
                            ? HotspotConfigurationService.getDataLimits().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()
                            : [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))])
                        : appState.dataLimits.map((limit) {
                            final label = limit is Map ? (limit['name'] ?? 'Unknown') : limit.toString();
                            return DropdownMenuItem(value: limit, child: Text(label));
                          }).toList(),
                    onChanged: (value) => setState(() => selectedDataLimit = value),
                  ),
                  const SizedBox(height: 12),
                  // Validity Dropdown
                  DropdownButtonFormField<dynamic>(
                    value: selectedValidity,
                    decoration: InputDecoration(labelText: 'validity'.tr()),
                    items: appState.validityPeriods.isEmpty
                        ? (HotspotConfigurationService.getValidityOptions().isNotEmpty
                            ? HotspotConfigurationService.getValidityOptions().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()
                            : [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))])
                        : appState.validityPeriods.map((validity) {
                            final label = validity is Map ? (validity['name'] ?? 'Unknown') : validity.toString();
                            return DropdownMenuItem(value: validity, child: Text(label));
                          }).toList(),
                    onChanged: (value) => setState(() => selectedValidity = value),
                  ),
                  const SizedBox(height: 12),
                  // Device Allowed Dropdown (Shared Users)
                  DropdownButtonFormField<dynamic>(
                    value: selectedDeviceAllowed,
                    decoration: InputDecoration(labelText: 'device_allowed'.tr()),
                    items: appState.sharedUsers.isEmpty
                        ? (HotspotConfigurationService.getDeviceAllowed().isNotEmpty
                            ? HotspotConfigurationService.getDeviceAllowed().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()
                            : [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))])
                        : appState.sharedUsers.map((user) {
                            final label = user is Map ? (user['name'] ?? 'Unknown') : user.toString();
                            return DropdownMenuItem(value: user, child: Text(label));
                          }).toList(),
                    onChanged: (value) => setState(() => selectedDeviceAllowed = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedProfile,
                    decoration: InputDecoration(labelText: 'hotspot_profile'.tr()),
                    items: appState.hotspotProfiles.isEmpty
                        ? [DropdownMenuItem(value: 'Basic', child: Text('Basic'))]
                        : appState.hotspotProfiles
                            .map((profile) => DropdownMenuItem(
                                  value: profile.id,
                                  child: Text(profile.name),
                                ))
                            .toList(),
                    onChanged: (value) => setState(() => selectedProfile = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.isEmpty || priceController.text.isEmpty ||
                      selectedDataLimit == null || selectedValidity == null ||
                      selectedDeviceAllowed == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('fill_all_fields'.tr())),
                    );
                    return;
                  }

                  // Helper to extract value from dynamic item (Map or String)
                  int extractValue(dynamic item) {
                    if (item is Map) {
                      return int.tryParse(item['value']?.toString() ?? '0') ?? 0;
                    } else if (item is String) {
                      return HotspotConfigurationService.extractNumericValue(item);
                    }
                    return 0;
                  }

                  final data = {
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'dataLimitGB': selectedDataLimit is String && HotspotConfigurationService.isUnlimited(selectedDataLimit)
                        ? 999999
                        : extractValue(selectedDataLimit),
                    'validityDays': extractValue(selectedValidity),
                    'deviceAllowed': extractValue(selectedDeviceAllowed),
                    'userProfile': selectedProfile,
                  };

                  context.read<AppState>().createPlan(data);
                  Navigator.pop(context);
                },
                child: Text('create'.tr()),
              ),
            ],
          );
        },
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
        title: Text(
          'internet_plans'.tr(),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
              hintText: 'search_plans'.tr(),
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
                                        appState.formatMoney(plan.price),
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPlanFeature(
                                    Icons.cloud_download,
                                    'data_limit'.tr(),
                                    '${plan.dataLimitGB} GB',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPlanFeature(
                                    Icons.devices,
                                    'device_allowed'.tr(),
                                    '${plan.deviceAllowed} ${'devices'.tr()}',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPlanFeature(
                                    Icons.calendar_month,
                                    'validity'.tr(),
                                    '${plan.validityDays} ${'days'.tr()}',
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
                                      label: Text('assign_to_user'.tr()),
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
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
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
