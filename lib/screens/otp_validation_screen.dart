import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/split/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/alerts/success_alert.dart';

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
  
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    
    // Auto-verify when last digit is entered
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyCode();
    }
  }

  Future<void> _resendCode() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final type = args?['type'] as String?;
    final email = args?['email'] as String?;
    final authProvider = context.read<AuthProvider>();

    if (email == null) return;

    _startTimer(); // Restart timer immediately for feedback

    try {
      if (type == 'password_reset') {
        await authProvider.resendPasswordResetOtp(email);
      } else if (type == 'registration') {
        await authProvider.resendVerifyEmailOtp(email);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('code_resent'.tr()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.brandGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final code = _controllers.map((c) => c.text).join();
    final type = args?['type'] as String?;
    final email = args?['email'] as String?;
    
    if (code.length != 6) return;

    final authProvider = context.read<AuthProvider>();

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.brandGreen),
      ),
    );

    try {
      if (type == 'password_reset' && email != null) {
        final otpId = args?['otp_id']?.toString() ?? '';
        final response = await authProvider.verifyPasswordResetOtp(email, code, otpId);
        
        if (mounted) Navigator.of(context).pop(); // Close loading

        if (response != null && response['success'] == true) {
          String? token;
          if (response['data'] is Map) {
            token = response['data']['token'];
          } else if (response['token'] != null) {
            token = response['token'];
          }

          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              '/set-new-password',
              arguments: {
                'email': email,
                'token': token ?? '',
              },
            );
          }
        } else {
          _handleError(response?['message'] ?? 'invalid_verification_code'.tr());
        }
      } else if (type == 'registration' && email != null) {
        final success = await authProvider.confirmRegistration(email, code);
        if (mounted) Navigator.of(context).pop(); // Close loading

        if (success) {
          if (mounted) {
            await SuccessAlert.show(
              context,
              title: 'registration_successful'.tr(),
              message: 'welcome_message'.tr(),
              buttonText: 'continue'.tr(),
            );
            if (mounted) Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          _handleError(authProvider.error ?? 'Verification failed');
        }
      } else {
        if (mounted) Navigator.of(context).pop();
        // Fallback for other types
        if (args != null && args['onVerified'] != null) {
          args['onVerified']();
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _handleError('Error: $e');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Optional: Shake animation on the boxes would be cool here
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String purpose = args?['purpose'] as String? ?? 'verify_identity'.tr();
    final String? email = args?['email'];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Icon with Animation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.brandGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.vpn_key_outlined,
                  size: 44,
                  color: AppTheme.brandGreen,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.backOut).fadeIn(),

              const SizedBox(height: 32),
              
              Text(
                purpose,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 12),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textLight,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: 'code_sent_to'.tr()),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: email ?? 'your_email'.tr(),
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 48),

              // Digital Input Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpInputBox(index)),
              ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _verifyCode,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'verify_and_continue'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              Column(
                children: [
                  Text(
                    "didn_t_receive_code".tr(),
                    style: TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _canResend ? _resendCode : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      _canResend 
                          ? 'resend_code'.tr() 
                          : '${'resend_code'.tr()} in ${_secondsRemaining}s',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _canResend ? AppTheme.brandGreen : AppTheme.textLight,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInputBox(int index) {
    return Container(
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus 
              ? AppTheme.brandGreen 
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          if (_focusNodes[index].hasFocus)
            BoxShadow(
              color: AppTheme.brandGreen.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            _onDigitEntered(index, value);
            // Redraw to show the green border on focus change if needed
            setState(() {});
          },
          onTap: () {
            _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index].text.length,
            );
          },
        ),
      ),
    );
  }
}
