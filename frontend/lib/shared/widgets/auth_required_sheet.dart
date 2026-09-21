import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:frontend/features/auth/view/register_screen.dart';
import 'package:get/get.dart';

void showAuthRequiredSheet(
  BuildContext context, {
  VoidCallback? onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final sheetBg = isDark ? const Color(0xFF181B22) : Colors.white;
      final primaryText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
      final secondaryText = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
      final borderColor = isDark ? const Color(0xFF2C313C) : const Color(0xFFE2E8F0);

      return Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B4252) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Icon badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.green,
                      AppColors.green.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.ticket,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'sign_in_to_book'.tr,
                textAlign: TextAlign.center,
                style: AppFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'sign_in_to_book_desc'.tr,
                textAlign: TextAlign.center,
                style: AppFonts.dmSans(
                  fontSize: 13,
                  color: secondaryText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // Primary Action: Log In
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Get.to(() => LoginScreen(
                          onLoginSuccess: onSuccess,
                        ));
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.arrowRightToBracket,
                    size: 15,
                    color: Colors.white,
                  ),
                  label: Text(
                    'login'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Action: Create Account
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryText,
                    side: BorderSide(color: borderColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Get.to(() => RegisterScreen(
                          onRegisterSuccess: onSuccess,
                        ));
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.userPlus,
                    size: 14,
                    color: primaryText,
                  ),
                  label: Text(
                    'create_account'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Dismiss Action
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'continue_browsing'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 13,
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
