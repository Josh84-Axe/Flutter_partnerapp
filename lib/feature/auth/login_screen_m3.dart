import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../motion/m3_motion.dart';
import '../../providers/split/auth_provider.dart';
import '../../services/api/token_storage.dart';
import '../../services/api/pin_vault.dart';
import 'package:flutter/foundation.dart';

/// Material 3 login screen with unified theme components
/// Uses M3 TextFields, FilledButton, and animations
class LoginScreenM3 extends StatefulWidget {
  const LoginScreenM3({super.key});

  @override
  State<LoginScreenM3> createState() => _LoginScreenM3State();
}

class _LoginScreenM3State extends State<LoginScreenM3> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _showPinLogin = false;

  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadInitData();
  }

  Future<void> _loadInitData() async {
    final isPinConfigured = await PinVault.isPinConfigured();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email');
    
    if (mounted) {
      setState(() {
        if (email != null) {
          _emailController.text = email;
          _rememberMe = true;
        }
        _showPinLogin = isPinConfigured;
      });
      
      if (_showPinLogin) {
        _pinFocusNode.requestFocus();
      }
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (kDebugMode) print('🔐 [LoginScreenM3] _handleLogin() called');
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) print('🔐 [LoginScreenM3] Calling AuthProvider.login()');
      
      // Save or clear email for "Remember Me"
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('remembered_email', _emailController.text.trim());
      } else {
        await prefs.remove('remembered_email');
      }

      final success = await context.read<AuthProvider>().login(
            _emailController.text,
            _passwordController.text,
          );
      if (kDebugMode) print('🔐 [LoginScreenM3] AuthProvider.login() returned: $success');

      if (!mounted) return;

      // Check if login was successful
      if (!success) {
        final error = context.read<AuthProvider>().error;
        if (kDebugMode) print('🔐 [LoginScreenM3] Login failed - showing error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'login_failed_credentials'.tr())),
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
          SnackBar(content: Text('authentication_failed_token'.tr())),
        );
        return;
      }

      if (kDebugMode) print('🔐 [LoginScreenM3] Login successful');
      
      final isPinConfigured = await PinVault.isPinConfigured();
      if (!mounted) return;
      
      if (!isPinConfigured) {
        Navigator.of(context).pushReplacementNamed('/setup-pin');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (kDebugMode) print('🔐 [LoginScreenM3] Exception during login: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_generic'.tr(args: [e.toString()]))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePinLogin(String pin) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AuthProvider>().loginWithPin(pin);
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        final error = context.read<AuthProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'invalid_credentials'.tr())),
        );
        _pinController.clear();
        _pinFocusNode.requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_generic'.tr(args: [e.toString()]))),
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
              'app_title'.tr(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'manage_wifi_zone'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_showPinLogin) ...[
                    Text(
                    'enter_pin'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _pinController,
                    focusNode: _pinFocusNode,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(letterSpacing: 8, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '', // Hide the max length counter
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        _handlePinLogin(value);
                      }
                    },
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    TextButton(
                      onPressed: () {
                        setState(() => _showPinLogin = false);
                      },
                      child: Text('login_with_password'.tr()),
                    ),
                ] else ...[
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'email'.tr(),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_email'.tr();
                      }
                      if (!value.contains('@')) {
                        return 'invalid_email'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_password'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  // Remember me
                  CheckboxListTile(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    title: Text('remember_me'.tr()),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ], // end of else ...[
                ], // end of children: [
              ),
            ),
            const SizedBox(height: 8),
            // Forgot Password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pushNamed('/forgot-password');
                      },
                child: Text('forgot_password'.tr()),
              ),
            ),
            const SizedBox(height: 16),
            // Login button
            FilledButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('login'.tr()),
            ).animate().scale(
                  duration: M3Motion.buttonBounce,
                  curve: M3Motion.bounce,
                  // delay: 200.ms, 
                ),
            const SizedBox(height: 12),
            // Create account button
            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pushNamed('/register');
                    },
              child: Text('create_account'.tr()),
            ),
            const SizedBox(height: 12),
            // Guest button
            TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        // Enter guest mode
                        await context.read<AuthProvider>().enterGuestMode();
                        if (!mounted) return;
                        Navigator.of(context).pushReplacementNamed('/home');
                      } catch (e) {
                        if (kDebugMode) print('❌ [LoginScreenM3] Guest mode error: $e');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error entering guest mode: ${e.toString()}')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
              icon: const Icon(Icons.visibility, size: 18),
              label: Text('continue_as_guest'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
