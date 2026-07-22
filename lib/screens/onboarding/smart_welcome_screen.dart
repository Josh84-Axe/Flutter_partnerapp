import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VariantOption {
  final String variant;
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final Color primaryColor;
  final Color bgColor;

  const VariantOption({
    required this.variant,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.primaryColor,
    required this.bgColor,
  });
}

class SmartWelcomeScreen extends StatefulWidget {
  const SmartWelcomeScreen({super.key});

  @override
  State<SmartWelcomeScreen> createState() => _SmartWelcomeScreenState();
}

class _SmartWelcomeScreenState extends State<SmartWelcomeScreen> with SingleTickerProviderStateMixin {
  String? _selectedVariant;
  late AnimationController _controller;
  bool _skipNextTime = false;

  static const List<VariantOption> _variants = [
    VariantOption(
      variant: 'partner',
      icon: Icons.business_center_rounded,
      titleKey: 'onboarding.commercialTitle',
      subtitleKey: 'onboarding.commercialSubtitle',
      primaryColor: Color(0xFF2D7D46),
      bgColor: Color(0xFFE8F5E9),
    ),
    VariantOption(
      variant: 'family',
      icon: Icons.family_restroom_rounded,
      titleKey: 'onboarding.familyTitle',
      subtitleKey: 'onboarding.familySubtitle',
      primaryColor: Color(0xFF1565C0),
      bgColor: Color(0xFFE3F2FD),
    ),
    VariantOption(
      variant: 'campus',
      icon: Icons.school_rounded,
      titleKey: 'onboarding.campusTitle',
      subtitleKey: 'onboarding.campusSubtitle',
      primaryColor: Color(0xFF6A1B9A),
      bgColor: Color(0xFFF3E5F5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continueToTour() async {
    if (_selectedVariant == null) return;
    Navigator.of(context).pushNamed(
      '/dynamic-tour',
      arguments: _selectedVariant,
    );
  }

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (_skipNextTime) {
      await prefs.setBool('skip_universal_welcome', true);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Image.asset('assets/images/logo_tiknet.png', height: 40),
                  const SizedBox(height: 16),
              Text(
                'onboarding.welcomeTitle'.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'onboarding.welcomeSubtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
              ),
              const SizedBox(height: 32),

              // Variant cards
              Expanded(
                child: ListView.separated(
                  itemCount: _variants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = _variants[index];
                    final isSelected = _selectedVariant == option.variant;

                    return _VariantCard(
                      option: option,
                      isSelected: isSelected,
                      animationDelay: Duration(milliseconds: 100 * index),
                      controller: _controller,
                      onTap: () => setState(() => _selectedVariant = option.variant),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // CTA button
              AnimatedOpacity(
                opacity: _selectedVariant != null ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedVariant != null ? _continueToTour : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedVariant == null
                          ? 'onboarding.selectOption'.tr()
                          : 'onboarding.continueWith'.tr(args: [_getLabel(_selectedVariant!)]),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skip next time checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _skipNextTime,
                    onChanged: (value) => setState(() => _skipNextTime = value ?? false),
                    activeColor: colorScheme.primary,
                  ),
                  Text(
                    'Skip this screen on next launch',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              // Login button
              Center(
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text('onboarding.login'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
  ),
);
}

  String _getLabel(String variant) {
    switch (variant) {
      case 'family':
        return 'onboarding.familyTitle'.tr();
      case 'campus':
        return 'onboarding.campus'.tr();
      default:
        return 'onboarding.commercial'.tr();
    }
  }
}

class _VariantCard extends StatelessWidget {
  final VariantOption option;
  final bool isSelected;
  final Duration animationDelay;
  final AnimationController controller;
  final VoidCallback onTap;

  const _VariantCard({
    required this.option,
    required this.isSelected,
    required this.animationDelay,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => child!,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? option.bgColor : colorScheme.surfaceContainerLowest,
            border: Border.all(
              color: isSelected ? option.primaryColor : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: option.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? option.primaryColor
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  option.icon,
                  size: 28,
                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.titleKey.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? option.primaryColor : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitleKey.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? option.primaryColor : colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? option.primaryColor : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
