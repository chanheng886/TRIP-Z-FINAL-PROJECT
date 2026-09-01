import 'package:flutter/material.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  /// Returns Kantumruy Pro (without heavy bold) if the active language is Khmer,
  /// or DM Sans if the active language is English.
  static TextStyle dmSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    bool isKhmer = false;
    try {
      if (Get.isRegistered<LanguageController>()) {
        isKhmer = Get.find<LanguageController>().isKhmer;
      } else {
        isKhmer = Get.locale?.languageCode == 'km';
      }
    } catch (_) {
      isKhmer = Get.locale?.languageCode == 'km';
    }

    if (isKhmer) {
      // For Khmer (Kantumruy Pro), cap bold weights to normal or w500 to keep text clean and elegant
      FontWeight finalWeight = FontWeight.normal;
      if (fontWeight == FontWeight.bold ||
          fontWeight == FontWeight.w700 ||
          fontWeight == FontWeight.w800 ||
          fontWeight == FontWeight.w900) {
        finalWeight = FontWeight.w500;
      } else if (fontWeight != null) {
        finalWeight = fontWeight;
      }

      return GoogleFonts.kantumruyPro(
        fontSize: fontSize,
        fontWeight: finalWeight,
        color: color,
        height: height,
        decoration: decoration,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      );
    }

    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  /// General font alias
  static TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) =>
      dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
      );
}
