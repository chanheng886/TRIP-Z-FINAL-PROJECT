import 'package:flutter/material.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class LanguageSelectorBottomSheet extends StatelessWidget {
  final LanguageController languageController;
  final bool isDarkMode;

  const LanguageSelectorBottomSheet({
    super.key,
    required this.languageController,
    required this.isDarkMode,
  });

  static void show(
    BuildContext context,
    LanguageController languageController,
    bool isDarkMode,
  ) {
    Get.bottomSheet(
      LanguageSelectorBottomSheet(
        languageController: languageController,
        isDarkMode: isDarkMode,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'select_language'.tr,
                style: AppFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                color: isDarkMode ? Colors.white70 : Colors.black54,
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...LanguageController.supportedLanguages.map((lang) {
            final isSelected =
                languageController.locale.value.languageCode ==
                lang.languageCode;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.green.withValues(alpha: isDarkMode ? 0.2 : 0.08)
                    : (isDarkMode
                          ? const Color(0xFF26262A)
                          : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.green : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Text(lang.flag, style: const TextStyle(fontSize: 26)),
                title: Text(
                  lang.nativeName,
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                subtitle: Text(
                  lang.name,
                  style: AppFonts.dmSans(
                    fontSize: 12,
                    color: isDarkMode
                        ? const Color(0xFF8A8A8E)
                        : const Color(0xFF64748B),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.green,
                      )
                    : null,
                onTap: () {
                  languageController.changeLanguage(
                    lang.languageCode,
                    lang.countryCode,
                  );
                  Get.back();
                },
              ),
            );
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
