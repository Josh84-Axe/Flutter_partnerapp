import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onExploreDemo;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onExploreDemo,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              AppTheme.pureWhite,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  Icons.wifi_tethering,
                  size: 100,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'welcome_hub_title'.tr(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'welcome_hub_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onGetStarted,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('get_started'.tr()),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onExploreDemo,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('explore_demo'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
