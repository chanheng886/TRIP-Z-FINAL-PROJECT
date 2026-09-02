import 'package:flutter/material.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/theme_controller.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewModel extends GetxController {
  final AuthViewmodel _authVM = Get.find<AuthViewmodel>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final ThemeController _themeController = Get.find<ThemeController>();

  final RxBool pauseNotifications = false.obs;

  static const String _notificationsKey = 'pause_notifications';

  User? get currentUser => _authVM.currentUser;
  bool get isAdmin => currentUser?.role == UserRole.Admin;
  bool get isDarkMode => _themeController.themeMode.value == ThemeMode.dark;
  LanguageModel get currentLanguage => _languageController.currentLanguage;
  Locale get currentLocale => _languageController.locale.value;

  @override
  void onInit() {
    super.onInit();
    loadNotificationSetting();
  }

  Future<void> loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    pauseNotifications.value = prefs.getBool(_notificationsKey) ?? false;
  }

  Future<void> toggleNotificationSetting(bool val) async {
    pauseNotifications.value = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, val);
  }

  void toggleDarkMode() {
    _themeController.toggleTheme();
  }

  void changeLanguage(String languageCode, String countryCode) {
    _languageController.changeLanguage(languageCode, countryCode);
  }

  Future<void> logout() async {
    await _authVM.logout();
  }
}
