import 'package:flutter/animation.dart';

/// Material 3 motion constants for Tiknet Partner App
/// Defines durations and curves for consistent animations across the app
class M3Motion {
  // Durations
  static const Duration splashFade = Duration(milliseconds: 650);
  static const Duration splashScale = Duration(milliseconds: 800);
  static const Duration slideIn = Duration(milliseconds: 420);
  static const Duration buttonBounce = Duration(milliseconds: 380);

  // Curves
  static const Curve decel = Curves.decelerate;
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve bounce = Curves.easeOutBack;
}
