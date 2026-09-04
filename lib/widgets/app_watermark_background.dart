import 'package:flutter/material.dart';
import '../../flavors.dart';

/// Unified flavor-aware plain background for all 3 app variants.
/// - Family:  Soft light ivory canvas (#FDFBF7) + warm amber radial glow (#FEF3C7)
/// - Partner: Light mint green canvas (#DCFCE7) + emerald radial glow (#4ADE80)
/// - Campus:  Clean slate white canvas (#F8FAFC) + teal radial glow (#0D9488)
class AppWatermarkBackground extends StatelessWidget {
  final Widget child;

  const AppWatermarkBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final flavor = F.appFlavor;
    return _FlavorBackground(flavor: flavor, child: child);
  }
}

class _FlavorBackground extends StatelessWidget {
  final Flavor? flavor;
  final Widget child;

  const _FlavorBackground({required this.flavor, required this.child});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color glowColor;

    switch (flavor) {
      case Flavor.partner:
        bgColor = const Color(0xFFDCFCE7);
        glowColor = const Color(0xFF4ADE80);
        break;
      case Flavor.campus:
        bgColor = const Color(0xFFF8FAFC);
        glowColor = const Color(0xFF0D9488);
        break;
      case Flavor.family:
      default:
        bgColor = const Color(0xFFFDFBF7);
        glowColor = const Color(0xFFFEF3C7);
        break;
    }

    return Stack(
      children: [
        // Base background
        Container(color: bgColor),
        // Radial ambient glow
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.4,
                colors: [
                  glowColor.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Child content
        child,
      ],
    );
  }
}
