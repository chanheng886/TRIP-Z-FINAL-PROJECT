import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AiChatTypingIndicator extends StatefulWidget {
  final bool isDark;

  const AiChatTypingIndicator({super.key, required this.isDark});

  @override
  State<AiChatTypingIndicator> createState() => _AiChatTypingIndicatorState();
}

class _AiChatTypingIndicatorState extends State<AiChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg =
        widget.isDark ? const Color(0xFF1E222B) : const Color(0xFFF8FAFC);
    final borderColor =
        widget.isDark ? const Color(0xFF2C3240) : const Color(0xFFE2E8F0);
    final textSecondary =
        widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mini Robot Avatar
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green, AppColors.greenBright],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.robot,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Typing Bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: widget.isDark ? 0.25 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedDot(0),
                  const SizedBox(width: 5),
                  _buildAnimatedDot(0.2),
                  const SizedBox(width: 5),
                  _buildAnimatedDot(0.4),
                  const SizedBox(width: 10),
                  Text(
                    'TripZ AI is thinking...',
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
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

  Widget _buildAnimatedDot(double delayOffset) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = (_controller.value - delayOffset) % 1.0;
        final double bounce = (1.0 - (t - 0.5).abs() * 2.0).clamp(0.0, 1.0);
        final double scale = 0.8 + 0.4 * bounce;
        final double opacity = 0.35 + 0.65 * bounce;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
