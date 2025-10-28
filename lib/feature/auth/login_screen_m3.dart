import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../motion/m3_motion.dart';
import '../../providers/app_state.dart';

/// Material 3 login screen with unified theme components
/// Uses M3 TextFields, FilledButton, and animations
class LoginScreenM3 extends StatefulWidget {
  const LoginScreenM3({super.key});

  @override
  State<LoginScreenM3> createState() => _LoginScreenM3State();
}

class _LoginScreenM3State extends State<LoginScreenM3> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AppState>().login(
            _emailController.text,
            _passwordController.text,
          );

      if (!mounted) return;

      // Navigate to home on successful login
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            const SizedBox(height: 36),
            // Logo
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.wifi_rounded,
                  size: 56,
                  color: scheme.onPrimaryContainer,
                ),
              )
                  .animate()
                  .fadeIn(duration: M3Motion.splashFade)
                  .scale(
                    duration: M3Motion.splashScale,
                    curve: M3Motion.decel,
                  ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Tiknet Partner',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your Wi-Fi zone',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            // Email field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              enabled: !_isLoading,
              onSubmitted: (_) => _handleLogin(),
            ),
            const SizedBox(height: 24),
            // Login button
            FilledButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ).animate().scale(
                  duration: M3Motion.buttonBounce,
                  curve: M3Motion.bounce,
                ),
            const SizedBox(height: 12),
            // Create account button
            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      // TODO: Navigate to registration screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registration coming soon'),
                        ),
                      );
                    },
              child: const Text('Create account'),
            ),
            const SizedBox(height: 12),
            // Guest button
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      // TODO: Implement guest mode
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Guest mode coming soon'),
                        ),
                      );
                    },
              child: const Text('Continue as guest'),
            ),
          ],
        ),
      ),
    );
  }
}
