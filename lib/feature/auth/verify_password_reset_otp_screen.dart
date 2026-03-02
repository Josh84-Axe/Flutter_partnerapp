import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../motion/m3_motion.dart';
import '../../providers/split/auth_provider.dart';

/// OTP Verification screen - Step 2: Verify OTP code
class VerifyPasswordResetOtpScreen extends StatefulWidget {
  final String email;
  final String otpId;

  const VerifyPasswordResetOtpScreen({
    super.key,
    required this.email,
    this.otpId = '',
  });

  @override
  State<VerifyPasswordResetOtpScreen> createState() =>
      _VerifyPasswordResetOtpScreenState();
}

class _VerifyPasswordResetOtpScreenState
    extends State<VerifyPasswordResetOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('otp_required'.tr())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify OTP with backend first
      final response = await context.read<AuthProvider>().verifyPasswordResetOtp(
            widget.email,
            _otpController.text,
            widget.otpId,
          );

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        final authProvider = context.read<AuthProvider>();
        
        if (kDebugMode) {
          print('🔍 [VerifyPasswordResetOtpScreen] Full response: $response');
        }
        
        // Safe extraction of token from multiple possible locations
        String? token;
        final responseData = response['data'];
        
        if (responseData is Map) {
          token = responseData['token']?.toString() ?? 
                  responseData['access']?.toString() ?? 
                  responseData['reset_token']?.toString() ?? // Added correct key
                  responseData['password_reset_token']?.toString();
        } else if (responseData is String) {
          token = responseData;
        }
        
        // Check if token is in the flat response
        token ??= response['token']?.toString() ?? 
                  response['access']?.toString() ?? 
                  response['reset_token']?.toString() ?? // Added correct key
                  response['password_reset_token']?.toString();
                  
        // Final fallback to provider if it was captured there
        token ??= authProvider.passwordResetToken;

        if (kDebugMode && token != null) {
          print('🔑 [VerifyPasswordResetOtpScreen] Token captured: ${token.substring(0, 8)}...');
        }

        if (mounted) {
          if (token != null && token.isNotEmpty) {
            Navigator.of(context).pushReplacementNamed(
              '/reset-password',
              arguments: {
                'email': widget.email,
                'token': token,
              },
            );
          } else {
             // Fallback error if still missing (shouldn't happen now)
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('error_token_missing'.tr()),
                duration: const Duration(seconds: 5),
              ),
             );
          }
        }
      } else {
        final errorMessage = response?['message'] ?? 'Invalid verification code.';
        // DEBUG: Show full structure if failed
        if (kDebugMode) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Debug Failure: $errorMessage\nFull: $response'),
              duration: const Duration(seconds: 10),
            ),
           );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage.tr())),
           );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await context.read<AuthProvider>().requestPasswordReset(
            widget.email,
          );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('otp_resent_success'.tr()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_resend_code'.tr()),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('verify_code'.tr()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            // Icon
            Icon(
              Icons.mark_email_read,
              size: 80,
              color: scheme.primary,
            )
                .animate()
                .fadeIn(duration: M3Motion.splashFade)
                .scale(
                  duration: M3Motion.splashScale,
                  curve: M3Motion.decel,
                ),
            const SizedBox(height: 24),
            // Title
            Text(
              'enter_verification_code_title'.tr(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${'verification_code_sent_to'.tr()}\n${widget.email}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // OTP field
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'verification_code'.tr(),
                prefixIcon: Icon(Icons.pin),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              maxLength: 6,
              onSubmitted: (_) => _handleVerifyOtp(),
            ),
            const SizedBox(height: 24),
            // Verify button
            FilledButton(
              onPressed: _isLoading ? null : _handleVerifyOtp,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('continue'.tr()),
            ).animate().scale(
                  duration: M3Motion.buttonBounce,
                  curve: M3Motion.bounce,
                ),
            const SizedBox(height: 12),
            // Resend code button
            TextButton(
              onPressed: _isLoading ? null : _handleResendCode,
              child: Text('resend'.tr()),
            ),
            const SizedBox(height: 12),
            // Back button
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: Text('close'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
