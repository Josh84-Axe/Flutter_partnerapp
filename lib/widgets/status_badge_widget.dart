import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum BadgeType {
  success,
  warning,
  error,
  info,
  pending,
}

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.type,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case BadgeType.success:
        return AppTheme.successGreen.withValues(alpha: 0.1);
      case BadgeType.warning:
        return AppTheme.warningAmber.withValues(alpha: 0.1);
      case BadgeType.error:
        return AppTheme.errorRed.withValues(alpha: 0.1);
      case BadgeType.info:
        return AppTheme.primaryGreen.withValues(alpha: 0.1);
      case BadgeType.pending:
        return AppTheme.warningAmber.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case BadgeType.success:
        return AppTheme.successGreen;
      case BadgeType.warning:
        return AppTheme.warningAmber;
      case BadgeType.error:
        return AppTheme.errorRed;
      case BadgeType.info:
        return AppTheme.primaryGreen;
      case BadgeType.pending:
        return AppTheme.warningAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
