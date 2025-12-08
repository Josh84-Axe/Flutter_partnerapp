import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/app_theme.dart';
import 'verify_identity_dialog.dart';

class PasswordAndTwoFactorScreen extends StatefulWidget {
  const PasswordAndTwoFactorScreen({super.key});

  @override
  State<PasswordAndTwoFactorScreen> createState() => _PasswordAndTwoFactorScreenState();
}

class _PasswordAndTwoFactorScreenState extends State<PasswordAndTwoFactorScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _is2FAEnabled = false;
  bool _isLoading = false;
  String _passwordStrength = 'weak';

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordStrength);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTwoFactorStatus();
    });
  }

  Future<void> _loadTwoFactorStatus() async {
    final status = await context.read<AppState>().getTwoFactorStatus();
    if (mounted) {
      setState(() {
        _is2FAEnabled = status;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    if (password.length < 6) {
      setState(() => _passwordStrength = 'weak');
    } else if (password.length < 10) {
      setState(() => _passwordStrength = 'medium');
    } else {
      setState(() => _passwordStrength = 'strong');
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty || 
        _newPasswordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_fill_all_fields'.tr()), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('passwords_do_not_match'.tr()), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await context.read<AppState>().changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('password_updated_success'.tr()), backgroundColor: AppTheme.successGreen),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('password_update_failed'.tr()), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('security_settings'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'change_password'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            decoration: InputDecoration(
              labelText: 'current_password'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'new_password'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'password_strength'.tr(),
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: _passwordStrength == 'weak' ? 0.33 : _passwordStrength == 'medium' ? 0.66 : 1.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _passwordStrength == 'weak' ? AppTheme.errorRed :
                    _passwordStrength == 'medium' ? Colors.orange : AppTheme.successGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _passwordStrength.tr(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _passwordStrength == 'weak' ? AppTheme.errorRed :
                         _passwordStrength == 'medium' ? Colors.orange : AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'confirm_password'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _changePassword,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Update Password'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
