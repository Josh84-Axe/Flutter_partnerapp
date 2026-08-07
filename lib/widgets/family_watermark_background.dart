import 'package:flutter/material.dart';
import 'app_watermark_background.dart';

/// Reusable Watermark Background Widget (delegating to unified AppWatermarkBackground)
class FamilyWatermarkBackground extends StatelessWidget {
  final Widget child;

  const FamilyWatermarkBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppWatermarkBackground(child: child);
  }
}
