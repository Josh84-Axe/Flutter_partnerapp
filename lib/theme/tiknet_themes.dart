import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TiknetThemeVariant {
  flatLightGreen,
  elevatedDynamicBlue,
  pillRoundedDark,
}

class TiknetThemes {
  // Unified Material 3 base theme with consistent layout, shapes, and typography
  // Only color schemes differ between variants
  static ThemeData _base(ColorScheme scheme) {
    final textTheme = GoogleFonts.interTextTheme(
      Typography.material2021(platform: TargetPlatform.android).black,
    );
    
    // Enhanced color scheme with deeper, more outstanding colors
    final enhancedScheme = scheme.copyWith(
      // Make primary colors more vibrant and deep
      primary: _deepenColor(scheme.primary, 0.15),
      primaryContainer: _deepenColor(scheme.primaryContainer, 0.1),
      // Enhance secondary colors
      secondary: _deepenColor(scheme.secondary, 0.15),
      secondaryContainer: _deepenColor(scheme.secondaryContainer, 0.1),
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: enhancedScheme,
      textTheme: textTheme,
      
      // Unified AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: scheme.onSurface,
        ),
      ),
      
      // Unified Card theme - elevation 1, borderRadius 16
      cardTheme: CardThemeData(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Unified Input decoration - filled, borderRadius 16
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
      
      // Unified NavigationBar theme - height 72
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      
      // Unified button themes - borderRadius 16
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
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  // Flat Light Green Theme - deeper green with enhanced contrast
  static ThemeData getFlatLightGreenTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20), // Deeper green (was #2E7D32)
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  // Elevated Dynamic Blue Theme - deeper blue with richer tones
  static ThemeData getElevatedDynamicBlueTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1), // Deeper blue (was Colors.blue)
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  // Pill Rounded Dark Theme - deeper dark with richer teal
  static ThemeData getPillRoundedDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00897B), // Deeper teal (was #00BFA6)
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData getThemeForVariant(TiknetThemeVariant variant) {
    switch (variant) {
      case TiknetThemeVariant.flatLightGreen:
        return getFlatLightGreenTheme();
      case TiknetThemeVariant.elevatedDynamicBlue:
        return getElevatedDynamicBlueTheme();
      case TiknetThemeVariant.pillRoundedDark:
        return getPillRoundedDarkTheme();
    }
  }

  // Helper method to deepen colors for better contrast and depth
  static Color _deepenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    // Reduce lightness to deepen the color
    final deepened = hsl.withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0));
    // Increase saturation slightly for more vibrant colors
    final vibrant = deepened.withSaturation((deepened.saturation * 1.1).clamp(0.0, 1.0));
    return vibrant.toColor();
  }
}
