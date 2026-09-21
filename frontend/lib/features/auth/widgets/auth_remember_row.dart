import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Row containing Remember Me toggle and Forgot Password link
class AuthRememberRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback? onForgotPassword;
  final bool isDarkMode;

  const AuthRememberRow({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.isDarkMode,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me Switch
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.72,
              child: Switch(
                value: rememberMe,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.green,
                inactiveThumbColor: isDarkMode
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                inactiveTrackColor: isDarkMode
                    ? const Color(0xFF2A2E3D)
                    : const Color(0xFFE2E8F0),
                onChanged: onRememberMeChanged,
              ),
            ),
            Text(
              'remember_me'.tr,
              style: AppFonts.dmSans(
                fontSize: 12.5,
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Forgot Password Link
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onForgotPassword ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.green,
                    content: Text(
                      'Password recovery instructions sent to your email.',
                      style: AppFonts.dmSans(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
          child: Text(
            'forgot_password'.tr,
            style: AppFonts.dmSans(
              fontSize: 12.5,
              color: AppColors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
