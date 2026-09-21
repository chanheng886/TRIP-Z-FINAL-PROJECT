import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Full-width action button to save profile edits with loading indicator
class EditProfileSaveButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSave;

  const EditProfileSaveButton({
    super.key,
    required this.isSubmitting,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppColors.green.withValues(alpha: 0.4),
        ),
        onPressed: isSubmitting ? null : onSave,
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.solidFloppyDisk,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'save_changes'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
