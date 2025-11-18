import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../motion/m3_motion.dart';
import '../../providers/app_state.dart';
import '../../services/api/token_storage.dart';
import 'package:flutter/foundation.dart';

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
    if (kDebugMode) print('🔐 [LoginScreenM3] _handleLogin() called');
    
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
      if (kDebugMode) print('🔐 [LoginScreenM3] Calling AppState.login()');
      final success = await context.read<AppState>().login(
            _emailController.text,
            _passwordController.text,
          );
      if (kDebugMode) print('🔐 [LoginScreenM3] AppState.login() returned: $success');

      if (!mounted) return;

      // Check if login was successful
      if (!success) {
        if (kDebugMode) print('🔐 [LoginScreenM3] Login failed - showing error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed - invalid credentials')),
        );
        return;
      }

      // Verify token was saved before navigating
      if (kDebugMode) print('🔐 [LoginScreenM3] Verifying token was saved');
      final tokenStorage = TokenStorage();
      final accessToken = await tokenStorage.getAccessToken();
      if (kDebugMode) print('🔐 [LoginScreenM3] Access token exists: ${accessToken != null}');
      
      if (accessToken == null) {
        if (kDebugMode) print('🔐 [LoginScreenM3] No token found - showing error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed - no token received')),
        );
        return;
      }

      if (kDebugMode) print('🔐 [LoginScreenM3] Login successful - navigating to /home');
      // Navigate to home on successful login
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (kDebugMode) print('🔐 [LoginScreenM3] Exception during login: $e');
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
            // Logo - Tiknet icon covering full space without background
            Center(
              child: Image.asset(
                'assets/images/logo_tiknet.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
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
                      Navigator.of(context).pushNamed('/register');
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
