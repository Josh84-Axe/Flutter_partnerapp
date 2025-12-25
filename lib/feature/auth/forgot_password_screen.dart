import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../motion/m3_motion.dart';
import '../../providers/split/auth_provider.dart';

/// Forgot Password screen - Step 1: Email input
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestReset() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    // Basic email validation
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AuthProvider>().requestPasswordReset(
            _emailController.text,
          );

      if (!mounted) return;

      if (success) {
        // Navigate to OTP verification screen
        Navigator.of(context).pushNamed(
          '/verify-password-reset-otp',
          arguments: _emailController.text,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send reset code. Please try again.'),
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
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            // Icon
            Icon(
              Icons.lock_reset,
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
              'Reset Password',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email address and we\'ll send you a code to reset your password.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Email field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              onSubmitted: (_) => _handleRequestReset(),
            ),
            const SizedBox(height: 24),
            // Send Code button
            FilledButton(
              onPressed: _isLoading ? null : _handleRequestReset,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send Reset Code'),
            ).animate().scale(
                  duration: M3Motion.buttonBounce,
                  curve: M3Motion.bounce,
                ),
            const SizedBox(height: 12),
            // Back to login button
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
