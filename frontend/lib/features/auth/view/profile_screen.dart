import 'package:flutter/material.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:frontend/features/profile/widgets/account_info_group.dart';
import 'package:frontend/features/profile/widgets/admin_banner_card.dart';
import 'package:frontend/features/profile/widgets/app_preferences_group.dart';
import 'package:frontend/features/profile/widgets/hero_profile_card.dart';
import 'package:frontend/features/profile/widgets/language_selector_bottom_sheet.dart';
import 'package:frontend/features/profile/widgets/profile_common_widgets.dart';
import 'package:frontend/features/profile/widgets/support_legal_group.dart';
import 'package:frontend/features/profile/widgets/travel_services_group.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/profile/view/edit_profile_screen.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(ProfileViewModel());
    final languageController = Get.find<LanguageController>();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDarkMode ? AppColors.darkBg : const Color(0xFFF6F8FA);
    final cardBg = isDarkMode ? AppColors.darkSurface : Colors.white;
    final primaryText = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final borderColor = isDarkMode
        ? const Color(0xFF2A2A2E)
        : const Color(0xFFE5E7EB);
    final dividerColor = isDarkMode
        ? const Color(0xFF28282C)
        : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Obx(() {
          final _ = viewModel.currentLocale;
          return Text(
            'profile & settings'.tr,
            style: AppFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryText,
              letterSpacing: -0.4,
            ),
          );
        }),
        actions: [
          // Edit Profile action button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Get.to(() => const EditProfileScreen()),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.penToSquare,
                    size: 13,
                    color: primaryText,
                  ),
                ),
              ),
            ),
          ),
          // Language switcher pill in app bar
          Obx(() {
            final currentLang = languageController.currentLanguage;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => LanguageSelectorBottomSheet.show(
                  context,
                  languageController,
                  isDarkMode,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(
                      alpha: isDarkMode ? 0.15 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentLang.flag,
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        currentLang.languageCode.toUpperCase(),
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final user = viewModel.currentUser;
        final isDark = viewModel.isDarkMode;
        final isAdmin = viewModel.isAdmin;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero VIP Profile Card
              HeroProfileCard(user: user, isAdmin: isAdmin, isDark: isDark),
              const SizedBox(height: 16),

              // 2. Admin Operations Shortcut (if Admin)
              if (isAdmin) ...[
                AdminBannerCard(isDark: isDark),
                const SizedBox(height: 16),
              ],

              // 3. Account Information Group
              AccountInfoGroup(
                user: user,
                isAdmin: isAdmin,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                dividerColor: dividerColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
              ),
              const SizedBox(height: 18),

              // 4. Quick Travel Services Shortcuts
              TravelServicesGroup(
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                dividerColor: dividerColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
              ),
              const SizedBox(height: 18),

              // 5. App Preferences Group
              AppPreferencesGroup(
                viewModel: viewModel,
                languageController: languageController,
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                dividerColor: dividerColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
              ),
              const SizedBox(height: 18),

              // 6. Support & Legal
              SupportLegalGroup(
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                dividerColor: dividerColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
              ),
              const SizedBox(height: 28),

              // 7. Logout Button
              ProfileLogoutButton(viewModel: viewModel, isDark: isDark),
              const SizedBox(height: 36),
            ],
          ),
        );
      }),
    );
  }
}
