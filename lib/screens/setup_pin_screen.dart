import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/auth_provider.dart';
import '../services/api/pin_vault.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  
  String? firstPin;
  bool isConfirming = false;
  bool isError = false;

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onCompleted(String pin) async {
    if (!isConfirming) {
      setState(() {
        firstPin = pin;
        isConfirming = true;
        isError = false;
      });
      pinController.clear();
      focusNode.requestFocus();
    } else {
      if (pin == firstPin) {
        // PINs match! Save to secure vault
        final authProvider = context.read<AuthProvider>();
        if (authProvider.lastLoginEmail != null && authProvider.lastLoginPassword != null) {
          await PinVault.saveCredentials(
            authProvider.lastLoginEmail!, 
            authProvider.lastLoginPassword!, 
            pin
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('pin_setup_success'.tr())),
            );
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          // Should not happen if coming from successful login
          if (mounted) Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // PINs don't match
        setState(() {
          isError = true;
          isConfirming = false;
          firstPin = null;
        });
        pinController.clear();
        focusNode.requestFocus();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('pin_mismatch'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('setup_smart_access'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: Text('skip'.tr()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                isConfirming 
                    ? 'confirm_pin'.tr()
                    : 'create_pin'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'pin_description'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: pinController,
                focusNode: focusNode,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(letterSpacing: 8, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '••••••',
                  counterText: '', // Hide the max length counter
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isError ? Colors.red : colorScheme.outline),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _onCompleted(value);
                  }
                },
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
