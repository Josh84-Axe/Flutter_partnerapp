import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/tiknet_themes.dart';
import '../models/theme_config_model.dart';
import '../theme/dynamic_theme.dart';
import '../flavors.dart';
import 'dart:convert';

class ThemeProvider with ChangeNotifier {
  ThemeConfig? _dynamicThemeConfig;
  static const String _dynamicThemeKey = 'dynamicThemeConfig';

  TiknetThemeVariant get currentVariant {
    switch (F.appFlavor) {
      case Flavor.campus:
        return TiknetThemeVariant.vibrantOrange;
      case Flavor.family:
        return TiknetThemeVariant.elevatedDynamicBlue;
      case Flavor.partner:
      default:
        return TiknetThemeVariant.flatLightGreen;
    }
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
    return currentVariant == TiknetThemeVariant.pillRoundedDark
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
    // No-op for compile-time theming
  }

  String getVariantName(TiknetThemeVariant variant) {
    if (_dynamicThemeConfig != null) {
      return _dynamicThemeConfig!.appName;
    }
    switch (F.appFlavor) {
      case Flavor.family:
        return 'Tiknet Family';
      case Flavor.campus:
        return 'Tiknet Campus';
      case Flavor.partner:
      default:
        return 'Tiknet Partner';
    }
  }
}
