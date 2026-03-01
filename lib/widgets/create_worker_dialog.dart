import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/user_provider.dart';

class CreateWorkerDialog extends StatefulWidget {
  const CreateWorkerDialog({super.key});

  @override
  State<CreateWorkerDialog> createState() => _CreateWorkerDialogState();
}

class _CreateWorkerDialogState extends State<CreateWorkerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addresseController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addresseController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final roles = userProvider.roles;

    return AlertDialog(
      title: Text('create_worker'.tr()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                   Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'first_name'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                          return 'field_required'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'last_name'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                          return 'field_required'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  border: const OutlineInputBorder(),
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
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'phone'.tr(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_phone'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addresseController,
                decoration: InputDecoration(
                  labelText: 'address'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_address'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'city'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                          return 'field_required'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: 'country'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                          return 'field_required'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'username'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_username'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'role'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: roles.isEmpty
                    ? [DropdownMenuItem(value: null, child: Text('no_roles_available'.tr()))]
                    : roles.map((role) {
                        return DropdownMenuItem(
                          value: role.id,
                          child: Text(role.name),
                        );
                      }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'select_role'.tr();
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await userProvider.createWorker({
                  'first_name': _firstNameController.text,
                  'last_name': _lastNameController.text,
                  'email': _emailController.text,
                  'phone': _phoneController.text,
                  'addresse': _addresseController.text,
                  'city': _cityController.text,
                  'country': _countryController.text,
                  'username': _usernameController.text,
                  'password': _passwordController.text,
                  'role_id': _selectedRole,
                });
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('worker_created'.tr()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: Text('create'.tr()),
        ),
      ],
    );
  }
}
