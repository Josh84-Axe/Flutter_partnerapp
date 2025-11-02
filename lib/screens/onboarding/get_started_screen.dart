import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class GetStartedScreen extends StatelessWidget {
  final VoidCallback onSignUp;
  final VoidCallback onLogin;
  final VoidCallback onContinueAsGuest;

  const GetStartedScreen({
    super.key,
    required this.onSignUp,
    required this.onLogin,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.hexagon,
                  size: 40,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your partnership on the go.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSignUp,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Log In'),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: onContinueAsGuest,
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryGreen,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
