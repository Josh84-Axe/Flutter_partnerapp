import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../motion/m3_motion.dart';
import '../../flavors.dart';

class DynamicTourScreen extends StatefulWidget {
  const DynamicTourScreen({super.key});

  @override
  State<DynamicTourScreen> createState() => _DynamicTourScreenState();
}

class _DynamicTourScreenState extends State<DynamicTourScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  late final List<_OnboardingPage> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _getPagesForVariant(F.name);
  }

  List<_OnboardingPage> _getPagesForVariant(String variant) {
    if (variant == 'family') {
      return [
        _OnboardingPage(
          icon: Icons.pause_circle_filled_rounded,
          title: 'onboarding.tour.family.slide1Title'.tr(),
          subtitle: 'onboarding.tour.family.slide1Subtitle'.tr(),
        ),
        _OnboardingPage(
          icon: Icons.bedtime_rounded,
          title: 'onboarding.tour.family.slide2Title'.tr(),
          subtitle: 'onboarding.tour.family.slide2Subtitle'.tr(),
        ),
      ];
    } else if (variant == 'campus') {
      return [
        _OnboardingPage(
          icon: Icons.data_usage_rounded,
          title: 'onboarding.tour.campus.slide1Title'.tr(),
          subtitle: 'onboarding.tour.campus.slide1Subtitle'.tr(),
        ),
        _OnboardingPage(
          icon: Icons.bolt_rounded,
          title: 'onboarding.tour.campus.slide2Title'.tr(),
          subtitle: 'onboarding.tour.campus.slide2Subtitle'.tr(),
        ),
      ];
    } else {
      // Default / Commercial Partner
      return [
        _OnboardingPage(
          icon: Icons.wifi_tethering_rounded,
          title: 'onboarding.tour.partner.slide1Title'.tr(),
          subtitle: 'onboarding.tour.partner.slide1Subtitle'.tr(),
        ),
        _OnboardingPage(
          icon: Icons.monitor_heart_rounded,
          title: 'onboarding.tour.partner.slide2Title'.tr(),
          subtitle: 'onboarding.tour.partner.slide2Subtitle'.tr(),
        ),
      ];
    }
  }

  Future<void> _finishTour({required bool isLogin}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    
    if (isLogin) {
      context.go('/login');
    } else {
      context.go('/register');
    }
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
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logo_tiknet.png',
                        height: 32,
                      ),
                      TextButton(
                        onPressed: () => _finishTour(isLogin: true),
                        child: Text('onboarding.tour.skip'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
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
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            page.icon,
                            size: 80,
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
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.subtitle,
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
            const SizedBox(height: 24),
            // CTA buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_currentIndex < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishTour(isLogin: false);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentIndex == _pages.length - 1 ? 'onboarding.tour.createAccount'.tr() : 'onboarding.tour.next'.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ).animate().scale(
                          duration: M3Motion.buttonBounce,
                          curve: M3Motion.bounce,
                        ),
                  ),
                  if (_currentIndex == _pages.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextButton(
                        onPressed: () => _finishTour(isLogin: true),
                        child: Text(
                          'already_have_account'.tr(),
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
                    ),
                ],
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
