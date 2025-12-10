import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Dialog shown when guest tries to perform a restricted action
class RegisterPromptDialog extends StatelessWidget {
  final String? featureName;

  const RegisterPromptDialog({
    super.key,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('register_required'.tr()),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (featureName != null) ...[
            Text(
              'register_required_for_feature'.tr(namedArgs: {'feature': featureName!}),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'register_benefits_title'.tr(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildBenefit(context, Icons.router, 'register_benefit_routers'.tr()),
          _buildBenefit(context, Icons.people, 'register_benefit_customers'.tr()),
          _buildBenefit(context, Icons.analytics, 'register_benefit_analytics'.tr()),
          _buildBenefit(context, Icons.group, 'register_benefit_team'.tr()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('continue_exploring'.tr()),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.person_add, size: 18),
          label: Text('register_now'.tr()),
        ),
      ],
    );
  }

  Widget _buildBenefit(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Show the dialog and return true if user wants to register
  static Future<bool> show(BuildContext context, {String? featureName}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RegisterPromptDialog(featureName: featureName),
    );
    return result ?? false;
  }
}
