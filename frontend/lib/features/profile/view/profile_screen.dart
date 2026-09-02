import 'package:flutter/material.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/view/admin_dashboard_screen.dart';
import 'package:frontend/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:frontend/features/profile/widgets/language_selector_bottom_sheet.dart';
import 'package:frontend/features/profile/widgets/logout_dialog.dart';
import 'package:frontend/features/profile/widgets/profile_action_buttons.dart';
import 'package:frontend/features/profile/widgets/profile_info_group.dart';
import 'package:frontend/features/profile/widgets/profile_settings_group.dart';
import 'package:frontend/features/profile/widgets/profile_user_card.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(ProfileViewModel());
    final languageController = Get.find<LanguageController>();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? AppColors.darkBg : const Color(0xFFF4F5F7);
    final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;
    final primaryText = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final dividerColor = isDarkMode
        ? const Color(0xFF28282C)
        : const Color(0xFFF1F1F3);
    final borderColor = isDarkMode
        ? const Color(0xFF2A2A2E)
        : const Color(0xFFECECEF);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Obx(() {
          final _ = viewModel.currentLocale;
          return Text(
            'profile & settings'.tr,
            style: AppFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          );
        }),
      ),
      body: Obx(() {
        final user = viewModel.currentUser;
        final pauseNotifs = viewModel.pauseNotifications.value;
        final isDark = viewModel.isDarkMode;
        final currentLang = viewModel.currentLanguage;
        final isAdmin = viewModel.isAdmin;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Summary Card
              ProfileUserCard(
                user: user,
                isDarkMode: isDark,
                cardColor: cardColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                borderColor: borderColor,
              ),

              const SizedBox(height: 16),

              // 2. Settings Group (Notifications, Dark Mode, Language)
              ProfileSettingsGroup(
                pauseNotifications: pauseNotifs,
                onToggleNotifications: viewModel.toggleNotificationSetting,
                isDarkMode: isDark,
                onToggleDarkMode: viewModel.toggleDarkMode,
                currentLanguage: currentLang,
                onSelectLanguage: () => LanguageSelectorBottomSheet.show(
                  context,
                  languageController,
                  isDark,
                ),
                cardColor: cardColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                dividerColor: dividerColor,
                borderColor: borderColor,
              ),

              const SizedBox(height: 16),

              // 3. Info Group (Role, Phone)
              ProfileInfoGroup(
                user: user,
                isDarkMode: isDark,
                cardColor: cardColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                dividerColor: dividerColor,
                borderColor: borderColor,
              ),

              const SizedBox(height: 48),

              // 4. Action Buttons (Admin Dashboard, Logout)
              ProfileActionButtons(
                isAdmin: isAdmin,
                isDarkMode: isDark,
                cardColor: cardColor,
                borderColor: borderColor,
                onAdminDashboardPressed: () =>
                    Get.to(() => const AdminDashboardScreen()),
                onLogoutPressed: () =>
                    LogoutDialog.show(context, viewModel, isDark),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
