import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:frontend/features/profile/widgets/language_selector_bottom_sheet.dart';
import 'package:frontend/features/profile/widgets/profile_common_widgets.dart';
import 'package:get/get.dart';

class AppPreferencesGroup extends StatelessWidget {
  final ProfileViewModel viewModel;
  final LanguageController languageController;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color dividerColor;
  final Color primaryText;
  final Color secondaryText;

  const AppPreferencesGroup({
    super.key,
    required this.viewModel,
    required this.languageController,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.dividerColor,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final currentLang = viewModel.currentLanguage;
    final pauseNotifs = viewModel.pauseNotifications.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSectionTitle(
          title: 'app_preferences'.tr,
          textColor: primaryText,
        ),
        const SizedBox(height: 8),
        ProfileCardContainer(
          cardBg: cardBg,
          borderColor: borderColor,
          children: [
            // 1. Language selector
            ProfileActionTile(
              icon: FontAwesomeIcons.language,
              iconColor: AppColors.green,
              title: 'language'.tr,
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentLang.flag,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currentLang.nativeName,
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: secondaryText,
                  ),
                ],
              ),
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
              onTap: () => LanguageSelectorBottomSheet.show(
                context,
                languageController,
                isDark,
              ),
            ),
            ProfileDivider(color: dividerColor),

            // 2. Dark Mode Switch
            ProfileSwitchTile(
              icon: isDark
                  ? FontAwesomeIcons.solidMoon
                  : FontAwesomeIcons.solidSun,
              iconColor: isDark
                  ? const Color(0xFFFBBF24)
                  : const Color(0xFFF59E0B),
              title: isDark ? 'dark_mode'.tr : 'light_mode'.tr,
              value: isDark,
              onChanged: (_) => viewModel.toggleDarkMode(),
              primaryText: primaryText,
              isDark: isDark,
            ),
            ProfileDivider(color: dividerColor),

            // 3. Pause Notifications Switch
            ProfileSwitchTile(
              icon: FontAwesomeIcons.solidBell,
              iconColor: const Color(0xFFEC4899),
              title: 'pause_notifications'.tr,
              value: pauseNotifs,
              onChanged: viewModel.toggleNotificationSetting,
              primaryText: primaryText,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}
