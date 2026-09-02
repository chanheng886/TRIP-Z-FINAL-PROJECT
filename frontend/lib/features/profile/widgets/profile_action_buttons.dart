import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class ProfileActionButtons extends StatelessWidget {
  final bool isAdmin;
  final bool isDarkMode;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback onAdminDashboardPressed;
  final VoidCallback onLogoutPressed;

  const ProfileActionButtons({
    super.key,
    required this.isAdmin,
    required this.isDarkMode,
    required this.cardColor,
    required this.borderColor,
    required this.onAdminDashboardPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Admin Dashboard Pill Button (if Admin)
        if (isAdmin) ...[
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                foregroundColor: AppColors.green,
                elevation: isDarkMode ? 0 : 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(color: borderColor, width: 1),
                ),
              ),
              onPressed: onAdminDashboardPressed,
              child: Text(
                'Admin dashboard'.tr,
                style: AppFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // 2. Logout Pill Button
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cardColor,
              foregroundColor: const Color(0xFFEF4444),
              elevation: isDarkMode ? 0 : 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: borderColor, width: 1),
              ),
            ),
            onPressed: onLogoutPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.arrowRightFromBracket,
                  size: 16,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(width: 8),
                Text(
                  'log_out'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
