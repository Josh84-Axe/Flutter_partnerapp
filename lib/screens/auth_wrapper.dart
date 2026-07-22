import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/split/auth_provider.dart';
import '../providers/split/user_provider.dart';
import 'onboarding/smart_welcome_screen.dart';
import '../feature/auth/login_screen_m3.dart';
import 'subscription_management_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _skipWelcomeScreen = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Check the new skip_universal_welcome key
      final skipWelcome = prefs.getBool('skip_universal_welcome') ?? false;
      
      if (mounted) {
        setState(() {
          _skipWelcomeScreen = skipWelcome;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _skipWelcomeScreen = false;
          _isLoading = false;
        });
      }
    }

    if (_skipWelcomeScreen) {
      if (mounted) {
        context.read<AuthProvider>().checkAuthStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Always show the welcome screen unless explicitly skipped
    if (!_skipWelcomeScreen) {
      return const SmartWelcomeScreen();
    }

    final authProvider = context.watch<AuthProvider>();
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return const LoginScreenM3();
    }

    final userProvider = context.watch<UserProvider>();
    
    if (!userProvider.isSubscriptionLoaded && !userProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userProvider.loadSubscription();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!userProvider.isSubscriptionLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final subscription = userProvider.subscription;
    
    bool needsSubscription = subscription == null || !subscription.isActive;
    
    if (needsSubscription) {
      int daysSinceExpiration = 0;
      if (subscription != null) {
        daysSinceExpiration = DateTime.now().difference(subscription.renewalDate ?? DateTime.now()).inDays;
      } else {
        daysSinceExpiration = 0;
      }

      bool isGracePeriod = daysSinceExpiration <= 5;
      
      if (!isGracePeriod) {
        return const SubscriptionManagementScreen(canDismiss: false);
      } else if (!userProvider.hasSkippedSubscriptionCheck) {
        return const SubscriptionManagementScreen(canDismiss: true);
      }
    }

    return const HomeScreen();
  }
}
