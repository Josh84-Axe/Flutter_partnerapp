import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ResetEmailSentScreen extends StatelessWidget {
  const ResetEmailSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Sent'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.mark_email_read,
                size: 100,
                color: AppTheme.successGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Check Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/set-new-password');
                },
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Continue to Reset Password',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset link resent!')),
                  );
                },
                child: Text(
                  'Didn\'t receive the email? Resend',
                  style: TextStyle(color: AppTheme.deepGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
