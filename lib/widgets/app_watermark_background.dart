import 'package:flutter/material.dart';
import '../../flavors.dart';

/// Unified flavor-aware watermark background for all 3 app variants.
/// - Family:  Dark blue + cyan-teal glow, vector watermarks of homes/shields/wifi
/// - Partner: Light mint green + emerald glow, POS terminals/charts/handshakes
/// - Campus:  Clean white/slate + teal glow, graduation caps/books/wifi towers
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
    final Color strokeColor;

    switch (flavor) {
      case Flavor.partner:
        bgColor = const Color(0xFFDCFCE7);
        glowColor = const Color(0xFF4ADE80);
        strokeColor = const Color(0xFF064E3B);
        break;
      case Flavor.campus:
        bgColor = const Color(0xFFF8FAFC);
        glowColor = const Color(0xFF0D9488);
        strokeColor = const Color(0xFF0F766E);
        break;
      case Flavor.family:
      default:
        bgColor = const Color(0xFF0B192C);
        glowColor = const Color(0xFF00E676);
        strokeColor = const Color(0xFF00E676);
        break;
    }

    final double opacity = (flavor == Flavor.family) ? 0.06 : 0.08;
    final bool isDark = flavor == Flavor.family;

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
                  glowColor.withValues(alpha: isDark ? 0.18 : 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Watermark tile pattern
        Positioned.fill(
          child: CustomPaint(
            painter: _FlavorWatermarkPainter(
              flavor: flavor,
              strokeColor: strokeColor,
              opacity: opacity,
            ),
          ),
        ),
        // Child content
        child,
      ],
    );
  }
}

class _FlavorWatermarkPainter extends CustomPainter {
  final Flavor? flavor;
  final Color strokeColor;
  final double opacity;

  _FlavorWatermarkPainter({
    required this.flavor,
    required this.strokeColor,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = strokeColor.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.fill;

    const tileSize = 140.0;
    for (double x = 0; x < size.width + tileSize; x += tileSize) {
      for (double y = 0; y < size.height + tileSize; y += tileSize) {
        canvas.save();
        canvas.translate(x, y);
        switch (flavor) {
          case Flavor.partner:
            _drawPartnerTile(canvas, paint, fillPaint);
            break;
          case Flavor.campus:
            _drawCampusTile(canvas, paint, fillPaint);
            break;
          default:
            _drawFamilyTile(canvas, paint, fillPaint);
        }
        canvas.restore();
      }
    }
  }

  // --- FAMILY: Homes, WiFi, Shields, Devices ---
  void _drawFamilyTile(Canvas canvas, Paint paint, Paint fillPaint) {
    // Home outline
    canvas.drawPath(
      Path()
        ..moveTo(15, 30)
        ..lineTo(30, 18)
        ..lineTo(45, 30)
        ..lineTo(45, 48)
        ..lineTo(15, 48)
        ..close(),
      paint,
    );
    // Heart inside home
    canvas.drawPath(
      Path()
        ..moveTo(30, 38)
        ..cubicTo(27, 34, 23, 37, 26, 41)
        ..cubicTo(28, 43, 30, 45, 30, 45)
        ..cubicTo(30, 45, 32, 43, 34, 41)
        ..cubicTo(37, 37, 33, 34, 30, 38)
        ..close(),
      fillPaint,
    );
    // WiFi arcs
    canvas.drawArc(Rect.fromCircle(center: const Offset(90, 30), radius: 16), -0.8, 1.6, false, paint);
    canvas.drawArc(Rect.fromCircle(center: const Offset(90, 30), radius: 10), -0.8, 1.6, false, paint);
    canvas.drawCircle(const Offset(90, 30), 2, fillPaint);
    // Shield
    canvas.drawPath(
      Path()
        ..moveTo(30, 80)
        ..cubicTo(30, 80, 45, 75, 45, 80)
        ..cubicTo(45, 95, 30, 102, 30, 102)
        ..cubicTo(30, 102, 15, 95, 15, 80)
        ..cubicTo(15, 75, 30, 80, 30, 80)
        ..close(),
      paint,
    );
    // Laptop
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(75, 80, 24, 16), const Radius.circular(3)),
      paint,
    );
    canvas.drawLine(const Offset(70, 96), const Offset(104, 96), paint);
  }

  // --- PARTNER: POS Terminal, Growth Chart, Handshake, Payout Badge ---
  void _drawPartnerTile(Canvas canvas, Paint paint, Paint fillPaint) {
    // POS terminal body
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(15, 22, 30, 40), const Radius.circular(4)),
      paint,
    );
    // Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(19, 26, 22, 14), const Radius.circular(1)),
      fillPaint,
    );
    // Keypad dots
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawCircle(Offset(22.0 + col * 8, 46.0 + row * 7), 1.5, fillPaint);
      }
    }
    // Growth chart arrow
    canvas.drawLine(const Offset(80, 55), const Offset(92, 42), paint);
    canvas.drawLine(const Offset(92, 42), const Offset(102, 50), paint);
    canvas.drawLine(const Offset(102, 50), const Offset(118, 30), paint);
    // Arrowhead
    canvas.drawLine(const Offset(110, 30), const Offset(118, 30), paint);
    canvas.drawLine(const Offset(118, 30), const Offset(118, 38), paint);
    // Handshake (simplified)
    canvas.drawPath(
      Path()
        ..moveTo(22, 90)
        ..cubicTo(22, 90, 32, 82, 38, 88)
        ..cubicTo(44, 94, 54, 86, 54, 86),
      paint,
    );
    canvas.drawCircle(const Offset(38, 88), 3, fillPaint);
    // Payout badge
    canvas.drawCircle(const Offset(96, 108), 14, paint);
    canvas.drawLine(const Offset(96, 100), const Offset(96, 116), paint);
    canvas.drawLine(const Offset(91, 104), const Offset(101, 104), paint);
    canvas.drawLine(const Offset(91, 112), const Offset(101, 112), paint);
  }

  // --- CAMPUS: Graduation Cap, Book, WiFi Tower, Student Badge ---
  void _drawCampusTile(Canvas canvas, Paint paint, Paint fillPaint) {
    // Graduation cap board
    canvas.drawPath(
      Path()
        ..moveTo(30, 24)
        ..lineTo(58, 34)
        ..lineTo(30, 44)
        ..lineTo(2, 34)
        ..close(),
      paint,
    );
    // Tassel drop
    canvas.drawLine(const Offset(55, 36), const Offset(55, 50), paint);
    canvas.drawCircle(const Offset(55, 52), 2, fillPaint);
    // Gown sides
    canvas.drawLine(const Offset(16, 38), const Offset(12, 54), paint);
    canvas.drawLine(const Offset(44, 38), const Offset(48, 54), paint);
    // Open book
    canvas.drawPath(
      Path()
        ..moveTo(78, 44)
        ..cubicTo(78, 44, 90, 38, 102, 44)
        ..lineTo(102, 62)
        ..cubicTo(102, 62, 90, 56, 78, 62)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(102, 44)
        ..cubicTo(102, 44, 114, 38, 126, 44)
        ..lineTo(126, 62)
        ..cubicTo(126, 62, 114, 56, 102, 62)
        ..close(),
      paint,
    );
    canvas.drawLine(const Offset(102, 44), const Offset(102, 62), paint);
    // WiFi tower
    canvas.drawPath(
      Path()
        ..moveTo(32, 82)
        ..lineTo(18, 118)
        ..lineTo(46, 118)
        ..close(),
      paint,
    );
    canvas.drawLine(const Offset(22, 100), const Offset(42, 100), paint);
    canvas.drawArc(Rect.fromCircle(center: const Offset(32, 76), radius: 12), -2.3, 4.6, false, paint);
    canvas.drawCircle(const Offset(32, 76), 3, fillPaint);
    // Student badge
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(84, 84, 26, 32), const Radius.circular(4)),
      paint,
    );
    canvas.drawCircle(const Offset(97, 95), 4.5, paint);
    canvas.drawPath(
      Path()
        ..moveTo(90, 108)
        ..cubicTo(90, 104, 93, 102, 97, 102)
        ..cubicTo(101, 102, 104, 104, 104, 108),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FlavorWatermarkPainter oldDelegate) =>
      oldDelegate.flavor != flavor ||
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.opacity != opacity;
}
