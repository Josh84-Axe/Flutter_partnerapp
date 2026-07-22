import 'package:flutter/material.dart';

class ThemeConfig {
  final String primaryColorHex;
  final String secondaryColorHex;
  final String? fontFamily;
  final bool isDarkMode;
  final String appName;

  ThemeConfig({
    required this.primaryColorHex,
    required this.secondaryColorHex,
    this.fontFamily,
    this.isDarkMode = false,
    required this.appName,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      primaryColorHex: json['primaryColorHex'] ?? '#2E7D32', // Default Partner Green
      secondaryColorHex: json['secondaryColorHex'] ?? '#4CAF50',
      fontFamily: json['fontFamily'],
      isDarkMode: json['isDarkMode'] ?? false,
      appName: json['appName'] ?? 'Tiknet Partner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
      'fontFamily': fontFamily,
      'isDarkMode': isDarkMode,
      'appName': appName,
    };
  }

  // Fallback default theme for Partner app
  static ThemeConfig get defaultPartnerTheme => ThemeConfig(
    primaryColorHex: '#2E7D32',
    secondaryColorHex: '#4CAF50',
    fontFamily: 'Inter',
    isDarkMode: false,
    appName: 'Tiknet Partner',
  );

  // Fallback for Family app (until API is ready)
  static ThemeConfig get defaultFamilyTheme => ThemeConfig(
    primaryColorHex: '#1976D2', // Family Blue
    secondaryColorHex: '#64B5F6',
    fontFamily: 'Inter',
    isDarkMode: false,
    appName: 'Tiknet Family',
  );
}
