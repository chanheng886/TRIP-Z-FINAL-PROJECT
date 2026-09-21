import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// Standardized, theme-adaptive text field for authentication forms
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool isHighlighted;
  final bool isDarkMode;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDarkMode,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryTextColor =
        isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryTextColor =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final fieldBorderColor =
        isDarkMode ? const Color(0xFF2C3240) : const Color(0xFFE2E8F0);
    final fieldFillColor =
        isDarkMode ? const Color(0xFF16181F) : const Color(0xFFFAFAFA);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppFonts.dmSans(
        color: primaryTextColor,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppFonts.dmSans(
          color: isHighlighted ? AppColors.green : secondaryTextColor,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
        ),
        hintStyle: AppFonts.dmSans(
          color: secondaryTextColor.withValues(alpha: 0.6),
          fontSize: 14,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        filled: true,
        fillColor: fieldFillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isHighlighted ? AppColors.green : fieldBorderColor,
            width: isHighlighted ? 1.8 : 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.green,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.lightAlertText,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.lightAlertText,
            width: 1.8,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
