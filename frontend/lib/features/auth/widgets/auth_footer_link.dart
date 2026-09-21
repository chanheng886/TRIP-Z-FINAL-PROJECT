import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// Bottom footer link row to navigate between Login and Register screens
class AuthFooterLink extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onTap;
  final bool isDarkMode;

  const AuthFooterLink({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: AppFonts.dmSans(
            fontSize: 13,
            color: secondaryTextColor,
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            actionText,
            style: AppFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ),
      ],
    );
  }
}
