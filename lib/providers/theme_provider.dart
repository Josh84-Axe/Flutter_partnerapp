import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/tiknet_themes.dart';
import '../models/theme_config_model.dart';
import '../theme/dynamic_theme.dart';
import 'dart:convert';

class ThemeProvider with ChangeNotifier {
  TiknetThemeVariant _currentVariant = TiknetThemeVariant.flatLightGreen;
  ThemeConfig? _dynamicThemeConfig;
  static const String _themeKey = 'themeVariant';
  static const String _dynamicThemeKey = 'dynamicThemeConfig';

  TiknetThemeVariant get currentVariant => _currentVariant;

  ThemeData get currentTheme {
    if (_dynamicThemeConfig != null) {
      return DynamicTheme.buildTheme(_dynamicThemeConfig!);
    }
    return TiknetThemes.getThemeForVariant(_currentVariant);
  }

  ThemeMode get themeMode {
    if (_dynamicThemeConfig != null) {
      return _dynamicThemeConfig!.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
    return _currentVariant == TiknetThemeVariant.pillRoundedDark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load dynamic theme if exists
    final dynamicThemeJson = prefs.getString(_dynamicThemeKey);
    if (dynamicThemeJson != null) {
      try {
        _dynamicThemeConfig = ThemeConfig.fromJson(json.decode(dynamicThemeJson));
      } catch (e) {
        debugPrint('Error parsing dynamic theme: $e');
      }
    }

    final variantIndex = prefs.getInt(_themeKey) ?? 0;
    _currentVariant = TiknetThemeVariant.values[variantIndex];
    notifyListeners();
  }

  Future<void> setThemeVariant(TiknetThemeVariant variant) async {
    if (_currentVariant == variant) return;
    _currentVariant = variant;
    _dynamicThemeConfig = null; // Clear dynamic theme when manually selecting a static one
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, variant.index);
    await prefs.remove(_dynamicThemeKey);
    notifyListeners();
  }

  Future<void> setDynamicTheme(ThemeConfig config) async {
    _dynamicThemeConfig = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dynamicThemeKey, json.encode(config.toJson()));
    notifyListeners();
  }

  String getVariantName(TiknetThemeVariant variant) {
    if (_dynamicThemeConfig != null) {
      return _dynamicThemeConfig!.appName;
    }
    switch (variant) {
      case TiknetThemeVariant.flatLightGreen:
        return 'Flat Light Green';
      case TiknetThemeVariant.elevatedDynamicBlue:
        return 'Elevated Dynamic Blue';
      case TiknetThemeVariant.pillRoundedDark:
        return 'Pill Rounded Dark';
      case TiknetThemeVariant.vibrantOrange:
        return 'Vibrant Orange';
    }
  }
}
