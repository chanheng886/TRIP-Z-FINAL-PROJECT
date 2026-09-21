import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_gender_selector.dart';
import 'package:get/get.dart';

/// Card containing personal details input fields (Username, Email, Phone, Gender)
class EditProfileFieldsCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final Color cardBg;
  final Color borderColor;
  final Color primaryText;
  final Color fieldBg;
  final bool isDark;

  const EditProfileFieldsCard({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.cardBg,
    required this.borderColor,
    required this.primaryText,
    required this.fieldBg,
    required this.isDark,
  });

  InputDecoration _buildInputDecoration({
    required String hintText,
    required FaIconData icon,
    required Color iconColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fieldBg,
      hintText: hintText,
      hintStyle: AppFonts.dmSans(
        fontSize: 13,
        color: const Color(0xFF94A3B8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 10),
        child: FaIcon(icon, size: 14, color: iconColor),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryText.withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'personal_details'.tr,
          style: AppFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: primaryText,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username Field
              _buildFieldLabel('username'.tr),
              const SizedBox(height: 6),
              TextFormField(
                controller: usernameController,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'username_cannot_empty'.tr
                    : null,
                decoration: _buildInputDecoration(
                  hintText: 'Enter username',
                  icon: FontAwesomeIcons.solidUser,
                  iconColor: AppColors.green,
                ),
              ),

              const SizedBox(height: 16),

              // Email Field
              _buildFieldLabel('Email'),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
                decoration: _buildInputDecoration(
                  hintText: 'user@tripz.kh',
                  icon: FontAwesomeIcons.solidEnvelope,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),

              const SizedBox(height: 16),

              // Phone Field
              _buildFieldLabel('Phone'),
              const SizedBox(height: 6),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                decoration: _buildInputDecoration(
                  hintText: '+855 12 345 678',
                  icon: FontAwesomeIcons.phone,
                  iconColor: const Color(0xFF10B981),
                ),
              ),

              const SizedBox(height: 18),

              // Gender Selection
              _buildFieldLabel('select_gender'.tr),
              const SizedBox(height: 8),
              EditProfileGenderSelector(
                selectedGender: selectedGender,
                onGenderChanged: onGenderChanged,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
