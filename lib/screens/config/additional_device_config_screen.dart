import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/split/user_provider.dart';
import '../../utils/currency_utils.dart';
import '../../utils/app_theme.dart';
import '../../models/config_item_model.dart';

class AdditionalDeviceConfigScreen extends StatefulWidget {
  const AdditionalDeviceConfigScreen({super.key});

  @override
  State<AdditionalDeviceConfigScreen> createState() => _AdditionalDeviceConfigScreenState();
}

class _AdditionalDeviceConfigScreenState extends State<AdditionalDeviceConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _deviceCountController = TextEditingController();
  final _priceController = TextEditingController();

  List<ConfigItem> _configs = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final userProvider = context.read<UserProvider>();
      _configs = [
        ConfigItem(
          id: '1',
          name: 'no_extra_devices'.tr(),
          description: '0 additional devices - ${CurrencyUtils.formatPrice(0, userProvider.partnerCountry)}',
        ),
        ConfigItem(
          id: '2',
          name: 'extra_device'.tr(namedArgs: {'count': '1'}),
          description: '1 additional device - ${CurrencyUtils.formatPrice(5, userProvider.partnerCountry)}',
        ),
        ConfigItem(
          id: '3',
          name: 'extra_devices'.tr(namedArgs: {'count': '3'}),
          description: 'Up to 3 devices - ${CurrencyUtils.formatPrice(12, userProvider.partnerCountry)}',
        ),
      ];
      _initialized = true;
    }
  }

  ConfigItem? _editingConfig;

  @override
  void dispose() {
    _nameController.dispose();
    _deviceCountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _editConfig(ConfigItem config) {
    setState(() {
      _editingConfig = config;
      _nameController.text = config.name;
      final deviceMatch = RegExp(r'(\d+) additional').firstMatch(config.description);
      _deviceCountController.text = deviceMatch?.group(1) ?? '0';
      final priceMatch = RegExp(r'(\d+\.?\d*)').allMatches(config.description).lastOrNull;
      _priceController.text = priceMatch?.group(1) ?? '';
    });
  }

  void _deleteConfig(ConfigItem config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_confirm_title'.tr()),
        content: Text('delete_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _configs.removeWhere((c) => c.id == config.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('save_configuration'.tr()),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  void _saveConfiguration() {
    if (!_formKey.currentState!.validate()) return;

    final deviceCount = _deviceCountController.text;
    final price = _priceController.text;
    final userProvider = context.read<UserProvider>();
    final formattedPrice = CurrencyUtils.formatPrice(double.tryParse(price) ?? 0, userProvider.partnerCountry);
    final description = '$deviceCount additional ${int.parse(deviceCount) == 1 ? "device" : "devices"} - $formattedPrice';

    final newConfig = ConfigItem(
      id: _editingConfig?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: description,
    );

    setState(() {
      if (_editingConfig != null) {
        final index = _configs.indexWhere((c) => c.id == _editingConfig!.id);
        if (index != -1) {
          _configs[index] = newConfig;
        }
        _editingConfig = null;
      } else {
        _configs.add(newConfig);
      }
      _nameController.clear();
      _deviceCountController.clear();
      _priceController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('save_configuration'.tr()),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('device_configurations'.tr()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          ..._configs.map((config) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editConfig(config),
                      color: AppTheme.textLight,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _deleteConfig(config),
                    icon: Icon(Icons.delete, size: 18),
                    label: Text('delete'.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          )),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'add_new_setting'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'configuration_name'.tr(),
                      hintText: 'enter_config_name'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'configuration_name'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _deviceCountController,
                          decoration: InputDecoration(
                            labelText: 'number_of_devices'.tr(),
                            hintText: 'e.g., 5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'number_of_devices'.tr();
                            }
                            if (int.tryParse(value) == null) {
                              return 'number_of_devices'.tr();
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'price'.tr(),
                            hintText: '0.00',
                            prefixText: '${CurrencyUtils.getCurrencySymbol(context.read<UserProvider>().partnerCountry)} ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'price'.tr();
                            }
                            if (double.tryParse(value) == null) {
                              return 'price'.tr();
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          border: Border(
            top: BorderSide(
              color: AppTheme.textLight.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: FilledButton(
            onPressed: _saveConfiguration,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'save_configuration'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
