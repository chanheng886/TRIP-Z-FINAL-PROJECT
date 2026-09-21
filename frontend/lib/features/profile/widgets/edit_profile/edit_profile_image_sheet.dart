import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Bottom sheet dialog for picking avatar photo from camera or gallery, or removing it
class EditProfileImageSheet extends StatelessWidget {
  final bool hasPhoto;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onRemovePhoto;
  final bool isDark;

  const EditProfileImageSheet({
    super.key,
    required this.hasPhoto,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemovePhoto,
    required this.isDark,
  });

  static Future<void> show({
    required BuildContext context,
    required bool hasPhoto,
    required VoidCallback onPickCamera,
    required VoidCallback onPickGallery,
    required VoidCallback onRemovePhoto,
    required bool isDark,
  }) {
    final sheetBg = isDark ? const Color(0xFF1E222B) : Colors.white;

    return showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditProfileImageSheet(
        hasPhoto: hasPhoto,
        onPickCamera: () {
          Navigator.of(ctx).pop();
          onPickCamera();
        },
        onPickGallery: () {
          Navigator.of(ctx).pop();
          onPickGallery();
        },
        onRemovePhoto: () {
          Navigator.of(ctx).pop();
          onRemovePhoto();
        },
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryText =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final borderColor =
        isDark ? const Color(0xFF2C313C) : const Color(0xFFE2E8F0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'change_profile_photo'.tr.isNotEmpty
                  ? 'change_profile_photo'.tr
                  : 'Change Profile Photo',
              style: AppFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'select_photo_source'.tr.isNotEmpty
                  ? 'select_photo_source'.tr
                  : 'Choose where to get your profile picture',
              style: AppFonts.dmSans(
                fontSize: 13,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Camera Option
            _PickerOption(
              icon: Icons.camera_alt_rounded,
              title: 'take_photo'.tr.isNotEmpty
                  ? 'take_photo'.tr
                  : 'Take a Photo',
              subtitle: 'Use camera to capture a new photo',
              color: AppColors.green,
              isDark: isDark,
              borderColor: borderColor,
              onTap: onPickCamera,
            ),
            const SizedBox(height: 12),

            // Gallery Option
            _PickerOption(
              icon: Icons.photo_library_rounded,
              title: 'choose_from_gallery'.tr.isNotEmpty
                  ? 'choose_from_gallery'.tr
                  : 'Choose from Gallery',
              subtitle: 'Select an existing photo from device album',
              color: const Color(0xFF3B82F6),
              isDark: isDark,
              borderColor: borderColor,
              onTap: onPickGallery,
            ),

            // Remove Photo Option (if photo exists)
            if (hasPhoto) ...[
              const SizedBox(height: 12),
              _PickerOption(
                icon: Icons.delete_outline_rounded,
                title: 'remove_photo'.tr.isNotEmpty
                    ? 'remove_photo'.tr
                    : 'Remove Photo',
                subtitle: 'Reset to default avatar initials',
                color: const Color(0xFFEF4444),
                isDark: isDark,
                borderColor: borderColor,
                onTap: onRemovePhoto,
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final Color borderColor;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252A35) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(icon, size: 22, color: color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
