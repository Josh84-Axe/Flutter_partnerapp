import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/theme_config_model.dart';
import 'tiknet_themes.dart'; // To reuse the base layout

class DynamicTheme {
  /// Converts a hex string (e.g., '#RRGGBB' or 'RRGGBB') to a Color object.
  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add opacity if missing
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Generates a ThemeData from the dynamic ThemeConfig from the API.
  static ThemeData buildTheme(ThemeConfig config) {
    final primaryColor = _hexToColor(config.primaryColorHex);
    final secondaryColor = _hexToColor(config.secondaryColorHex);

    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
      brightness: config.isDarkMode ? Brightness.dark : Brightness.light,
    );

    // Get the base theme from TiknetThemes to reuse all the button/input shapes
    final baseTheme = _getBaseTheme(scheme);

    // Apply the custom font family if provided by the API
    if (config.fontFamily != null && config.fontFamily!.isNotEmpty) {
      try {
        final textTheme = GoogleFonts.getTextTheme(
          config.fontFamily!,
          baseTheme.textTheme,
        );
        return baseTheme.copyWith(textTheme: textTheme);
      } catch (e) {
        // Fallback if font isn't loaded
        return baseTheme;
      }
    }

    return baseTheme;
  }

  // Reuse the existing _base layout method logic from TiknetThemes
  static ThemeData _getBaseTheme(ColorScheme scheme) {
    final textTheme = GoogleFonts.interTextTheme(
      scheme.brightness == Brightness.dark
          ? Typography.material2021(platform: TargetPlatform.android).white
          : Typography.material2021(platform: TargetPlatform.android).black,
    );
    
    // We deep copy the styling from tiknet_themes to keep consistency
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.brightness == Brightness.dark
            ? const Color(0xFF121212)
            : scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
      ),
      scaffoldBackgroundColor: scheme.brightness == Brightness.dark
          ? const Color(0xFF121212)
          : scheme.surface,
      cardTheme: CardThemeData(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
