import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Modal dialog shown upon successful registration matching Screen 3 from reference.
class RegistrationSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const RegistrationSuccessDialog({super.key, required this.onContinue});

  static Future<void> show(BuildContext context, {required VoidCallback onContinue}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => RegistrationSuccessDialog(
        onContinue: () {
          Navigator.of(ctx).pop();
          onContinue();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF15803D),
              AppColors.green,
              AppColors.greenBright,
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background contour wave
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 180,
              child: CustomPaint(
                painter: _DialogBackgroundPainter(),
              ),
            ),

            // Dialog Content
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Envelope & Checkmark Icon
                  _buildEnvelopeGraphic(),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'thank_you_for_registration'.tr,
                    textAlign: TextAlign.center,
                    style: AppFonts.dmSans(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subtitle / Description
                  Text(
                    'registration_success_desc'.tr,
                    textAlign: TextAlign.center,
                    style: AppFonts.dmSans(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Dark pill action button (matches reference black button)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C1917), // Deep charcoal black
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: onContinue,
                      child: Text(
                        'start_exploring'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildEnvelopeGraphic() {
    return SizedBox(
      width: 90,
      height: 75,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Yellow Envelope Base
          Container(
            width: 74,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24), // Amber/yellow envelope
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // Envelope Flap folds (drawn with border triangle)
          Positioned(
            top: 14,
            child: CustomPaint(
              size: const Size(74, 38),
              painter: _EnvelopeFlapPainter(),
            ),
          ),

          // Letter Paper sticking out
          Positioned(
            top: 2,
            child: Container(
              width: 58,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Verified Checkmark Badge at top-right of the paper
          Positioned(
            top: -4,
            right: 10,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF59E0B) // Darker yellow flap shadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Diagonal fold lines of envelope
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height * 0.4);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DialogBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Top right contour lines
    final path1 = Path();
    path1.moveTo(size.width * 0.4, 0);
    path1.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.3,
      size.width,
      size.height * 0.2,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.6, 0);
    path2.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.45,
      size.width,
      size.height * 0.35,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
