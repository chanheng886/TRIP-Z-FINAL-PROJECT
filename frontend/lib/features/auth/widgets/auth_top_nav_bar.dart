import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/app/main_app.dart';
import 'package:get/get.dart';

/// Top overlay bar for authentication screens containing the back button
/// and the bilingual (EN / KM) language switcher pill.
class AuthTopNavBar extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const AuthTopNavBar({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Arrow Button
            IconButton(
              onPressed: onBackPressed ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Get.offAll(() => const MainApp());
                    }
                  },
              icon: const FaIcon(
                FontAwesomeIcons.angleLeft,
                color: Colors.white,
                size: 24,
              ),
              splashRadius: 22,
            ),

            // Bilingual Switcher Pill
            Obx(() {
              final currentLang = languageController.currentLanguage;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (languageController.isKhmer) {
                    languageController.changeLanguage('en', 'US');
                  } else {
                    languageController.changeLanguage('km', 'KH');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentLang.flag,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentLang.languageCode.toUpperCase(),
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
