import 'package:flutter/material.dart';

class HomeMapBackgroundPainter extends CustomPainter {
  final bool isDarkMode;

  HomeMapBackgroundPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final roadColor = isDarkMode
        ? const Color(0xFF222630).withValues(alpha: 0.5)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.6);

    final roadSecondaryColor = isDarkMode
        ? const Color(0xFF1A1D24).withValues(alpha: 0.4)
        : const Color(0xFFEDF2F7).withValues(alpha: 0.7);

    final roadPaint = Paint()
      ..color = roadColor
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryPaint = Paint()
      ..color = roadSecondaryColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final blockPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF171A21).withValues(alpha: 0.3)
          : const Color(0xFFF1F5F9).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Draw some subtle city blocks
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, 10, size.width * 0.35, 60),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.48, 15, size.width * 0.45, 50),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, 90, size.width * 0.3, 70),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Grid / Diagonal street network
    final path1 = Path()
      ..moveTo(-20, 40)
      ..lineTo(size.width * 0.45, 30)
      ..lineTo(size.width * 0.8, 100)
      ..lineTo(size.width + 20, 110);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.45, -20)
      ..lineTo(size.width * 0.45, 180)
      ..lineTo(size.width * 0.6, 240);
    canvas.drawPath(path2, roadPaint);

    final path3 = Path()
      ..moveTo(-10, 130)
      ..lineTo(size.width * 0.35, 120)
      ..lineTo(size.width * 0.75, 180)
      ..lineTo(size.width + 20, 170);
    canvas.drawPath(path3, secondaryPaint);

    final path4 = Path()
      ..moveTo(size.width * 0.2, -10)
      ..lineTo(size.width * 0.2, 200);
    canvas.drawPath(path4, secondaryPaint);

    final path5 = Path()
      ..moveTo(size.width * 0.75, -10)
      ..lineTo(size.width * 0.75, 220);
    canvas.drawPath(path5, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant HomeMapBackgroundPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode;
  }
}
