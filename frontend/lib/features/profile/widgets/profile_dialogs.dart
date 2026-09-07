import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class ProfileDialogs {
  const ProfileDialogs._();

  static void showAbout(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.bus,
                  size: 14,
                  color: AppColors.green,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'about_us'.tr,
              style: AppFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'TRIP-Z is Cambodia’s premier intelligent bus booking and transportation management application. Connecting travelers seamlessly across provinces with comfort, security, and convenience.',
          style: AppFonts.dmSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: AppFonts.dmSans(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showLegal(
    BuildContext context, {
    required String title,
    required String content,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: AppFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          content,
          style: AppFonts.dmSans(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: AppFonts.dmSans(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
