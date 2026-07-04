import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
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
    
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: isError ? Colors.red : colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

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
              Pinput(
                length: 6,
                controller: pinController,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                obscureText: true,
                obscuringCharacter: '•',
                onCompleted: _onCompleted,
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
