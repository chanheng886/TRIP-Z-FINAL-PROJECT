import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Gender selector row with Male, Female, and Other selectable chips
class EditProfileGenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final bool isDark;

  const EditProfileGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GenderChip(
          label: 'gender_male'.tr,
          icon: FontAwesomeIcons.mars,
          value: 'Male',
          isSelected: selectedGender == 'Male',
          onTap: () => onGenderChanged('Male'),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _GenderChip(
          label: 'gender_female'.tr,
          icon: FontAwesomeIcons.venus,
          value: 'Female',
          isSelected: selectedGender == 'Female',
          onTap: () => onGenderChanged('Female'),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _GenderChip(
          label: 'gender_other'.tr,
          icon: FontAwesomeIcons.genderless,
          value: 'Other',
          isSelected: selectedGender == 'Other',
          onTap: () => onGenderChanged('Other'),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.green.withValues(alpha: isDark ? 0.22 : 0.12)
                : (isDark ? const Color(0xFF1E222A) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.green
                  : (isDark
                      ? const Color(0xFF2A2A2E)
                      : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: 13,
                color: isSelected ? AppColors.green : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.green : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
