import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import '../theme/tiknet_themes.dart';

void showThemeSelectionDialog(BuildContext context) {
  final themeProvider = context.read<ThemeProvider>();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'theme'.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TiknetThemeVariant.values.map<Widget>((variant) {
            return RadioListTile<TiknetThemeVariant>(
              title: Text(themeProvider.getVariantName(variant)),
              value: variant,
              groupValue: themeProvider.currentVariant,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeVariant(value);
                  Navigator.of(context).pop();
                }
              },
              activeColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('close'.tr()),
        ),
      ],
    ),
  );
}
