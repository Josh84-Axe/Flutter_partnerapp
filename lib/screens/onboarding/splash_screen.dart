import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

import '../../flavors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              F.appFlavor == Flavor.family
                  ? 'assets/images/family_shield_logo_light.png'
                  : 'assets/images/partner_shield_logo_light.png',
              height: 80,
              fit: BoxFit.contain,
            ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),
            const SizedBox(height: 24),
            Text(
              'Your Success Portal',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
