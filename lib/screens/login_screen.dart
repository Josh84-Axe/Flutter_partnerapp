import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _numberOfRoutersController = TextEditingController();
  String? _selectedCountry;
  
  final List<String> _countries = [
    'United States',
    'France',
    'Belgium',
    'Canada',
    'Ivory Coast',
    'Senegal',
    'United Kingdom',
    'Germany',
    'Spain',
    'Italy',
    'Nigeria',
    'Ghana',
    'Kenya',
    'South Africa',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _numberOfRoutersController.dispose();
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
      success = await appState.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
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
                          color: AppTheme.primaryGreen,
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
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'phone'.tr(),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'address'.tr(),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'city'.tr(),
                        prefixIcon: const Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'country'.tr(),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
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
                        prefixIcon: const Icon(Icons.router),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final number = int.tryParse(value);
                          if (number == null || number < 0) {
                            return 'must_be_zero_or_greater'.tr();
                          }
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
                      prefixIcon: const Icon(Icons.email),
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
                      prefixIcon: const Icon(Icons.lock),
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
                          style: const TextStyle(color: AppTheme.primaryGreen),
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
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin ? 'dont_have_account'.tr() : 'already_have_account'.tr(),
                      style: const TextStyle(color: AppTheme.primaryGreen),
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
