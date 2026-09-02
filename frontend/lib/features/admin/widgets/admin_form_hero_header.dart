import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminFormHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final FaIconData icon;
  final int count;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;

  const AdminFormHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: FaIcon(icon, color: Colors.white, size: 17)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count total',
                        style: AppFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
