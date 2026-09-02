import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:frontend/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:get/get.dart';

class LogoutDialog {
  static void show(
    BuildContext context,
    ProfileViewModel viewModel,
    bool isDarkMode,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1C1C1F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'logout_confirm_title'.tr,
          style: AppFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          'logout_confirm_msg'.tr,
          style: AppFonts.dmSans(
            color: isDarkMode
                ? const Color(0xFF8A8A8E)
                : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: AppFonts.dmSans(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Get.back();
              await viewModel.logout();
              Get.offAll(() => const LoginScreen());
            },
            child: Text('log_out'.tr),
          ),
        ],
      ),
    );
  }
}
