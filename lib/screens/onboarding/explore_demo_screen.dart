import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ExploreDemoScreen extends StatelessWidget {
  final VoidCallback onSignUpNow;

  const ExploreDemoScreen({super.key, required this.onSignUpNow});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore the Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Experience the app\'s core features using sample data, with no sign-up needed. This is a read-only demo to showcase the value we provide.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.bar_chart,
            title: 'Dashboard Analytics',
            description: 'Visualize key metrics, user activity, and network performance.',
            buttonText: 'View Demo Dashboard',
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.group,
            title: 'User & Router Management',
            description: 'Browse and manage your users and their associated hardware seamlessly.',
            buttonText: 'Explore Demo Users',
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.receipt_long,
            title: 'Plan & Billing Management',
            description: 'Showcases the functionality for creating, viewing, and managing customer subscription plans.',
            buttonText: 'See Demo Plans',
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: onSignUpNow,
              child: Text(
                'Sign Up Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTap,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
