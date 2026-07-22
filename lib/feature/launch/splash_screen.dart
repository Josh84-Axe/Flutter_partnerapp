import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../motion/m3_motion.dart';

/// Splash screen with logo fade+scale animation
/// Shows on every app launch, then routes to onboarding (first launch) or auth flow
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Check if user has completed onboarding first
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    
    // Perform IP Detection for language
    try {
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 1)));
      final response = await dio.get('https://api.country.is/');
      if (response.data != null && response.data['country'] != null) {
        final countryCode = response.data['country'] as String;
        const francophoneCountries = [
          'FR', 'CI', 'SN', 'CM', 'ML', 'BF', 'NE', 'TG', 'BJ', 'CD', 'CG', 'GA', 'MG', 'GN', 'BI', 'RW', 'TD', 'CF', 'GQ', 'DJ', 'KM', 'HT'
        ];
        if (francophoneCountries.contains(countryCode.toUpperCase())) {
          if (mounted) context.setLocale(const Locale('fr'));
        } else {
          if (mounted) context.setLocale(const Locale('en'));
        }
      }
    } catch (e) {
      if (kDebugMode) print('IP Localization error: $e');
    }

    // Wait for splash animation to complete (just briefly so it doesn't flash)
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (!mounted) return;
    
    if (hasCompletedOnboarding) {
      // User has seen onboarding, go to main auth flow
      // Navigate to root which will trigger AuthWrapper
      Navigator.of(context).pushReplacementNamed('/auth-wrapper');
    } else {
      // First launch, show smart welcome screen
      Navigator.of(context).pushReplacementNamed('/smart-welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.wifi_tethering,
            size: 72,
            color: scheme.onPrimaryContainer,
          ),
        )
            .animate()
            .fadeIn(
              duration: M3Motion.splashFade,
              curve: M3Motion.easeOut,
            )
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: M3Motion.splashScale,
              curve: M3Motion.decel,
            ),
      ),
    );
  }
}
