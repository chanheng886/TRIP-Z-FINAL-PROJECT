import 'package:flutter/material.dart';

class AiChatTypingIndicator extends StatelessWidget {
  final bool isDark;

  const AiChatTypingIndicator({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2D35) : Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(isDark, 0),
            const SizedBox(width: 4),
            _buildDot(isDark, 1),
            const SizedBox(width: 4),
            _buildDot(isDark, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (_, value, __) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: value)
                : Colors.grey.withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
