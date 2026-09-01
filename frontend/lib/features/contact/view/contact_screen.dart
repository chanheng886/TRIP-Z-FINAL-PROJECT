import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final primaryText =
        isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final cardColor = isDarkMode ? const Color(0xFF1E222B) : Colors.white;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Obx(() {
          final _ = languageController.locale.value;
          return Text(
            'nav_contact'.tr,
            style: AppFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          );
        }),
      ),
      body: Obx(() {
        final _ = languageController.locale.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FD18B), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.headset,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'contact_us'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'contact_subtitle'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact Channels
              _ContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFF3B82F6).withOpacity(0.12),
                icon: FontAwesomeIcons.phone,
                title: 'hotline'.tr,
                subtitle: '+855 23 888 999 / +855 98 765 432',
                isDarkMode: isDarkMode,
              ),
              _ContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFF10B981).withOpacity(0.12),
                icon: FontAwesomeIcons.envelope,
                title: 'email_support'.tr,
                subtitle: 'support@tripz.com.kh',
                isDarkMode: isDarkMode,
              ),
              _ContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFF0284C7).withOpacity(0.12),
                icon: FontAwesomeIcons.telegram,
                title: 'telegram_support'.tr,
                subtitle: '@tripz_cambodia_support',
                isDarkMode: isDarkMode,
              ),
              _ContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFF59E0B).withOpacity(0.12),
                icon: FontAwesomeIcons.locationDot,
                title: 'office_address'.tr,
                subtitle: 'Russian Federation Blvd, Phnom Penh, Cambodia',
                isDarkMode: isDarkMode,
              ),
              _ContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFF8B5CF6).withOpacity(0.12),
                icon: FontAwesomeIcons.clock,
                title: 'office_hours'.tr,
                subtitle: 'office_hours_val'.tr,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final Color cardColor;
  final Color iconColor;
  final Color iconBg;
  final FaIconData icon;
  final String title;
  final String subtitle;
  final bool isDarkMode;

  const _ContactItem({
    required this.cardColor,
    required this.iconColor,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, color: iconColor, size: 20),
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
                    fontSize: 13,
                    color: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
