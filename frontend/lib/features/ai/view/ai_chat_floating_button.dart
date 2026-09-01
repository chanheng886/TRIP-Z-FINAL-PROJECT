import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/ai/view/ai_chat_bottom_sheet.dart';

class AiChatFloatingButton extends StatelessWidget {
  const AiChatFloatingButton({super.key});

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiChatBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 20,
      child: GestureDetector(
        onTap: () => _openChat(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xff4FD18B),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xff4FD18B).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.robot,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
