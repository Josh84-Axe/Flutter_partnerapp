import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../services/hotspot_configuration_service.dart';

class CreateEditInternetPlanScreen extends StatefulWidget {
  final Map<String, dynamic>? planData;

  const CreateEditInternetPlanScreen({super.key, this.planData});

  @override
  State<CreateEditInternetPlanScreen> createState() => _CreateEditInternetPlanScreenState();
}

class _CreateEditInternetPlanScreenState extends State<CreateEditInternetPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedValidity;
  String? _selectedDataLimit;
  String? _selectedAdditionalDevices;
  String? _selectedHotspotProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadAllConfigurations();
      context.read<AppState>().loadHotspotProfiles();
    });
    
    if (widget.planData != null) {
      _nameController.text = widget.planData!['name'] ?? '';
      _priceController.text = widget.planData!['price']?.toString() ?? '';
      // Use correct field names from PlanModel.toJson()
      _selectedValidity = widget.planData!['validityDays'];
      _selectedDataLimit = widget.planData!['dataLimitGB'];
      _selectedAdditionalDevices = widget.planData!['deviceAllowed'];
      _selectedHotspotProfile = widget.planData!['userProfile'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isEdit = widget.planData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_internet_plan'.tr() : 'create_internet_plan'.tr()),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'plan_name'.tr(),
                      hintText: 'plan_name_hint'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Plan name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'price'.tr(),
                      hintText: 'price_hint'.tr(),
                      border: const OutlineInputBorder(),
                      prefixText: '${appState.currencySymbol} ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<dynamic>(
                    value: _selectedValidity,
                    decoration: InputDecoration(
                      labelText: 'validity'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: appState.validityPeriods.isEmpty
                        ? (HotspotConfigurationService.getValidityOptions().isNotEmpty
                            ? HotspotConfigurationService.getValidityOptions().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()
                            : [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))])
                        : appState.validityPeriods
                            .map((v) {
                              final label = v is Map ? (v['name'] ?? 'Unknown') : v.toString();
                              return DropdownMenuItem(value: v, child: Text(label));
                            })
                            .toList(),
                    onChanged: (value) => setState(() => _selectedValidity = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a validity period';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<dynamic>(
                    value: _selectedDataLimit,
                    decoration: InputDecoration(
                      labelText: 'data_limit'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: appState.dataLimits.isEmpty
                        ? (HotspotConfigurationService.getDataLimits().isNotEmpty
                            ? HotspotConfigurationService.getDataLimits().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()
                            : [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))])
                        : appState.dataLimits
                            .map((d) {
                              final label = d is Map ? (d['name'] ?? 'Unknown') : d.toString();
                              return DropdownMenuItem(value: d, child: Text(label));
                            })
                            .toList(),
                    onChanged: (value) => setState(() => _selectedDataLimit = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a data limit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<dynamic>(
                    value: _selectedAdditionalDevices,
                    decoration: InputDecoration(
                      labelText: 'additional_devices_allowed'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: appState.sharedUsers.isEmpty
                        ? (HotspotConfigurationService.getDeviceAllowed().isNotEmpty
                            ? HotspotConfigurationService.getDeviceAllowed().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()
                            : [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))])
                        : appState.sharedUsers
                            .map((d) {
                              final label = d is Map ? (d['name'] ?? 'Unknown') : d.toString();
                              return DropdownMenuItem(value: d, child: Text(label));
                            })
                            .toList(),
                    onChanged: (value) => setState(() => _selectedAdditionalDevices = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select additional devices';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedHotspotProfile,
                    decoration: InputDecoration(
                      labelText: 'hotspot_user_profile'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: appState.hotspotProfiles.isEmpty
                        ? [DropdownMenuItem<String>(value: null, child: Text('no_profiles_configured'.tr()))]
                        : appState.hotspotProfiles
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                            .toList(),
                    onChanged: (value) => setState(() => _selectedHotspotProfile = value),
                  ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _savePlan,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEdit ? 'update_plan'.tr() : 'create_plan'.tr()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _savePlan() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Helper to extract value from dynamic item (Map or String)
    int extractValue(dynamic item, String context) {
      if (kDebugMode) print('🔍 [CreatePlan] Extracting value from $context: $item (type: ${item.runtimeType})');
      
      if (item is Map) {
        // Try multiple possible field names
        final value = int.tryParse(
          item['value']?.toString() ?? 
          item['days']?.toString() ?? 
          item['gb']?.toString() ?? 
          item['count']?.toString() ?? 
          item['limit']?.toString() ??
          '0'
        ) ?? 0;
        if (kDebugMode) print('   Extracted from Map: $value');
        return value;
      } else if (item is String) {
        final value = HotspotConfigurationService.extractNumericValue(item);
        if (kDebugMode) print('   Extracted from String: $value');
        return value;
      } else if (item is int) {
        if (kDebugMode) print('   Direct int value: $item');
        return item;
      }
      
      if (kDebugMode) print('   ⚠️ Could not extract value, returning 0');
      return 0;
    }

    // Get profile name from selected profile ID
    String getProfileName(String? profileId) {
      if (profileId == null) return 'Basic';
      final appState = context.read<AppState>();
      
      // Check if profiles list is empty
      if (appState.hotspotProfiles.isEmpty) {
        if (kDebugMode) print('⚠️ [CreatePlan] No hotspot profiles loaded, using "Basic"');
        return 'Basic';
      }
      
      // Find the profile by ID
      try {
        final profile = appState.hotspotProfiles.firstWhere(
          (p) => p.id == profileId,
        );
        if (kDebugMode) print('✅ [CreatePlan] Found profile: ${profile.name}');
        return profile.name;
      } catch (e) {
        // Profile not found, return first profile name or 'Basic'
        if (kDebugMode) print('⚠️ [CreatePlan] Profile not found, using first available or "Basic"');
        return appState.hotspotProfiles.isNotEmpty ? appState.hotspotProfiles.first.name : 'Basic';
      }
    }

    // Extract values with context for debugging
    final dataLimitValue = _selectedDataLimit is String && HotspotConfigurationService.isUnlimited(_selectedDataLimit as String)
        ? 999999
        : extractValue(_selectedDataLimit, 'data_limit');
    
    final validityDays = extractValue(_selectedValidity, 'validity');
    final validityMinutes = validityDays * 1440; // Convert days to minutes
    
    final sharedUsersValue = extractValue(_selectedAdditionalDevices, 'shared_users');

    // Prepare data with correct API field names
    final data = {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'data_limit': dataLimitValue,
      'validity': validityMinutes,
      'is_active': true,
      'shared_users': sharedUsersValue,
      'profile': _selectedHotspotProfile ?? 'Basic',
      'profile_name': getProfileName(_selectedHotspotProfile),
    };

    if (kDebugMode) {
      print('📦 [CreatePlan] Prepared plan data:');
      print('   Name: ${data['name']}');
      print('   Price: ${data['price']}');
      print('   Data Limit: ${data['data_limit']} GB');
      print('   Validity: ${data['validity']} minutes ($validityDays days)');
      print('   Shared Users: ${data['shared_users']}');
      print('   Profile: ${data['profile']}');
      print('   Profile Name: ${data['profile_name']}');
    }

    try {
      if (widget.planData != null && widget.planData!['id'] != null) {
        // Update existing plan
        if (kDebugMode) print('🔄 [CreatePlan] Updating plan: ${widget.planData!['id']}');
        await context.read<AppState>().updatePlan(widget.planData!['id'], data);
        if (kDebugMode) print('✅ [CreatePlan] Plan updated successfully');
      } else {
        // Create new plan
        if (kDebugMode) print('➕ [CreatePlan] Creating new plan');
        await context.read<AppState>().createPlan(data);
        if (kDebugMode) print('✅ [CreatePlan] Plan created successfully');
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.planData != null ? 'plan_updated'.tr() : 'plan_created'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ [CreatePlan] Error saving plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
