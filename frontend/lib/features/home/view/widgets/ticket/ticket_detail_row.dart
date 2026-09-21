import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// Formatted key-value row with icon for e-ticket details
class TicketDetailRow extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final ColorScheme colorScheme;

  const TicketDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 13,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.dmSans(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Text(
              value,
              style: AppFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
