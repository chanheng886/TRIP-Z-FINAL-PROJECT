import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

InputDecoration adminFieldDecoration({
  required String label,
  required FaIconData icon,
  required bool isDark,
  required Color secondaryText,
  required Color borderColor,
}) {
  final inputFieldColor = isDark ? AppColors.darkSurface : Colors.white;

  return InputDecoration(
    filled: true,
    fillColor: inputFieldColor,
    labelText: label,
    labelStyle: AppFonts.dmSans(color: secondaryText, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    prefixIcon: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Center(child: FaIcon(icon, color: AppColors.green, size: 14)),
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.green, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
    ),
  );
}

InputDecoration adminDropdownDecoration({
  required String label,
  required FaIconData icon,
  required bool isDark,
  required Color secondaryText,
  required Color borderColor,
}) {
  return adminFieldDecoration(
    label: label,
    icon: icon,
    isDark: isDark,
    secondaryText: secondaryText,
    borderColor: borderColor,
  );
}

TextStyle adminDropdownTextStyle({required Color primaryText}) {
  return AppFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );
}

class AdminPickerField extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final String? value;
  final VoidCallback onTap;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;

  const AdminPickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: adminFieldDecoration(
          label: label,
          icon: icon,
          isDark: isDark,
          secondaryText: secondaryText,
          borderColor: borderColor,
        ),
        child: Text(
          value ?? 'select'.tr,
          style: AppFonts.dmSans(
            fontSize: 14,
            fontWeight: value == null ? FontWeight.normal : FontWeight.w600,
            color: value == null ? secondaryText : primaryText,
          ),
        ),
      ),
    );
  }
}

class AdminSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  const AdminSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppColors.green.withValues(alpha: 0.4),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: AppFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}
