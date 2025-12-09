import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();
    final success = await appState.confirmRegistration(_otpController.text.trim());

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('email_verified_success'.tr()),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      // Navigate to dashboard or login
      Navigator.of(context).pushReplacementNamed('/home'); 
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    final appState = context.read<AppState>();
    final success = await appState.resendVerifyEmailOtp();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('otp_resent_success'.tr())),
      );
      _startResendTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final email = appState.registrationEmail ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: Text('verify_email'.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'enter_verification_code'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'code_sent_to'.tr(args: [email]),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter_otp'.tr();
                    }
                    if (value.length < 6) {
                      return 'otp_length_error'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (appState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      appState.error!,
                      style: const TextStyle(color: AppTheme.errorRed),
                      textAlign: TextAlign.center,
                    ),
                  ),
                FilledButton(
                  onPressed: appState.isLoading ? null : _verifyOtp,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: appState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('verify'.tr()),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _canResend && !appState.isLoading ? _resendCode : null,
                  child: Text(
                    _canResend
                        ? 'resend_code'.tr()
                        : 'resend_in'.tr(args: [_resendCountdown.toString()]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
