import 'package:frontend/core/localization/languages/en_us.dart';
import 'package:frontend/core/localization/languages/km_kh.dart';
import 'package:get/get.dart';

extension DbTranslator on String {
  /// Translates a database value (such as location name, bus type, company, or status)
  /// according to the active locale. Returns the localized string if found, or the original string.
  String get trDb {
    final text = trim();
    if (text.isEmpty) return this;

    final isKhmer = (Get.locale?.languageCode == 'km');
    final activeMap = isKhmer ? kmKH : enUS;

    // 1. Direct exact key lookup
    if (activeMap.containsKey(text)) {
      return activeMap[text]!;
    }

    // 2. Case-insensitive lookup
    final lowerText = text.toLowerCase();
    for (final entry in activeMap.entries) {
      if (entry.key.toLowerCase() == lowerText) {
        return entry.value;
      }
    }

    // 3. Fallback to standard GetX .tr
    final trValue = text.tr;
    if (trValue != text && trValue.isNotEmpty) {
      return trValue;
    }

    return this;
  }
}

/// Helper function to translate database strings
String trDb(String? text) {
  if (text == null || text.isEmpty) return '';
  return text.trDb;
}
