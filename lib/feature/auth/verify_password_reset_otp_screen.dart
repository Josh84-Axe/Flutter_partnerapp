import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../motion/m3_motion.dart';
import '../../providers/app_state.dart';

/// OTP Verification screen - Step 2: Verify OTP code
class VerifyPasswordResetOtpScreen extends StatefulWidget {
  final String email;

  const VerifyPasswordResetOtpScreen({
    super.key,
    required this.email,
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
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Navigate to reset password screen with email and OTP
      // Note: OTP verification happens during password reset confirmation
      Navigator.of(context).pushReplacementNamed(
        '/reset-password',
        arguments: {
          'email': widget.email,
          'otp': _otpController.text,
        },
      );
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
      final success = await context.read<AppState>().requestPasswordReset(
            widget.email,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend code. Please try again.'),
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
        title: const Text('Verify Code'),
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
              'Enter Verification Code',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a verification code to\n${widget.email}',
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
                labelText: 'Verification Code',
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
                  : const Text('Continue'),
            ).animate().scale(
                  duration: M3Motion.buttonBounce,
                  curve: M3Motion.bounce,
                ),
            const SizedBox(height: 12),
            // Resend code button
            TextButton(
              onPressed: _isLoading ? null : _handleResendCode,
              child: const Text('Resend Code'),
            ),
            const SizedBox(height: 12),
            // Back button
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
