import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TiknetThemeVariant {
  flatLightGreen,
  elevatedDynamicBlue,
  pillRoundedDark,
}

class TiknetThemes {
  // Flat Light Green Theme Colors
  static const Color flatGreenPrimary = Color(0xFF95FF39);
  static const Color flatGreenLight = Color(0xFF4CAF50);
  static const Color flatGreenBackground = Color(0xFFF6F7F8);
  static const Color flatGreenSurface = Color(0xFFFFFFFF);
  static const Color flatGreenText = Color(0xFF212121);
  static const Color flatGreenTextLight = Color(0xFF757575);

  // Elevated Dynamic Blue Theme Colors
  static const Color dynamicBluePrimary = Color(0xFF2196F3);
  static const Color dynamicBlueLight = Color(0xFF64B5F6);
  static const Color dynamicBlueDark = Color(0xFF1976D2);
  static const Color dynamicBlueBackground = Color(0xFFE3F2FD);
  static const Color dynamicBlueSurface = Color(0xFFBBDEFB);
  static const Color dynamicBlueText = Color(0xFF0D47A1);
  static const Color dynamicBlueTextLight = Color(0xFF1565C0);

  // Pill Rounded Dark Theme Colors
  static const Color darkPrimary = Color(0xFF00BCD4);
  static const Color darkPrimaryLight = Color(0xFF26C6DA);
  static const Color darkBackground = Color(0xFF101922);
  static const Color darkSurface = Color(0xFF1A2634);
  static const Color darkSurfaceVariant = Color(0xFF2C3E50);
  static const Color darkText = Color(0xFFE5E7EB);
  static const Color darkTextLight = Color(0xFF9CA3AF);

  // Common Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  static ThemeData getFlatLightGreenTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: flatGreenPrimary,
        brightness: Brightness.light,
        primary: flatGreenPrimary,
        secondary: flatGreenLight,
        surface: flatGreenSurface,
        error: errorRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: flatGreenText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: flatGreenText,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: flatGreenText,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: flatGreenText,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: flatGreenTextLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: flatGreenPrimary,
        foregroundColor: flatGreenText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: flatGreenText),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: flatGreenText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: flatGreenSurface,
        indicatorColor: flatGreenPrimary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: flatGreenPrimary,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            color: flatGreenTextLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: flatGreenPrimary);
          }
          return const IconThemeData(color: flatGreenTextLight);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: flatGreenSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: flatGreenTextLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: flatGreenPrimary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(),
        hintStyle: GoogleFonts.poppins(color: flatGreenTextLight),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: flatGreenPrimary,
          foregroundColor: flatGreenText,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData getElevatedDynamicBlueTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dynamicBluePrimary,
        brightness: Brightness.light,
        primary: dynamicBluePrimary,
        secondary: dynamicBlueLight,
        surface: dynamicBlueSurface,
        error: errorRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: dynamicBlueText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: dynamicBlueText,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: dynamicBlueText,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: dynamicBlueText,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: dynamicBlueTextLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dynamicBlueDark,
        foregroundColor: Colors.white,
        surfaceTintColor: dynamicBlueLight,
        elevation: 4,
        shadowColor: dynamicBluePrimary.withValues(alpha: 0.3),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dynamicBlueDark,
        indicatorColor: dynamicBluePrimary.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: Colors.white70);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: dynamicBluePrimary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: dynamicBlueDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dynamicBlueTextLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dynamicBluePrimary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: dynamicBlueText),
        hintStyle: GoogleFonts.poppins(color: dynamicBlueTextLight),
        filled: true,
        fillColor: dynamicBlueBackground,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dynamicBluePrimary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  static ThemeData getPillRoundedDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimary,
        brightness: Brightness.dark,
        primary: darkPrimary,
        secondary: darkPrimaryLight,
        surface: darkSurface,
        error: errorRed,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: darkText,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: darkTextLight,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        surfaceTintColor: darkPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkPrimary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkPrimary,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 12,
            color: darkTextLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkPrimary);
          }
          return const IconThemeData(color: darkTextLight);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: darkSurfaceVariant,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: darkTextLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: darkText),
        hintStyle: GoogleFonts.poppins(color: darkTextLight),
        filled: true,
        fillColor: darkSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkBackground,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
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
}
