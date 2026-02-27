import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/app_theme.dart';

class ExploreDemoScreen extends StatelessWidget {
  final VoidCallback onSignUpNow;

  const ExploreDemoScreen({super.key, required this.onSignUpNow});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('explore_demo_title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'explore_demo_desc'.tr(),
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
            title: 'dashboard_analytics_title'.tr(),
            description: 'dashboard_analytics_desc'.tr(),
            buttonText: 'view_demo_dashboard'.tr(),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.group,
            title: 'user_router_mgmt_title'.tr(),
            description: 'user_router_mgmt_desc'.tr(),
            buttonText: 'explore_demo_users'.tr(),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            icon: Icons.receipt_long,
            title: 'plan_billing_mgmt_title'.tr(),
            description: 'plan_billing_mgmt_desc'.tr(),
            buttonText: 'see_demo_plans'.tr(),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: onSignUpNow,
              child: Text(
                'sign_up_now'.tr(),
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
