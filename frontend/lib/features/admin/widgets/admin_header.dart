import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminHeader extends StatelessWidget {
  final Color pageBackground;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final VoidCallback onRefresh;
  final VoidCallback onBack;

  const AdminHeader({
    super.key,
    required this.pageBackground,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    required this.onRefresh,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: pageBackground,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: primaryText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Title & Subtitle with Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Admin Console',
                        style: AppFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.green, AppColors.limeGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PORTAL',
                        style: AppFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Fleet & Operations Management',
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Live Sync Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Live',
                  style: AppFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Refresh Button
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.arrowsRotate,
                  size: 13,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
