import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// A model describing each available app variant the user can choose from.
class VariantOption {
  final String variant;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color bgColor;

  const VariantOption({
    required this.variant,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.bgColor,
  });
}

/// Self-Service Variant Selection Screen.
///
/// Shown during onboarding before the user signs up. The user picks which
/// type of account they want — Commercial, Family, or Campus. The chosen
/// [selectedVariant] string is passed back to [onVariantSelected] and then
/// forwarded to the registration API as `app_variant`.
class VariantSelectionScreen extends StatefulWidget {
  final void Function(String selectedVariant) onVariantSelected;

  const VariantSelectionScreen({super.key, required this.onVariantSelected});

  @override
  State<VariantSelectionScreen> createState() => _VariantSelectionScreenState();
}

class _VariantSelectionScreenState extends State<VariantSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedVariant;
  late AnimationController _controller;

  static const List<VariantOption> _variants = [
    VariantOption(
      variant: 'partner',
      icon: Icons.business_center_rounded,
      title: 'Commercial Hotspot',
      subtitle: 'Manage vouchers, billing & bandwidth for your customers.',
      primaryColor: Color(0xFF2D7D46),
      bgColor: Color(0xFFE8F5E9),
    ),
    VariantOption(
      variant: 'family',
      icon: Icons.family_restroom_rounded,
      title: 'Home & Family',
      subtitle: 'Manage kids\' devices, screen time & bedtime schedules.',
      primaryColor: Color(0xFF1565C0),
      bgColor: Color(0xFFE3F2FD),
    ),
    VariantOption(
      variant: 'campus',
      icon: Icons.school_rounded,
      title: 'Campus & Education',
      subtitle: 'Manage student access, safe browsing & network quotas.',
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'How will you use\nTiknet?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the plan that fits your needs. You can always upgrade later.',
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
                    onPressed: _selectedVariant != null
                        ? () => widget.onVariantSelected(_selectedVariant!)
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedVariant == null
                          ? 'Select an option to continue'
                          : 'Continue with ${_getLabel(_selectedVariant!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _getLabel(String variant) {
    switch (variant) {
      case 'family':
        return 'Home & Family';
      case 'campus':
        return 'Campus';
      default:
        return 'Commercial';
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
              // Icon badge
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
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? option.primaryColor : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
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
              // Selection indicator
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
