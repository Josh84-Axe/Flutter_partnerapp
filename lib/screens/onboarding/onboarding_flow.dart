import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'carousel_screen.dart';
import 'welcome_screen.dart';
import 'variant_selection_screen.dart';
import 'get_started_screen.dart';
import 'explore_demo_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _currentStep = 0;

  /// Holds the variant chosen on VariantSelectionScreen so it can be
  /// forwarded to RegistrationScreen as a route argument.
  String _selectedVariant = 'partner';

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      // Pass the chosen variant so RegistrationScreen can include it in the API call.
      Navigator.of(context).pushReplacementNamed(
        '/register',
        arguments: {'app_variant': _selectedVariant},
      );
    }
  }

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return SplashScreen(onComplete: _nextStep);
      case 1:
        return CarouselScreen(onComplete: _nextStep);
      case 2:
        return WelcomeScreen(
          onGetStarted: _nextStep,
          onExploreDemo: () => setState(() => _currentStep = 5),
        );
      case 3:
        // NEW: Variant selection — user picks Commercial / Family / Campus
        return VariantSelectionScreen(
          onVariantSelected: (variant) {
            setState(() {
              _selectedVariant = variant;
              _currentStep++;
            });
          },
        );
      case 4:
        return GetStartedScreen(
          onSignUp: _completeOnboarding,
          onLogin: _goToLogin,
          onContinueAsGuest: () => setState(() => _currentStep = 5),
        );
      case 5:
        return ExploreDemoScreen(onSignUpNow: _completeOnboarding);
      default:
        return SplashScreen(onComplete: _nextStep);
    }
  }
}
