import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// Helpful tip/guidance row with small icon and dimmed instruction text
class TicketInfoRow extends StatelessWidget {
  final FaIconData icon;
  final String text;
  final ColorScheme colorScheme;

  const TicketInfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: 13,
          color: colorScheme.onSurface.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppFonts.dmSans(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }
}
