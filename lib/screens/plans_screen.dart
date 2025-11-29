import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../services/hotspot_configuration_service.dart';
import '../utils/currency_utils.dart';

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

// Separate screen for creating/editing plans
class CreateEditPlanScreen extends StatefulWidget {
  final Map<String, dynamic>? planData;

  const CreateEditPlanScreen({super.key, this.planData});

  @override
  State<CreateEditPlanScreen> createState() => _CreateEditPlanScreenState();
}

class _CreateEditPlanScreenState extends State<CreateEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  
  dynamic _selectedDataLimit;
  dynamic _selectedValidity;
  dynamic _selectedDeviceAllowed;
  int? _selectedProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.planData != null) {
      _nameController.text = widget.planData!['name'] ?? '';
      _priceController.text = widget.planData!['price']?.toString() ?? '';
      // Note: We'll need to match the selected values from the dropdowns after they load
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
    final colorScheme = Theme.of(context).colorScheme;
    final isEdit = widget.planData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_internet_plan'.tr() : 'create_internet_plan'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Plan Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'plan_name'.tr(),
                      hintText: 'plan_name_hint'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_plan_name'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'price'.tr(),
                      hintText: 'price_hint'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: '${appState.currencySymbol} ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Data Limit Dropdown
                  DropdownButtonFormField<dynamic>(
                    value: _selectedDataLimit,
                    decoration: InputDecoration(
                      labelText: 'data_limit'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.cloud_download),
                    ),
                    items: appState.dataLimits.isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))]
                        : appState.dataLimits.map((limit) {
                            return DropdownMenuItem(
                              value: limit, 
                              child: Text(_getLabel(limit, 'data_limit'))
                            );
                          }).toList(),
                    onChanged: (value) => setState(() => _selectedDataLimit = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a data limit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Validity Dropdown
                  DropdownButtonFormField<dynamic>(
                    value: _selectedValidity,
                    decoration: InputDecoration(
                      labelText: 'validity'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_month),
                    ),
                    items: appState.validityPeriods.isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))]
                        : appState.validityPeriods.map((validity) {
                            return DropdownMenuItem(
                              value: validity, 
                              child: Text(_getLabel(validity, 'validity'))
                            );
                          }).toList(),
                    onChanged: (value) => setState(() => _selectedValidity = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a validity period';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Device Allowed Dropdown
                  DropdownButtonFormField<dynamic>(
                    value: _selectedDeviceAllowed,
                    decoration: InputDecoration(
                      labelText: 'device_allowed'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.devices),
                    ),
                    items: appState.sharedUsers.isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))]
                        : appState.sharedUsers.map((user) {
                            return DropdownMenuItem(
                              value: user, 
                              child: Text(_getLabel(user, 'shared_users'))
                            );
                          }).toList(),
                    onChanged: (value) => setState(() => _selectedDeviceAllowed = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select device allowed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Hotspot Profile Dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedProfile,
                    decoration: InputDecoration(
                      labelText: 'hotspot_user_profile'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    items: appState.hotspotProfiles.isEmpty
                        ? []
                        : appState.hotspotProfiles
                            .map((profile) => DropdownMenuItem(
                                  value: int.tryParse(profile.id),
                                  child: Text(profile.name),
                                ))
                            .toList(),
                    onChanged: (value) => setState(() => _selectedProfile = value),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a hotspot profile';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      if (isEdit) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _deletePlan,
                            icon: const Icon(Icons.delete),
                            label: Text('delete_plan'.tr()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _savePlan,
                          icon: Icon(isEdit ? Icons.save : Icons.add),
                          label: Text(isEdit ? 'update_plan'.tr() : 'create_plan'.tr()),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _getLabel(dynamic item, String type) {
    if (item is! Map) return item.toString();
    
    if (item['name'] != null) return item['name'].toString();
    
    switch (type) {
      case 'data_limit':
        if (item['gb'] != null) return '${item['gb']} GB';
        if (item['value'] != null) return '${item['value']} GB';
        if (item['limit'] != null) return '${item['limit']} GB';
        break;
      case 'validity':
        if (item['days'] != null) return '${item['days']} Days';
        if (item['value'] != null) return '${item['value']} Days';
        break;
      case 'shared_users':
        if (item['count'] != null) return '${item['count']} Users';
        if (item['limit'] != null) return '${item['limit']} Users';
        if (item['value'] != null) return '${item['value']} Users';
        break;
    }
    
    // Fallback to printing the whole map if nothing matches, but cleaner
    return item.values.first.toString();
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Helper to extract ID from dynamic item
      int? extractId(dynamic item, String context) {
        if (kDebugMode) print('🔍 [CreatePlan] Extracting ID from $context: $item');
        
        if (item is Map) {
          final id = item['id'];
          if (kDebugMode) print('   Extracted ID: $id');
          return id is int ? id : (id is String ? int.tryParse(id) : null);
        } else if (item is int) {
          return item;
        } else if (item is String) {
          return int.tryParse(item);
        }
        return null;
      }

      final dataLimitId = _selectedDataLimit is String && 
          HotspotConfigurationService.isUnlimited(_selectedDataLimit as String)
          ? null
          : extractId(_selectedDataLimit, 'data_limit');
      
      final validityId = extractId(_selectedValidity, 'validity');
      final sharedUsersId = extractId(_selectedDeviceAllowed, 'shared_users');

      final data = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'data_limit': dataLimitId,
        'validity': validityId,
        'is_active': true,
        'shared_users': sharedUsersId,
        'profile': _selectedProfile,
      };

      if (kDebugMode) print('📦 [CreatePlan] Plan data: $data');

      final appState = context.read<AppState>();
      if (widget.planData != null && widget.planData!['id'] != null) {
        await appState.updatePlan(widget.planData!['slug']?.toString() ?? widget.planData!['id'].toString(), data);
      } else {
        await appState.createPlan(data);
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
      if (kDebugMode) print('❌ [CreatePlan] Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_plan'.tr()),
        content: Text('delete_plan_confirm'.tr(namedArgs: {'name': _nameController.text})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<AppState>().deletePlan(widget.planData!['slug']?.toString() ?? widget.planData!['id'].toString());
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('plan_deleted_successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
