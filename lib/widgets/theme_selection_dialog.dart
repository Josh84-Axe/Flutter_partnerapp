import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';

void showThemeSelectionDialog(BuildContext context) {
  final themeProvider = context.read<ThemeProvider>();
  final isDarkMode = themeProvider.isDarkMode;

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'theme'.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<bool>(
            title: Text('default_theme'.tr()),
            secondary: const Icon(Icons.wb_sunny_outlined),
            value: false,
            groupValue: isDarkMode,
            activeColor: Theme.of(dialogContext).colorScheme.primary,
            onChanged: (val) {
              if (val != null) {
                themeProvider.setDarkMode(val);
                Navigator.of(dialogContext).pop();
              }
            },
          ),
          RadioListTile<bool>(
            title: Text('dark_mode'.tr()),
            secondary: const Icon(Icons.nightlight_round),
            value: true,
            groupValue: isDarkMode,
            activeColor: Theme.of(dialogContext).colorScheme.primary,
            onChanged: (val) {
              if (val != null) {
                themeProvider.setDarkMode(val);
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('close'.tr()),
        ),
      ],
    ),
  );
}
