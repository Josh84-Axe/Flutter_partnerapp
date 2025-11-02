import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import 'carousel_screen.dart';
import 'welcome_screen.dart';
import 'get_started_screen.dart';
import 'explore_demo_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _currentStep = 0;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  Future<void> _completeOnboarding() async {
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
          onExploreDemo: () => setState(() => _currentStep = 4),
        );
      case 3:
        return GetStartedScreen(
          onSignUp: _completeOnboarding,
          onLogin: _completeOnboarding,
          onContinueAsGuest: () => setState(() => _currentStep = 4),
        );
      case 4:
        return ExploreDemoScreen(onSignUpNow: _completeOnboarding);
      default:
        return SplashScreen(onComplete: _nextStep);
    }
  }
}
