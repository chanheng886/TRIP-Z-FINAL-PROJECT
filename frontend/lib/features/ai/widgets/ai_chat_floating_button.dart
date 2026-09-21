import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/ai/view/ai_chat_bottom_sheet.dart';

/// Standalone circular AI Assistant Button with pulse animation & glow effect.
/// Can be embedded in rows, app bars, or navigation bars.
class AiChatButton extends StatefulWidget {
  final double size;

  const AiChatButton({super.key, this.size = 56});

  @override
  State<AiChatButton> createState() => _AiChatButtonState();
}

class _AiChatButtonState extends State<AiChatButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const AiChatBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Tooltip(
        message: 'TripZ AI Assistant',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openChat(context),
            borderRadius: BorderRadius.circular(s / 2),
            splashColor: Colors.white24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Outer Frosted Glow Container
                ClipRRect(
                  borderRadius: BorderRadius.circular(s / 2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.green.withValues(alpha: 0.90),
                            AppColors.greenBright.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withValues(alpha: 0.40),
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: AppColors.greenBright.withValues(alpha: 0.20),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.40),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.robot,
                          color: Colors.white,
                          size: s * 0.41,
                        ),
                      ),
                    ),
                  ),
                ),

                // Mini Sparkle Badge
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.wandMagicSparkles,
                        color: Colors.white,
                        size: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating wrapper for backwards compatibility with Stack-based layouts.
class AiChatFloatingButton extends StatelessWidget {
  final double bottom;
  final double right;
  final double size;

  const AiChatFloatingButton({
    super.key,
    this.bottom = 20,
    this.right = 20,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      right: right,
      child: AiChatButton(size: size),
    );
  }
}
