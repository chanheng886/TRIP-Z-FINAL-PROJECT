import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/core/theme/theme_controller.dart';
import 'package:frontend/features/admin/view/admin_dashboard_screen.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final primaryText =
        isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Obx(() {
          final _ = languageController.locale.value;
          return Text(
            'me'.tr,
            style: AppFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          );
        }),
      ),
      body: Obx(() {
        final authVM = Get.find<AuthViewmodel>();
        final User? user = authVM.currentUser;
        final _ = languageController.locale.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.username ?? 'Guest',
                style: AppFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: AppFonts.dmSans(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              if (user != null) ...[
                _InfoTile(
                  icon: FontAwesomeIcons.phone,
                  label: 'phone'.tr,
                  value: user.phone,
                ),
                _InfoTile(
                  icon: FontAwesomeIcons.venusMars,
                  label: 'gender'.tr,
                  value: user.gender == 'Male'
                      ? 'male'.tr
                      : (user.gender == 'Female' ? 'female'.tr : user.gender),
                ),
                _InfoTile(
                  icon: FontAwesomeIcons.userTag,
                  label: 'role'.tr,
                  value: user.role.name,
                ),
              ],
              const SizedBox(height: 12),
              _LanguageTile(isDarkMode: isDarkMode),
              _DarkModeTile(isDarkMode: isDarkMode),
              const SizedBox(height: 24),
              if (user != null && user.role == UserRole.Admin) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => const AdminDashboardScreen());
                    },
                    icon: const FaIcon(FontAwesomeIcons.tableColumns, size: 16),
                    label: Text(
                      'dashboard'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? AppColors.darkAlertText
                        : AppColors.lightAlertText,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    _showLogoutDialog(context, authVM, isDarkMode);
                  },
                  icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 16),
                  label: Text(
                    'logout'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showLogoutDialog(
      BuildContext context, AuthViewmodel authVM, bool isDarkMode) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'logout_confirm_title'.tr,
          style: AppFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'logout_confirm_msg'.tr,
          style: AppFonts.dmSans(
            color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
              backgroundColor: isDarkMode
                  ? AppColors.darkAlertText
                  : AppColors.lightAlertText,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Get.back();
              await authVM.logout();
              Get.offAll(() => const LoginScreen());
            },
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final bool isDarkMode;

  const _LanguageTile({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E222B) : Colors.white;
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      final currentLang = languageController.currentLanguage;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showLanguageSelector(context, languageController, isDarkMode),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E3A2F)
                          : const Color(0xffD4F3E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.globe,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'language'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 12,
                            color: isDarkMode
                                ? const Color(0xFF94A3B8)
                                : const Color(0xff64748B),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              currentLang.flag,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentLang.nativeName,
                              style: AppFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xff1E293B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showLanguageSelector(
    BuildContext context,
    LanguageController languageController,
    bool isDarkMode,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
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
                      ? (isDarkMode
                          ? const Color(0xFF1E3A2F)
                          : const Color(0xFFE8F8F0))
                      : (isDarkMode
                          ? const Color(0xFF262C38)
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    lang.nativeName,
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Text(
                    lang.name,
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      color: isDarkMode
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
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
      ),
      isScrollControlled: true,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1E222B) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E3A2F)
                  : const Color(0xffD4F3E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(icon, size: 18, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.dmSans(
                    fontSize: 12,
                    color: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
                Text(
                  value,
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xff1E293B),
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

class _DarkModeTile extends StatelessWidget {
  final bool isDarkMode;

  const _DarkModeTile({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1E222B) : Colors.white;
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E3A2F)
                  : const Color(0xffD4F3E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                isDarkMode ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(() {
              final _ = languageController.locale.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'appearance'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      color: isDarkMode
                          ? const Color(0xFF94A3B8)
                          : const Color(0xff64748B),
                    ),
                  ),
                  Text(
                    isDarkMode ? 'dark_mode'.tr : 'light_mode'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xff1E293B),
                    ),
                  ),
                ],
              );
            }),
          ),
          Obx(() {
            final isDark = themeController.themeMode.value == ThemeMode.dark;
            return Switch(
              value: isDark,
              onChanged: (_) => themeController.toggleTheme(),
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            );
          }),
        ],
      ),
    );
  }
}
