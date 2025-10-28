import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/language_model.dart';
import '../utils/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late List<LanguageModel> languages;
  late String selectedCode;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      selectedCode = context.locale.languageCode;
      languages = LanguageModel.availableLanguages.map((lang) {
        return lang.copyWith(isSelected: lang.code == selectedCode);
      }).toList();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('language'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                final isSelected = language.code == selectedCode;

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.language,
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textLight,
                    ),
                  ),
                  title: Text(
                    language.nativeName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(language.name),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedCode = language.code;
                      languages = languages.map((lang) {
                        return lang.copyWith(isSelected: lang.code == selectedCode);
                      }).toList();
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final selectedLanguage = languages.firstWhere(
                      (lang) => lang.code == selectedCode,
                    );
                    await context.setLocale(Locale(selectedLanguage.code));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('apply_changes'.tr()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
