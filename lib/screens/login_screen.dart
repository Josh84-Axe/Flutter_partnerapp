import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../utils/app_theme.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController(); // Confirm password
  bool _isLogin = true;
  final _nameController = TextEditingController(); // First Name
  final _enterpriseNameController = TextEditingController(); // Enterprise Name
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _numberOfRoutersController = TextEditingController();
  String? _selectedCountry;
  
  // Map of ISO code to Country Name
  final Map<String, String> _countries = {
    'TG': 'Togo',
    'US': 'United States',
    'FR': 'France',
    'BE': 'Belgium',
    'CA': 'Canada',
    'CI': 'Ivory Coast',
    'SN': 'Senegal',
    'GB': 'United Kingdom',
    'DE': 'Germany',
    'ES': 'Spain',
    'IT': 'Italy',
    'NG': 'Nigeria',
    'GH': 'Ghana',
    'KE': 'Kenya',
    'ZA': 'South Africa',
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _enterpriseNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _numberOfRoutersController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    bool success;

    if (_isLogin) {
      success = await appState.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      // Validate confirm password
      if (_passwordController.text != _password2Controller.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('passwords_do_not_match'.tr())),
        );
        return;
      }
      
      success = await appState.register(
        firstName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        password2: _password2Controller.text,
        phone: _phoneController.text.trim(),
        businessName: _enterpriseNameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        country: _selectedCountry ?? 'TG',
        numberOfRouters: int.tryParse(_numberOfRoutersController.text.trim()) ?? 1,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo_tiknet.png',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'app_title'.tr(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'manage_wifi_zone'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textLight,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'name'.tr(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        // Controller is updated automatically
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        setSelectorButtonAsPrefixIcon: true,
                        leadingPadding: 12,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      selectorTextStyle: TextStyle(color: colorScheme.onSurface),
                      initialValue: PhoneNumber(isoCode: _selectedCountry ?? 'TG'),
                      textFieldController: _phoneController,
                      formatInput: true,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputDecoration: InputDecoration(
                        labelText: 'phone'.tr(),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'register.error.phoneRequired'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _enterpriseNameController,
                      decoration: InputDecoration(
                        labelText: 'enterprise_name'.tr(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_enterprise_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'address'.tr(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_address'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'city'.tr(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_city'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'country'.tr(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: _countries.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'select_country'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numberOfRoutersController,
                      decoration: InputDecoration(
                        labelText: 'number_of_routers'.tr(),
                        prefixIcon: Icon(Icons.router),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_number_of_routers'.tr();
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'must_be_one_or_greater'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'email'.tr(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_email'.tr();
                      }
                      if (!value.contains('@')) {
                        return 'enter_valid_email'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_password'.tr();
                      }
                      if (value.length < 6) {
                        return 'password_min_length'.tr();
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password2Controller,
                      decoration: InputDecoration(
                        labelText: 'confirm_password'.tr(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'confirm_password_required'.tr();
                        }
                        if (value != _passwordController.text) {
                          return 'passwords_do_not_match'.tr();
                        }
                        return null;
                      },
                    ),
                  ],
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/forgot-password');
                        },
                        child: Text(
                          'forgot_password'.tr(),
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (appState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        appState.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  FilledButton(
                    onPressed: appState.isLoading ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: appState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? 'login'.tr() : 'register'.tr(),
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (_isLogin) {
                        Navigator.of(context).pushNamed('/register');
                      } else {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      }
                    },
                    child: Text(
                      _isLogin ? 'dont_have_account'.tr() : 'already_have_account'.tr(),
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
