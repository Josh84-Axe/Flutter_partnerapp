import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PermissionDeniedDialog extends StatelessWidget {
  final String? requiredPermission;
  final String? message;

  const PermissionDeniedDialog({
    super.key,
    this.requiredPermission,
    this.message,
  });

  static Future<void> show(BuildContext context, {String? requiredPermission, String? message}) {
    return showDialog(
      context: context,
      builder: (context) => PermissionDeniedDialog(
        requiredPermission: requiredPermission,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Text('access_denied'.tr()),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message ?? 'permission_denied_message'.tr()),
          if (requiredPermission != null) ...[
            const SizedBox(height: 12),
            Text(
              'required_permission'.tr(namedArgs: {'permission': requiredPermission!}),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('ok'.tr()),
        ),
      ],
    );
  }
}
