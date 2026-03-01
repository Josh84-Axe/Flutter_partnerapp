import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../motion/m3_motion.dart';

/// Onboarding screen with 3 pages showing app features
/// Uses PageView with progress dots and bouncy CTA buttons
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.people_alt_rounded,
      title: 'onboarding_title_1',
      subtitle: 'onboarding_subtitle_1',
    ),
    _OnboardingPage(
      icon: Icons.signal_cellular_alt_rounded,
      title: 'onboarding_title_2',
      subtitle: 'onboarding_subtitle_2',
    ),
    _OnboardingPage(
      icon: Icons.public_rounded,
      title: 'onboarding_title_3',
      subtitle: 'onboarding_subtitle_3',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            page.icon,
                            size: 72,
                            color: scheme.onPrimaryContainer,
                          ),
                        )
                            .animate()
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: M3Motion.slideIn,
                              curve: M3Motion.easeOut,
                            )
                            .fadeIn(duration: M3Motion.slideIn),
                        const SizedBox(height: 32),
                        Text(
                          page.title.tr(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.subtitle.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: isActive ? 22 : 8,
                  decoration: BoxDecoration(
                    color: isActive ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // CTA buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _completeOnboarding,
                      child: Text('login'.tr()),
                    ).animate().scale(
                          duration: M3Motion.buttonBounce,
                          curve: M3Motion.bounce,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _completeOnboarding,
                      child: Text('get_started'.tr()),
                    ).animate().scale(
                          duration: M3Motion.buttonBounce,
                          curve: M3Motion.bounce,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
