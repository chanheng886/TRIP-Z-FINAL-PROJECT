import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AiChatHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onClearChat;

  const AiChatHeader({
    super.key,
    required this.isDark,
    required this.onClearChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.robot,
                color: AppColors.green,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TripZ AI',
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Your bus travel assistant',
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClearChat,
            icon: FaIcon(
              FontAwesomeIcons.arrowsRotate,
              size: 16,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
