import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/split/auth_provider.dart';
import '../providers/split/user_provider.dart';
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
  bool _subscriptionTimeoutTriggered = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    // Safety net: force proceed after 3s if subscription loading stalls
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_subscriptionTimeoutTriggered) {
        setState(() {
          _subscriptionTimeoutTriggered = true;
        });
      }
    });
  }

  Future<void> _checkOnboarding() async {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      context.read<AuthProvider>().checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
    
    if (!userProvider.isSubscriptionLoaded && !_subscriptionTimeoutTriggered) {
      if (!userProvider.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProvider.loadSubscription();
        });
      }
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
