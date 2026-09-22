import 'package:flutter/material.dart';

/// Reusable Chatbot Avatar displaying the official TripZ Chatbot Head.
class ChatbotAvatar extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const ChatbotAvatar({
    super.key,
    required this.size,
    this.fit = BoxFit.contain,
  });

  static const String assetPath =
      'assets/images/friendly_chatbot_head_logo_no_antenna.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.medium,
    );
  }
}
