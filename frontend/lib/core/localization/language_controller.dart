import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageModel {
  final String name;
  final String nativeName;
  final String languageCode;
  final String countryCode;
  final String flag;

  const LanguageModel({
    required this.name,
    required this.nativeName,
    required this.languageCode,
    required this.countryCode,
    required this.flag,
  });

  Locale get locale => Locale(languageCode, countryCode);
}

class LanguageController extends GetxController {
  static const String _languageKey = 'language_code';
  static const String _countryKey = 'country_code';

  final Rx<Locale> locale = const Locale('en', 'US').obs;

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(
      name: 'English',
      nativeName: 'English (US)',
      languageCode: 'en',
      countryCode: 'US',
      flag: '🇺🇸',
    ),
    LanguageModel(
      name: 'Khmer',
      nativeName: 'ភាសាខ្មែរ',
      languageCode: 'km',
      countryCode: 'KH',
      flag: '🇰🇭',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    final savedCountry = prefs.getString(_countryKey);

    if (savedLang != null && savedCountry != null) {
      final savedLocale = Locale(savedLang, savedCountry);
      locale.value = savedLocale;
      Get.updateLocale(savedLocale);
    }
  }

  Future<void> changeLanguage(String languageCode, String countryCode) async {
    final newLocale = Locale(languageCode, countryCode);
    locale.value = newLocale;
    await Get.updateLocale(newLocale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    await prefs.setString(_countryKey, countryCode);
  }

  bool get isKhmer => locale.value.languageCode == 'km';

  LanguageModel get currentLanguage {
    return supportedLanguages.firstWhere(
      (lang) => lang.languageCode == locale.value.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }
}
