import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Segmented gender selector with animated tabs for the registration form
class AuthGenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final bool isDarkMode;
  final List<String> genders;

  const AuthGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.isDarkMode,
    this.genders = const ['male', 'female', 'other'],
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final fieldBorderColor =
        isDarkMode ? const Color(0xFF2C3240) : const Color(0xFFE2E8F0);
    final fieldFillColor =
        isDarkMode ? const Color(0xFF16181F) : const Color(0xFFFAFAFA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'gender'.tr,
          style: AppFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fieldFillColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: fieldBorderColor,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: genders.map((gender) {
              final isSelected = selectedGender == gender;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onGenderChanged(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      gender.toLowerCase().tr,
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
