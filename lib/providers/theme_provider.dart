import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/tiknet_themes.dart';

class ThemeProvider with ChangeNotifier {
  TiknetThemeVariant _currentVariant = TiknetThemeVariant.flatLightGreen;
  static const String _themeKey = 'themeVariant';

  TiknetThemeVariant get currentVariant => _currentVariant;

  ThemeData get currentTheme => TiknetThemes.getThemeForVariant(_currentVariant);

  ThemeMode get themeMode {
    return _currentVariant == TiknetThemeVariant.pillRoundedDark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final variantIndex = prefs.getInt(_themeKey) ?? 0;
    _currentVariant = TiknetThemeVariant.values[variantIndex];
    notifyListeners();
  }

  Future<void> setThemeVariant(TiknetThemeVariant variant) async {
    if (_currentVariant == variant) return;
    _currentVariant = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, variant.index);
    notifyListeners();
  }

  String getVariantName(TiknetThemeVariant variant) {
    switch (variant) {
      case TiknetThemeVariant.flatLightGreen:
        return 'Flat Light Green';
      case TiknetThemeVariant.elevatedDynamicBlue:
        return 'Elevated Dynamic Blue';
      case TiknetThemeVariant.pillRoundedDark:
        return 'Pill Rounded Dark';
    }
  }
}
