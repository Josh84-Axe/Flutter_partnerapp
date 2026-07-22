import 'package:flutter/material.dart';
import 'package:hotspot_partner_app/utils/error_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../motion/m3_motion.dart';
import '../../providers/split/auth_provider.dart';
import '../../services/api/token_storage.dart';
import '../../services/api/pin_vault.dart';
import 'package:flutter/foundation.dart';
import '../../theme/tiknet_themes.dart';

/// Material 3 login screen with unified theme components
/// Uses M3 TextFields, FilledButton, and animations
class LoginScreenM3 extends StatefulWidget {
  final String appVariant;
  const LoginScreenM3({super.key, this.appVariant = 'partner'});

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
  
  late String _currentVariant;
  bool _isVariantLoading = true;

  @override
  void initState() {
    super.initState();
    _currentVariant = widget.appVariant;
    _loadInitData();
  }

  Future<void> _loadInitData() async {
    final isPinConfigured = await PinVault.isPinConfigured();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email');
    final cachedVariant = prefs.getString('cached_app_variant');
    
    if (mounted) {
      setState(() {
        if (cachedVariant != null && cachedVariant.isNotEmpty) {
          _currentVariant = cachedVariant;
        } else if (widget.appVariant.isNotEmpty) {
          _currentVariant = widget.appVariant;
        } else {
          _currentVariant = 'partner'; // Default fallback
        }
        _isVariantLoading = false;
        
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
            overrideVariant: _currentVariant,
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
        SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(e))),
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
      final success = await context.read<AuthProvider>().loginWithPin(pin, overrideVariant: _currentVariant);
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
        SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(e))),
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
    if (_isVariantLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    ThemeData variantTheme;
    if (_currentVariant == 'family') {
      variantTheme = TiknetThemes.getElevatedDynamicBlueTheme();
    } else if (_currentVariant == 'campus') {
      variantTheme = TiknetThemes.getVibrantOrangeTheme();
    } else {
      variantTheme = TiknetThemes.getFlatLightGreenTheme();
    }

    final scheme = variantTheme.colorScheme;
    final colorScheme = scheme;

    return Theme(
      data: variantTheme,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: scheme.surface,
            body: Stack(
              children: [
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                    children: [
                      const SizedBox(height: 36),
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/logo_tiknet.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        _currentVariant == 'family'
                            ? 'login_title_family'.tr()
                            : _currentVariant == 'campus'
                                ? 'login_title_campus'.tr()
                                : 'login_title_partner'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentVariant == 'family'
                            ? 'onboarding.familyDesc'.tr()
                            : _currentVariant == 'campus'
                                ? 'onboarding.campusDesc'.tr()
                                : 'manage_wifi_zone'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      // Flavor Selector
                      Center(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'partner',
                              icon: Icon(Icons.business_center),
                              label: Text('Partner'),
                            ),
                            ButtonSegment<String>(
                              value: 'family',
                              icon: Icon(Icons.family_restroom),
                              label: Text('Family'),
                            ),
                            ButtonSegment<String>(
                              value: 'campus',
                              icon: Icon(Icons.school),
                              label: Text('Campus'),
                            ),
                          ],
                          selected: {_currentVariant},
                          onSelectionChanged: (Set<String> newSelection) async {
                            final selected = newSelection.first;
                            setState(() {
                              _currentVariant = selected;
                            });
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('cached_app_variant', selected);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_showPinLogin) ...[
                              TextFormField(
                                controller: _pinController,
                                focusNode: _pinFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'pin_code'.tr(),
                                  prefixIcon: const Icon(Icons.pin),
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'required_field'.tr();
                                  if (val.length < 4) return 'pin_too_short'.tr();
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text('login'.tr()),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showPinLogin = false;
                                  });
                                },
                                child: Text('login_with_password'.tr()),
                              ),
                            ] else ...[
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'email'.tr(),
                                  prefixIcon: const Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'required_field'.tr();
                                  if (!val.contains('@')) return 'invalid_email'.tr();
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'password'.tr(),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                onFieldSubmitted: (_) => _handleLogin(),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'required_field'.tr();
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                      ),
                                      Text('remember_me'.tr()),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Forgot password
                                    },
                                    child: Text('forgot_password'.tr()),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text('login'.tr()),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        Navigator.of(context).pushNamed('/register');
                                      },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('create_account'.tr()),
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      setState(() => _isLoading = true);
                                      try {
                                        await context.read<AuthProvider>().enterGuestMode();
                                        if (!mounted) return;
                                        Navigator.of(context).pushReplacementNamed('/home');
                                      } catch (e) {
                                        if (kDebugMode) print('❌ [LoginScreenM3] Guest mode error: $e');
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(e))),
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
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Card(
                    color: scheme.surface,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currentVariant,
                          items: const [
                            DropdownMenuItem(value: 'partner', child: Text('Partner')),
                            DropdownMenuItem(value: 'family', child: Text('Family')),
                            DropdownMenuItem(value: 'campus', child: Text('Campus')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _currentVariant = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
