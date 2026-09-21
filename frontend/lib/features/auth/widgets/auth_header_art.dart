import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Top header banner with organic brand green gradient, travel landscape contours,
/// and custom vector bus artwork (Front View for Login, Side View for Register).
class AuthHeaderArt extends StatelessWidget {
  final bool isRegister;
  final bool isDarkMode;
  final double height;

  const AuthHeaderArt({
    super.key,
    required this.isRegister,
    required this.isDarkMode,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = isDarkMode
        ? [
            const Color(0xFF062814),
            const Color(0xFF0A3C1F),
            const Color(0xFF0F4E28),
          ]
        : [
            const Color(0xFF15803D),
            AppColors.green,
            AppColors.greenBright,
          ];

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Travel landscape contours, road trails & GPS pin
          Positioned.fill(
            child: CustomPaint(
              painter: _AuthTravelBackgroundPainter(isRegister: isRegister),
            ),
          ),

          // 2. Bus Artwork (Front-view for Login, Side-view for Register)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: isRegister
                  ? _RegisterBusArt(isDarkMode: isDarkMode)
                  : _LoginBusArt(isDarkMode: isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative travel scenery: rolling journey hills, dashed highway route curves, and GPS pin
class _AuthTravelBackgroundPainter extends CustomPainter {
  final bool isRegister;

  _AuthTravelBackgroundPainter({required this.isRegister});

  @override
  void paint(Canvas canvas, Size size) {
    final hillLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final hillFillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Distant rolling mountain / hill on left
    final hillPath1 = Path()
      ..moveTo(0, size.height * 0.70)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.38,
        size.width * 0.32,
        size.height * 0.48,
        size.width * 0.50,
        size.height * 0.75,
      )
      ..lineTo(0, size.height * 0.75)
      ..close();
    canvas.drawPath(hillPath1, hillFillPaint);
    canvas.drawPath(hillPath1, hillLinePaint);

    // Scenic rolling hill on right
    final hillPath2 = Path()
      ..moveTo(size.width * 0.45, size.height * 0.78)
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.36,
        size.width * 0.82,
        size.height * 0.44,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height * 0.78)
      ..close();
    canvas.drawPath(hillPath2, hillFillPaint);
    canvas.drawPath(hillPath2, hillLinePaint);

    // Curved highway route contour across the sky
    final routePath = Path()
      ..moveTo(0, size.height * 0.28)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.18,
        size.width * 0.38,
        size.height * 0.60,
        size.width * 0.70,
        size.height * 0.30,
      )
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.16,
        size.width * 0.94,
        size.height * 0.24,
        size.width,
        size.height * 0.20,
      );

    final routeLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(routePath, routeLinePaint);

    // Floating GPS destination waypoint pin
    _drawLocationPin(
      canvas,
      Offset(size.width * (isRegister ? 0.82 : 0.78), size.height * 0.22),
    );

    // Subtle twinkling journey stars / sparkles
    _drawSparkle(canvas, Offset(size.width * 0.15, size.height * 0.20), 4);
    _drawSparkle(canvas, Offset(size.width * 0.88, size.height * 0.42), 3);
    _drawSparkle(canvas, Offset(size.width * 0.36, size.height * 0.15), 2.5);
  }

  void _drawLocationPin(Canvas canvas, Offset center) {
    final pinPaint = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final pinOutline = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Pin head circle
    canvas.drawCircle(Offset(center.dx, center.dy - 4), 6, pinPaint);
    canvas.drawCircle(Offset(center.dx, center.dy - 4), 6, pinOutline);

    // Inner pin dot
    canvas.drawCircle(
      Offset(center.dx, center.dy - 4),
      2.2,
      Paint()..color = Colors.white,
    );

    // Pin point triangle
    final pointPath = Path()
      ..moveTo(center.dx - 4.5, center.dy - 2)
      ..lineTo(center.dx + 4.5, center.dy - 2)
      ..lineTo(center.dx, center.dy + 6)
      ..close();
    canvas.drawPath(pointPath, pinPaint);
    canvas.drawPath(pointPath, pinOutline);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. LOGIN BUS ARTWORK: Modern Luxury Express Coach (Front View)
// ─────────────────────────────────────────────────────────────────────────────
class _LoginBusArt extends StatelessWidget {
  final bool isDarkMode;

  const _LoginBusArt({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 125,
      child: CustomPaint(
        painter: _FrontBusPainter(isDarkMode: isDarkMode),
      ),
    );
  }
}

class _FrontBusPainter extends CustomPainter {
  final bool isDarkMode;

  _FrontBusPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    const cx = 90.0;

    // 1. Asphalt Road Base & Ground Shadow
    final groundRect = Rect.fromCenter(
      center: const Offset(cx, 114),
      width: 164,
      height: 18,
    );
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.45),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(groundRect);
    canvas.drawOval(groundRect, shadowPaint);

    // Perspective white center road dashed line
    final roadDashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx, 108), const Offset(cx, 120), roadDashPaint);

    // 2. Headlight Illumination Glow Cones (casting on asphalt)
    _drawHeadlightBeams(canvas, cx);

    // 3. Tires (Left and Right)
    final tirePaint = Paint()..color = const Color(0xFF0F172A);
    final rimPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Left Tire
    final leftTireRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx - 44, 80, 13, 26),
      const Radius.circular(5),
    );
    canvas.drawRRect(leftTireRRect, tirePaint);
    canvas.drawRRect(leftTireRRect, rimPaint);

    // Right Tire
    final rightTireRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx + 31, 80, 13, 26),
      const Radius.circular(5),
    );
    canvas.drawRRect(rightTireRRect, tirePaint);
    canvas.drawRRect(rightTireRRect, rimPaint);

    // 4. Aerodynamic Stalk Side Mirrors
    _drawSideMirrors(canvas, cx);

    // 5. Main Bus Body Chassis (Aerodynamic curved silhouette)
    final bodyRRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(cx - 43, 16, cx + 43, 102),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );

    // Lower Chassis: Trip-Z Green with rich gradient
    final lowerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.greenBright,
          AppColors.green,
          const Color(0xFF065F46),
        ],
      ).createShader(const Rect.fromLTRB(cx - 43, 56, cx + 43, 102));

    // Upper Chassis: Sleek pearl white
    final upperPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Color(0xFFF1F5F9),
        ],
      ).createShader(const Rect.fromLTRB(cx - 43, 16, cx + 43, 56));

    // Draw lower body
    canvas.drawRRect(bodyRRect, lowerPaint);

    // Clip upper body to top half
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(cx - 44, 15, cx + 44, 56));
    canvas.drawRRect(bodyRRect, upperPaint);
    canvas.restore();

    // Body outline stroke for crispness
    final bodyOutline = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(bodyRRect, bodyOutline);

    // Gold luxury accent separator trim line
    final goldTrimPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx - 42, 56), const Offset(cx + 42, 56), goldTrimPaint);

    // 6. Top Aerodynamic Roof AC Pod & Spoiler
    final acPodRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx - 20, 10, 40, 7),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(acPodRRect, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawRRect(
      acPodRRect,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Amber roof clearance marker LEDs
    final markerPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(const Offset(cx - 30, 20), 2.2, markerPaint);
    canvas.drawCircle(const Offset(cx + 30, 20), 2.2, markerPaint);

    // 7. Destination LED Board: "TRIP-Z • EXPRESS"
    final ledBoardRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx - 31, 21, 62, 13),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(ledBoardRRect, Paint()..color = const Color(0xFF090D16));
    canvas.drawRRect(
      ledBoardRRect,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Glowing LED Text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'TRIP-Z EXPRESS',
        style: TextStyle(
          color: Color(0xFFFCD34D),
          fontSize: 6.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - (textPainter.width / 2), 24),
    );

    // 8. Panoramic Tinted Windshield
    final windshieldRRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(cx - 37, 36, cx + 37, 66),
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );

    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E293B),
        ],
      ).createShader(windshieldRRect.outerRect);
    canvas.drawRRect(windshieldRRect, glassPaint);

    // Interior Driver Silhouette & Steering Wheel
    final interiorPaint = Paint()..color = const Color(0xFF090D16);
    canvas.drawCircle(const Offset(cx - 20, 50), 5.0, interiorPaint); // Driver head
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(cx - 20, 58), width: 14, height: 10),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Diagonal Glossy Glass Glare Reflection
    final glarePath = Path()
      ..moveTo(cx - 30, 37)
      ..lineTo(cx - 18, 37)
      ..lineTo(cx - 26, 65)
      ..lineTo(cx - 36, 65)
      ..close();
    canvas.drawPath(
      glarePath,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    // Windshield wipers at bottom
    final wiperPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(cx - 24, 65), const Offset(cx - 10, 60), wiperPaint);
    canvas.drawLine(const Offset(cx + 4, 65), const Offset(cx + 18, 60), wiperPaint);

    // 9. Front Chrome Slatted Grille & Luxury "Z" Emblem
    final grilleRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx - 23, 70, 46, 13),
      const Radius.circular(3),
    );
    canvas.drawRRect(grilleRRect, Paint()..color = const Color(0xFF0F172A));

    // Chrome slats
    final slatPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(cx - 20, 74), const Offset(cx + 20, 74), slatPaint);
    canvas.drawLine(const Offset(cx - 20, 77), const Offset(cx + 20, 77), slatPaint);
    canvas.drawLine(const Offset(cx - 20, 80), const Offset(cx + 20, 80), slatPaint);

    // Center Gold Shield & "Z" Emblem
    canvas.drawCircle(
      const Offset(cx, 76),
      4.5,
      Paint()..color = const Color(0xFFFBBF24),
    );
    final zTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Z',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 6.0,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    zTextPainter.paint(canvas, Offset(cx - (zTextPainter.width / 2), 72.5));

    // 10. Modern Curved LED Projector Headlights
    _drawHeadlights(canvas, cx);

    // 11. Lower Aerodynamic Bumper, Fog Lamps & License Plate
    // Fog lamps
    final fogPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(const Offset(cx - 31, 91), 2.5, fogPaint);
    canvas.drawCircle(const Offset(cx + 31, 91), 2.5, fogPaint);

    // License Plate
    final plateRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(cx - 15, 88, 30, 9),
      const Radius.circular(2),
    );
    canvas.drawRRect(plateRRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      plateRRect,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final platePainter = TextPainter(
      text: const TextSpan(
        text: 'TRIP-Z',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 5.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    platePainter.paint(
      canvas,
      Offset(cx - (platePainter.width / 2), 89.5),
    );
  }

  void _drawSideMirrors(Canvas canvas, double cx) {
    final mirrorBody = Paint()..color = const Color(0xFF0F172A);
    final stalkPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Left Mirror
    canvas.drawLine(Offset(cx - 41, 44), Offset(cx - 52, 40), stalkPaint);
    final leftPod = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 57, 36, 7, 18),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(leftPod, mirrorBody);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 55.5, 38, 4, 14),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Right Mirror
    canvas.drawLine(Offset(cx + 41, 44), Offset(cx + 52, 40), stalkPaint);
    final rightPod = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + 50, 36, 7, 18),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(rightPod, mirrorBody);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 51.5, 38, 4, 14),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF94A3B8),
    );
  }

  void _drawHeadlights(Canvas canvas, double cx) {
    // Modern angled LED projector housings
    final leftLampRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(cx - 40, 70, cx - 26, 81),
      topLeft: const Radius.circular(6),
      bottomLeft: const Radius.circular(4),
      topRight: const Radius.circular(2),
      bottomRight: const Radius.circular(6),
    );
    final rightLampRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(cx + 26, 70, cx + 40, 81),
      topRight: const Radius.circular(6),
      bottomRight: const Radius.circular(4),
      topLeft: const Radius.circular(2),
      bottomLeft: const Radius.circular(6),
    );

    // Dark housing
    canvas.drawRRect(leftLampRRect, Paint()..color = const Color(0xFF090D16));
    canvas.drawRRect(rightLampRRect, Paint()..color = const Color(0xFF090D16));

    // Bright Projector Cores
    final corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 33, 75.5), 3.2, corePaint);
    canvas.drawCircle(Offset(cx + 33, 75.5), 3.2, corePaint);

    // Cyan / Amber Daytime Running Light (DRL) eyebrows
    final drlPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 39, 71), Offset(cx - 27, 72), drlPaint);
    canvas.drawLine(Offset(cx + 39, 71), Offset(cx + 27, 72), drlPaint);
  }

  void _drawHeadlightBeams(Canvas canvas, double cx) {
    // Left Light Cone
    final leftBeam = Path()
      ..moveTo(cx - 33, 77)
      ..lineTo(cx - 68, 115)
      ..lineTo(cx - 15, 115)
      ..close();

    final beamShaderL = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.22),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTRB(cx - 68, 77, cx - 15, 115));
    canvas.drawPath(leftBeam, Paint()..shader = beamShaderL);

    // Right Light Cone
    final rightBeam = Path()
      ..moveTo(cx + 33, 77)
      ..lineTo(cx + 15, 115)
      ..lineTo(cx + 68, 115)
      ..close();

    final beamShaderR = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.22),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTRB(cx + 15, 77, cx + 68, 115));
    canvas.drawPath(rightBeam, Paint()..shader = beamShaderR);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. REGISTER BUS ARTWORK: Sleek Streamlined Travel Coach (Side 3/4 Profile)
// ─────────────────────────────────────────────────────────────────────────────
class _RegisterBusArt extends StatelessWidget {
  final bool isDarkMode;

  const _RegisterBusArt({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 125,
      child: CustomPaint(
        painter: _SideBusPainter(isDarkMode: isDarkMode),
      ),
    );
  }
}

class _SideBusPainter extends CustomPainter {
  final bool isDarkMode;

  _SideBusPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Asphalt Highway Strip & Dashed Lanes
    final roadRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 102, 206, 11),
      const Radius.circular(5.5),
    );
    canvas.drawRRect(
      roadRRect,
      Paint()
        ..color = const Color(0xFF0F172A).withValues(alpha: 0.65),
    );

    // White dashed highway lines
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(22, 107.5), const Offset(42, 107.5), dashPaint);
    canvas.drawLine(const Offset(58, 107.5), const Offset(84, 107.5), dashPaint);
    canvas.drawLine(const Offset(100, 107.5), const Offset(130, 107.5), dashPaint);
    canvas.drawLine(const Offset(146, 107.5), const Offset(176, 107.5), dashPaint);
    canvas.drawLine(const Offset(192, 107.5), const Offset(212, 107.5), dashPaint);

    // Aerodynamic speed wind streaks behind bus
    final windPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(6, 48), const Offset(26, 48), windPaint);
    canvas.drawLine(const Offset(14, 62), const Offset(28, 62), windPaint);
    canvas.drawLine(const Offset(10, 76), const Offset(24, 76), windPaint);

    // 2. Wheel Contact Shadows
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(68, 102), width: 62, height: 6),
      shadowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(170, 102), width: 34, height: 6),
      shadowPaint,
    );

    // 3. Main Bus Coach Body Silhouette
    // Rear: x = 32, Front nose: x = 196, Roof: y = 28, Skirt: y = 94
    final coachBodyPath = Path()
      ..moveTo(32, 34)
      ..quadraticBezierTo(32, 28, 40, 28) // Rear top spoiler curve
      ..lineTo(182, 28) // Long roofline
      ..quadraticBezierTo(192, 28, 196, 46) // Aerodynamic raked windshield slope
      ..lineTo(198, 68) // Front nose
      ..quadraticBezierTo(196, 94, 186, 94) // Front bumper curve
      ..lineTo(34, 94) // Bottom skirt
      ..quadraticBezierTo(32, 94, 32, 88) // Rear lower bumper
      ..close();

    // Fill upper body with pearl white
    canvas.drawPath(
      coachBodyPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFE2E8F0)],
        ).createShader(const Rect.fromLTWH(32, 28, 166, 66)),
    );

    // Lower chassis (Trip-Z Emerald Green)
    final lowerChassisPath = Path()
      ..moveTo(32, 64)
      ..lineTo(198, 64)
      ..lineTo(198, 68)
      ..quadraticBezierTo(196, 94, 186, 94)
      ..lineTo(34, 94)
      ..quadraticBezierTo(32, 94, 32, 88)
      ..close();

    canvas.save();
    canvas.clipPath(coachBodyPath);
    canvas.drawPath(
      lowerChassisPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.greenBright,
            AppColors.green,
            const Color(0xFF047857),
          ],
        ).createShader(const Rect.fromLTWH(32, 64, 166, 30)),
    );

    // Dynamic Speed Swoop Livery (Lime Green & Amber Ribbon)
    final swoopPath = Path()
      ..moveTo(194, 76)
      ..cubicTo(150, 72, 100, 56, 42, 38)
      ..lineTo(38, 44)
      ..cubicTo(96, 62, 146, 80, 190, 84)
      ..close();
    canvas.drawPath(
      swoopPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFBBF24),
            AppColors.greenBright,
          ],
        ).createShader(const Rect.fromLTWH(38, 38, 156, 46)),
    );
    canvas.restore();

    // Body crisp boundary outline
    canvas.drawPath(
      coachBodyPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // 4. Roof Aerodynamic AC Unit
    final acRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(75, 22, 60, 7),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(acRRect, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRRect(
      acRRect,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    // 5. Panoramic Tinted Window Ribbon
    final windowRibbonPath = Path()
      ..moveTo(40, 34)
      ..lineTo(178, 34)
      ..quadraticBezierTo(188, 34, 192, 48) // Front windshield slope
      ..lineTo(192, 58)
      ..lineTo(40, 58)
      ..close();

    canvas.drawPath(
      windowRibbonPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        ).createShader(const Rect.fromLTWH(40, 34, 152, 24)),
    );

    // Warm Ambient Passenger Cabin Glow (Interior travel lights)
    final cabinGlowPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final winX = 46.0 + (i * 22.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(winX, 36, 17, 10),
          const Radius.circular(2),
        ),
        cabinGlowPaint,
      );
    }

    // Window Mullion Pillars (Dividers)
    final mullionPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.0;
    for (int i = 1; i <= 5; i++) {
      final px = 42.0 + (i * 22.0);
      canvas.drawLine(Offset(px, 34), Offset(px, 58), mullionPaint);
    }

    // Diagonal Glass Glare Streaks
    final glassGlarePath = Path()
      ..moveTo(70, 34)
      ..lineTo(82, 34)
      ..lineTo(70, 58)
      ..lineTo(58, 58)
      ..close();
    canvas.drawPath(
      glassGlarePath,
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );

    // 6. Bold "TRIP-Z" Branding on Side Coach Panel
    final brandPainter = TextPainter(
      text: const TextSpan(
        text: 'TRIP-Z',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    brandPainter.paint(canvas, const Offset(96, 63));

    // 7. Passenger Entry Door & Luggage Compartments
    // Door seam line
    final seamPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.35)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(164, 34), const Offset(164, 94), seamPaint);

    // Luggage bay doors (Under-floor cargo hatches)
    final cargoPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (int i = 0; i < 3; i++) {
      final cxBay = 98.0 + (i * 20.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cxBay, 76, 17, 14),
          const Radius.circular(2),
        ),
        cargoPaint,
      );
      // Recessed chrome handle
      canvas.drawLine(
        Offset(cxBay + 6, 80),
        Offset(cxBay + 11, 80),
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // 8. Front Wrap-around Headlight & Rear LED Taillight
    // Front LED Headlight
    final headlightPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(193, 66, 5, 8),
        topRight: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      headlightPaint,
    );
    // Amber blinker
    canvas.drawCircle(
      const Offset(195, 76),
      1.6,
      Paint()..color = const Color(0xFFF59E0B),
    );

    // Rear Red Taillight Strip
    final taillightPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(32.5, 62), const Offset(32.5, 78), taillightPaint);

    // Front Side Mirror Stalk
    final mirrorStalk = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(190, 44), const Offset(199, 41), mirrorStalk);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(198, 38, 4.5, 9),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );

    // 9. Wheels & Wheel Arches
    // Rear Dual Axles (2 wheels for luxury coach) + Front Axle (1 wheel)
    _drawWheel(canvas, 54, 94);
    _drawWheel(canvas, 78, 94);
    _drawWheel(canvas, 170, 94);
  }

  void _drawWheel(Canvas canvas, double cx, double cy) {
    // Wheel Arch Cutout (Dark Liner)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 30),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF090D16),
    );

    // Rubber Tire
    canvas.drawCircle(
      Offset(cx, cy),
      11.5,
      Paint()..color = const Color(0xFF0F172A),
    );

    // Silver Alloy Rim
    canvas.drawCircle(
      Offset(cx, cy),
      7.5,
      Paint()..color = const Color(0xFFCBD5E1),
    );

    // Rim inner ring
    canvas.drawCircle(
      Offset(cx, cy),
      5.0,
      Paint()..color = const Color(0xFF94A3B8),
    );

    // Green Center Hubcap
    canvas.drawCircle(
      Offset(cx, cy),
      2.5,
      Paint()..color = AppColors.green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
