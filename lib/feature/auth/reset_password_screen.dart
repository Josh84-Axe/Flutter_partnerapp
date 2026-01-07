import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../motion/m3_motion.dart';
import '../../providers/split/auth_provider.dart';

/// Reset Password screen - Step 3: Set new password
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your new password')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String tokenToUse = widget.token;
      if (tokenToUse.isEmpty) {
        if (kDebugMode) print('⚠️ [ResetPasswordScreen] Token is empty, attempting fallback to AuthProvider');
        tokenToUse = context.read<AuthProvider>().passwordResetToken ?? '';
      }
      
      if (kDebugMode) print('🔑 [ResetPasswordScreen] Using token: ${tokenToUse.isNotEmpty ? "${tokenToUse.substring(0, 8)}..." : "EMPTY"}');

      final success = await context.read<AuthProvider>().confirmPasswordReset(
            token: tokenToUse,
            newPassword: _passwordController.text,
          );

      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully! Please login.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset password. Please try again.'),
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
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            // Icon
            Icon(
              Icons.lock_open,
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
              'Create New Password',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your new password below',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // New Password field
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            // Confirm Password field
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              enabled: !_isLoading,
              onSubmitted: (_) => _handleResetPassword(),
            ),
            const SizedBox(height: 24),
            // Reset Password button
            FilledButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reset Password'),
            ).animate().scale(
                  duration: M3Motion.buttonBounce,
                  curve: M3Motion.bounce,
                ),
          ],
        ),
      ),
    );
  }
}
