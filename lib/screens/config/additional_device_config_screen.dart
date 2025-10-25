import 'package:flutter/material.dart';
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

  List<ConfigItem> _configs = [
    ConfigItem(
      id: '1',
      name: 'No Extra Devices',
      description: '0 additional devices - \$0.00',
    ),
    ConfigItem(
      id: '2',
      name: '1 Extra Device',
      description: '1 additional device - \$5.00',
    ),
    ConfigItem(
      id: '3',
      name: 'Up to 3 Devices',
      description: 'Up to 3 devices - \$12.00',
    ),
  ];

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
      final priceMatch = RegExp(r'\$(\d+\.?\d*)').firstMatch(config.description);
      _priceController.text = priceMatch?.group(1) ?? '';
    });
  }

  void _deleteConfig(ConfigItem config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete "${config.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _configs.removeWhere((c) => c.id == config.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuration deleted'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveConfiguration() {
    if (!_formKey.currentState!.validate()) return;

    final deviceCount = _deviceCountController.text;
    final price = _priceController.text;
    final description = '$deviceCount additional ${int.parse(deviceCount) == 1 ? "device" : "devices"} - \$$price';

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
        content: Text(_editingConfig != null ? 'Configuration updated' : 'Configuration added'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Configurations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                      icon: const Icon(Icons.edit),
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
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
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
                  const Text(
                    'Add New Setting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Configuration Name',
                      hintText: 'e.g., \'Business Plan\'',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a configuration name';
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
                            labelText: 'Number of Devices',
                            hintText: 'e.g., 5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Must be a number';
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
                            labelText: 'Price',
                            hintText: '0.00',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid';
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
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Configuration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
