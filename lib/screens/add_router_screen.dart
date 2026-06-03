import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/router_configuration_model.dart';
import '../providers/split/network_provider.dart';
import 'package:provider/provider.dart';

class AddRouterScreen extends StatefulWidget {
  const AddRouterScreen({super.key});

  @override
  State<AddRouterScreen> createState() => _AddRouterScreenState();
}

class _AddRouterScreenState extends State<AddRouterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _radiusSecretController = TextEditingController();

  // Constants — not shown to user, always sent to API
  static const int _apiPort = 8728;
  static const int _coaPort = 3799;

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
          _passwordController.text = args.password ?? '';
          _radiusSecretController.text = args.radiusSecret ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _radiusSecretController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    if (_formKey.currentState!.validate()) {
      final networkProvider = context.read<NetworkProvider>();

      final data = {
        'name': _nameController.text.trim(),
        'password': _passwordController.text,
        'secret': _radiusSecretController.text.trim(),
        'api_port': _apiPort,
        'coa_port': _coaPort,
        'is_active': true,
      };

      try {
        if (_existingConfig != null) {
          await networkProvider.updateRouter(_existingConfig!.slug, data);
        } else {
          await networkProvider.addRouter(data);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _existingConfig != null
                    ? 'router_config_updated'.tr()
                    : 'router_config_saved'.tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('error_occurred'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingConfig != null;
    final colorScheme = Theme.of(context).colorScheme;

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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: colorScheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'router_config_info'.tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Wifi Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'wifi_name'.tr(),
                        hintText: 'wifi_name_hint'.tr(),
                        prefixIcon: const Icon(Icons.wifi),
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enter_wifi_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // MikroTik Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'mikrotik_password'.tr(),
                        hintText: 'mikrotik_password_hint'.tr(),
                        prefixIcon: const Icon(Icons.lock_outline),
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
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_mikrotik_password'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Radius Secret
                    TextFormField(
                      controller: _radiusSecretController,
                      decoration: InputDecoration(
                        labelText: 'radius_secret'.tr(),
                        hintText: 'radius_secret_hint'.tr(),
                        prefixIcon: const Icon(Icons.key_outlined),
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
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveConfiguration(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enter_radius_secret'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Constant values info (read-only display)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'default_settings'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.settings_ethernet,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                'API Port: $_apiPort  •  CoA Port: $_coaPort',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: Consumer<NetworkProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('cancel'.tr()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed:
                                provider.isLoading ? null : _saveConfiguration,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('save_configuration'.tr()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
