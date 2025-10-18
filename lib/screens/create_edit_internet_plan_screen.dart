import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        title: Text(isEdit ? 'Edit Internet Plan' : 'Create Internet Plan'),
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
                    decoration: const InputDecoration(
                      labelText: 'Plan Name',
                      hintText: 'e.g., Premium Unlimited',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      hintText: 'e.g., 29.99',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedValidity,
                    decoration: const InputDecoration(
                      labelText: 'Validity',
                      border: OutlineInputBorder(),
                    ),
                    items: HotspotConfigurationService.getValidityOptions().isEmpty
                        ? [const DropdownMenuItem(value: null, child: Text('No options configured'))]
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
                    decoration: const InputDecoration(
                      labelText: 'Data Limit',
                      border: OutlineInputBorder(),
                    ),
                    items: HotspotConfigurationService.getDataLimits().isEmpty
                        ? [const DropdownMenuItem(value: null, child: Text('No options configured'))]
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
                    decoration: const InputDecoration(
                      labelText: 'Additional Devices Allowed',
                      border: OutlineInputBorder(),
                    ),
                    items: HotspotConfigurationService.getDeviceAllowed().isEmpty
                        ? [const DropdownMenuItem(value: null, child: Text('No options configured'))]
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
                    decoration: const InputDecoration(
                      labelText: 'Router',
                      border: OutlineInputBorder(),
                    ),
                    items: appState.routerConfigurations.isEmpty
                        ? [const DropdownMenuItem(value: null, child: Text('No routers configured'))]
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
                    decoration: const InputDecoration(
                      labelText: 'Hotspot User Profile',
                      border: OutlineInputBorder(),
                    ),
                    items: appState.hotspotProfiles.isEmpty
                        ? [const DropdownMenuItem(value: null, child: Text('No profiles configured'))]
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
                  child: Text(isEdit ? 'Update Plan' : 'Create Plan'),
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
        const SnackBar(content: Text('Please fill required fields')),
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
      SnackBar(content: Text(widget.planData != null ? 'Plan updated' : 'Plan created')),
    );
  }
}
