import 'package:flutter/material.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/theme_controller.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends GetxController {
  final AuthViewmodel _authVM = Get.find<AuthViewmodel>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final ImagePicker _picker = ImagePicker();

  final RxBool pauseNotifications = false.obs;
  final RxBool isUploadingImage = false.obs;

  static const String _notificationsKey = 'pause_notifications';

  User? get currentUser => _authVM.currentUser;
  bool get isAdmin => currentUser?.role == UserRole.Admin;
  bool get isDarkMode {
    final tm = _themeController.themeMode.value;
    if (tm == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return tm == ThemeMode.dark;
  }
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

  Future<String?> pickImageBase64(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    required String username,
    required String email,
    required String phone,
    required String gender,
    String? profileImage,
  }) async {
    return await _authVM.updateProfile(
      username: username,
      email: email,
      phone: phone,
      gender: gender,
      profileImage: profileImage,
    );
  }

  Future<void> logout() async {
    await _authVM.logout();
  }
}
