import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import '../services/hotspot_configuration_service.dart';

class CreateEditInternetPlanScreen extends StatefulWidget {
  final Map<String, dynamic>? planData;

  const CreateEditInternetPlanScreen({super.key, this.planData});

  @override
  State<CreateEditInternetPlanScreen> createState() => _CreateEditInternetPlanScreenState();
}

class _CreateEditInternetPlanScreenState extends State<CreateEditInternetPlanScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedValidity;
  String? _selectedDataLimit;
  String? _selectedAdditionalDevices;
  String? _selectedRouter;
  String? _selectedHotspotProfile;

  @override
  void initState() {
    super.initState();
    if (widget.planData != null) {
      _nameController.text = widget.planData!['name'] ?? '';
      _priceController.text = widget.planData!['price']?.toString() ?? '';
      _selectedValidity = widget.planData!['validity'];
      _selectedDataLimit = widget.planData!['dataLimit'];
      _selectedAdditionalDevices = widget.planData!['additionalDevices'];
      _selectedRouter = widget.planData!['router'];
      _selectedHotspotProfile = widget.planData!['hotspotProfile'];
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'plan_name'.tr(),
                      hintText: 'plan_name_hint'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'price'.tr(),
                      hintText: 'price_hint'.tr(),
                      border: const OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedValidity,
                    decoration: InputDecoration(
                      labelText: 'validity'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: HotspotConfigurationService.getValidityOptions().isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))]
                        : HotspotConfigurationService.getValidityOptions()
                            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                    onChanged: HotspotConfigurationService.getValidityOptions().isEmpty
                        ? null
                        : (value) => setState(() => _selectedValidity = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDataLimit,
                    decoration: InputDecoration(
                      labelText: 'data_limit'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: HotspotConfigurationService.getDataLimits().isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))]
                        : HotspotConfigurationService.getDataLimits()
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                    onChanged: HotspotConfigurationService.getDataLimits().isEmpty
                        ? null
                        : (value) => setState(() => _selectedDataLimit = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedAdditionalDevices,
                    decoration: InputDecoration(
                      labelText: 'additional_devices_allowed'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: HotspotConfigurationService.getDeviceAllowed().isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_options_configured'.tr()))]
                        : HotspotConfigurationService.getDeviceAllowed()
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                    onChanged: HotspotConfigurationService.getDeviceAllowed().isEmpty
                        ? null
                        : (value) => setState(() => _selectedAdditionalDevices = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRouter,
                    decoration: InputDecoration(
                      labelText: 'router'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: appState.routerConfigurations.isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_routers_configured'.tr()))]
                        : appState.routerConfigurations
                            .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                            .toList(),
                    onChanged: appState.routerConfigurations.isEmpty
                        ? null
                        : (value) => setState(() => _selectedRouter = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedHotspotProfile,
                    decoration: InputDecoration(
                      labelText: 'hotspot_user_profile'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    items: appState.hotspotProfiles.isEmpty
                        ? [DropdownMenuItem(value: null, child: Text('no_profiles_configured'.tr()))]
                        : appState.hotspotProfiles
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                            .toList(),
                    onChanged: appState.hotspotProfiles.isEmpty
                        ? null
                        : (value) => setState(() => _selectedHotspotProfile = value),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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

  void _savePlan() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('fill_required_fields'.tr())),
      );
      return;
    }

    final data = {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
      'dataLimitGB': _selectedDataLimit != null
          ? HotspotConfigurationService.extractNumericValue(_selectedDataLimit!)
          : 10,
      'validityDays': _selectedValidity != null
          ? HotspotConfigurationService.extractNumericValue(_selectedValidity!)
          : 30,
      'speedMbps': 50,
      'isActive': true,
      'deviceAllowed': _selectedAdditionalDevices != null
          ? HotspotConfigurationService.extractNumericValue(_selectedAdditionalDevices!)
          : 1,
      'userProfile': _selectedHotspotProfile ?? 'Basic',
    };

    context.read<AppState>().createPlan(data);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.planData != null ? 'plan_updated'.tr() : 'plan_created'.tr())),
    );
  }
}
