import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/tiknet_themes.dart';
import '../models/theme_config_model.dart';
import '../theme/dynamic_theme.dart';
import '../flavors.dart';
import 'dart:convert';

class ThemeProvider with ChangeNotifier {
  ThemeConfig? _dynamicThemeConfig;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  String get _darkModeKey => 'isDarkMode_${F.appFlavor.name}';
  String get _dynamicThemeKey => 'dynamicThemeConfig_${F.appFlavor.name}';

  TiknetThemeVariant get defaultVariant {
    switch (F.appFlavor) {
      case Flavor.campus:
        return TiknetThemeVariant.vibrantOrange;
      case Flavor.family:
        return TiknetThemeVariant.elevatedDynamicBlue;
      default:
        return TiknetThemeVariant.flatLightGreen;
    }
  }

  TiknetThemeVariant get currentVariant {
    if (_isDarkMode) {
      return TiknetThemeVariant.pillRoundedDark;
    }
    return defaultVariant;
  }

  ThemeData get currentTheme {
    if (_dynamicThemeConfig != null) {
      return DynamicTheme.buildTheme(_dynamicThemeConfig!);
    }
    return TiknetThemes.getThemeForVariant(currentVariant);
  }

  ThemeMode get themeMode {
    if (_dynamicThemeConfig != null) {
      return _dynamicThemeConfig!.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    
    // Load flavor-scoped dynamic theme if exists
    final dynamicThemeJson = prefs.getString(_dynamicThemeKey);
    if (dynamicThemeJson != null) {
      try {
        _dynamicThemeConfig = ThemeConfig.fromJson(json.decode(dynamicThemeJson));
      } catch (e) {
        debugPrint('Error parsing dynamic theme: $e');
      }
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
    notifyListeners();
  }

  Future<void> setDynamicTheme(ThemeConfig config) async {
    _dynamicThemeConfig = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dynamicThemeKey, json.encode(config.toJson()));
    notifyListeners();
  }

  Future<void> clearDynamicTheme() async {
    _dynamicThemeConfig = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dynamicThemeKey);
    notifyListeners();
  }

  void setThemeVariant(TiknetThemeVariant variant) {
    if (variant == TiknetThemeVariant.pillRoundedDark) {
      setDarkMode(true);
    } else {
      setDarkMode(false);
    }
  }

  String getVariantName(TiknetThemeVariant variant) {
    if (_isDarkMode || variant == TiknetThemeVariant.pillRoundedDark) {
      return 'Dark Mode';
    }
    return 'Default Theme';
  }
}
