import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AiChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;

  const AiChatInputField({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2D35) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: AppFonts.dmSans(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about buses, routes, prices...',
                  hintStyle: AppFonts.dmSans(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onSend,
              icon: const FaIcon(
                FontAwesomeIcons.paperPlane,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
