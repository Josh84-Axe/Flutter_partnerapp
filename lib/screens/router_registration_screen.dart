import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class RouterRegistrationScreen extends StatefulWidget {
  const RouterRegistrationScreen({super.key});

  @override
  State<RouterRegistrationScreen> createState() => _RouterRegistrationScreenState();
}

class _RouterRegistrationScreenState extends State<RouterRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiPortController = TextEditingController();
  final _dnsController = TextEditingController();
  final _usernameController = TextEditingController();
  final _radiusSecretController = TextEditingController();
  final _coaPortController = TextEditingController();
  bool _isActive = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _passwordController.dispose();
    _apiPortController.dispose();
    _dnsController.dispose();
    _usernameController.dispose();
    _radiusSecretController.dispose();
    _coaPortController.dispose();
    super.dispose();
  }

  bool _isValidIPv4(String ip) {
    final ipv4Regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    return ipv4Regex.hasMatch(ip);
  }

  bool _isValidIPv6(String ip) {
    final ipv6Regex = RegExp(
      r'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$'
    );
    return ipv6Regex.hasMatch(ip);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final routerData = {
      'name': _nameController.text.trim(),
      'ipAddress': _ipController.text.trim(),
      'password': _passwordController.text,
      'apiPort': int.parse(_apiPortController.text),
      'dnsName': _dnsController.text.trim(),
      'username': _usernameController.text.trim(),
      'radiusSecret': _radiusSecretController.text,
      'coaPort': int.parse(_coaPortController.text),
      'isActive': _isActive,
    };

    await context.read<AppState>().createRouter(routerData);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Router registered successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Router'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Router Name',
                  prefixIcon: Icon(Icons.router),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Router name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP Address',
                  prefixIcon: Icon(Icons.dns),
                  hintText: 'IPv4 or IPv6',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'IP address is required';
                  }
                  if (!_isValidIPv4(value) && !_isValidIPv6(value)) {
                    return 'Invalid IP address format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apiPortController,
                decoration: const InputDecoration(
                  labelText: 'API Port',
                  prefixIcon: Icon(Icons.power),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final port = int.tryParse(value);
                  if (port == null || port < 1 || port > 65535) {
                    return 'Port must be between 1-65535';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dnsController,
                decoration: const InputDecoration(
                  labelText: 'DNS Name',
                  prefixIcon: Icon(Icons.dns),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _radiusSecretController,
                decoration: const InputDecoration(
                  labelText: 'Radius Secret',
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coaPortController,
                decoration: const InputDecoration(
                  labelText: 'COA Port',
                  prefixIcon: Icon(Icons.power),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final port = int.tryParse(value);
                  if (port == null || port < 1 || port > 65535) {
                    return 'Port must be between 1-65535';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activate Router'),
                subtitle: const Text('Router will be active immediately'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: appState.isLoading ? null : _submitForm,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: appState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register Router', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
