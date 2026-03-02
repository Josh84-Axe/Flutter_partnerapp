import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class ActionFailedAlert {
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onTryAgain,
    VoidCallback? onContactSupport,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final displayTitle = title ?? 'action_failed'.tr();
        final displayMessage = message ?? 'generic_error_check_internet'.tr();
        return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error,
                  size: 40,
                  color: AppTheme.errorRed,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onTryAgain?.call();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('try_again'.tr()),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onContactSupport?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('contact_support_btn'.tr()),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'close'.tr(),
                  style: TextStyle(color: AppTheme.textLight),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}
