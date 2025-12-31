import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/split/auth_provider.dart';
import '../utils/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class OtpValidationScreen extends StatefulWidget {
  const OtpValidationScreen({super.key});

  @override
  State<OtpValidationScreen> createState() => _OtpValidationScreenState();
}

class _OtpValidationScreenState extends State<OtpValidationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final code = _controllers.map((c) => c.text).join();
    final type = args?['type'] as String?;
    final email = args?['email'] as String?;
    
    if (code.length == 6) {
      if (type == 'password_reset' && email != null) {
        // Verify OTP with backend before navigating
         final authProvider = context.read<AuthProvider>();
         
         showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
         );

         try {
           final success = await authProvider.verifyPasswordResetOtp(email, code);
           
           if (mounted) Navigator.of(context).pop(); // Close loading
           
           if (success) {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(
                  '/set-new-password',
                  arguments: {
                    'email': email,
                    'otp': code,
                  },
                );
              }
           } else {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text('invalid_verification_code'.tr()),
                   backgroundColor: AppTheme.errorRed,
                 ),
               );
             }
           }
         } catch (e) {
           if (mounted) Navigator.of(context).pop();
           if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text('error_occurred'.tr()),
                   backgroundColor: AppTheme.errorRed,
                 ),
               );
           }
         }
      } else {
        // Original behavior for other OTP types
        // Note: Ideally other flows should also verify_otp here or pass a callback
        Navigator.of(context).pop();
        if (args != null && args['onVerified'] != null) {
          args['onVerified']();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final purpose = args?['purpose'] as String? ?? 'Verify your identity';

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Validation'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              purpose,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'A 6-digit code has been sent to your email',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onDigitEntered(index, value),
                    onTap: () {
                      _controllers[index].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controllers[index].text.length,
                      );
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _verifyCode,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Verify & Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                 final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                 final type = args?['type'] as String?;
                 final email = args?['email'] as String?;
                 
                 if (type == 'password_reset' && email != null) {
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.resendPasswordResetOtp(email);
                    if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('code_resent'.tr())),
                       );
                    }
                 }
              },
              child: Text(
                'resend_code'.tr(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
