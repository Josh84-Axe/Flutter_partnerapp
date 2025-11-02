import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../models/router_configuration_model.dart';
import '../utils/app_theme.dart';

class AddRouterScreen extends StatefulWidget {
  const AddRouterScreen({super.key});

  @override
  State<AddRouterScreen> createState() => _AddRouterScreenState();
}

class _AddRouterScreenState extends State<AddRouterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ipAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiPortController = TextEditingController();
  final _dnsNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _radiusSecretController = TextEditingController();
  final _coaPortController = TextEditingController();
  
  bool _passwordVisible = false;
  bool _radiusSecretVisible = false;
  RouterConfigurationModel? _existingConfig;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is RouterConfigurationModel) {
        setState(() {
          _existingConfig = args;
          _nameController.text = args.name;
          _ipAddressController.text = args.ipAddress;
          _passwordController.text = args.password ?? '';
          _apiPortController.text = args.apiPort?.toString() ?? '';
          _dnsNameController.text = args.dnsName ?? '';
          _usernameController.text = args.username ?? '';
          _radiusSecretController.text = args.radiusSecret ?? '';
          _coaPortController.text = args.coaPort?.toString() ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipAddressController.dispose();
    _passwordController.dispose();
    _apiPortController.dispose();
    _dnsNameController.dispose();
    _usernameController.dispose();
    _radiusSecretController.dispose();
    _coaPortController.dispose();
    super.dispose();
  }

  void _saveConfiguration() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _existingConfig != null
                ? 'router_config_updated'.tr()
                : 'router_config_saved'.tr(),
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingConfig != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_router'.tr() : 'add_new_router'.tr()),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'router_name'.tr(),
                        hintText: 'router_name_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_router_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ipAddressController,
                      decoration: InputDecoration(
                        labelText: 'ip_address'.tr(),
                        hintText: 'ip_address_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_ip_address'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'password'.tr(),
                        hintText: 'router_password'.tr(),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiPortController,
                      decoration: InputDecoration(
                        labelText: 'api_port'.tr(),
                        hintText: 'api_port_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dnsNameController,
                      decoration: InputDecoration(
                        labelText: 'dns_name'.tr(),
                        hintText: 'dns_name_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'username'.tr(),
                        hintText: 'username_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _radiusSecretController,
                      decoration: InputDecoration(
                        labelText: 'radius_secret'.tr(),
                        hintText: 'radius_secret_hint'.tr(),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _radiusSecretVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _radiusSecretVisible = !_radiusSecretVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_radiusSecretVisible,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coaPortController,
                      decoration: InputDecoration(
                        labelText: 'coa_port'.tr(),
                        hintText: 'coa_port_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('cancel'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveConfiguration,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('save_configuration'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
