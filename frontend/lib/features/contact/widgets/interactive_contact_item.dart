import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class InteractiveContactItem extends StatelessWidget {
  final Color cardColor;
  final Color iconColor;
  final Color iconBg;
  final FaIconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const InteractiveContactItem({
    super.key,
    required this.cardColor,
    required this.iconColor,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    required this.isDarkMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText =
        isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final secondaryText =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(icon, color: iconColor, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          color: secondaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null && onTap != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel!,
                          style: AppFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new,
                          size: 11,
                          color: iconColor,
                        ),
                      ],
                    ),
                  ),
                ] else if (onTap != null) ...[
                  Icon(
                    Icons.chevron_right,
                    color: secondaryText,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
