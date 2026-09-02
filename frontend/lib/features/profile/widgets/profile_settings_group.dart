import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class ProfileSettingsGroup extends StatelessWidget {
  final bool pauseNotifications;
  final ValueChanged<bool> onToggleNotifications;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final LanguageModel currentLanguage;
  final VoidCallback onSelectLanguage;
  final Color cardColor;
  final Color primaryText;
  final Color secondaryText;
  final Color dividerColor;
  final Color? borderColor;

  const ProfileSettingsGroup({
    super.key,
    required this.pauseNotifications,
    required this.onToggleNotifications,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.currentLanguage,
    required this.onSelectLanguage,
    required this.cardColor,
    required this.primaryText,
    required this.secondaryText,
    required this.dividerColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor!, width: 1),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // 1. Pause notifications
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.bellSlash,
                  size: 18,
                  color: primaryText,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'pause_notifications'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
                    ),
                  ),
                ),
                Switch(
                  value: pauseNotifications,
                  onChanged: onToggleNotifications,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: isDarkMode
                      ? const Color(0xFF2C2C30)
                      : const Color(0xFFE5E7EB),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 2. Dark mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.moon, size: 18, color: primaryText),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'dark_mode'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
                    ),
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (_) => onToggleDarkMode(),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: isDarkMode
                      ? const Color(0xFF2C2C30)
                      : const Color(0xFFE5E7EB),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 3. Language
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              onTap: onSelectLanguage,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.globe,
                      size: 18,
                      color: primaryText,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'language'.tr,
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            currentLanguage.nativeName,
                            style: AppFonts.dmSans(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
