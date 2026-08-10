import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightPrimaryText,
      error: AppColors.lightAlertText,
    ),
    cardColor: AppColors.lightCardBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.lightPrimaryText),
    ),
    textTheme: GoogleFonts.dmSansTextTheme().apply(
      bodyColor: AppColors.lightPrimaryText,
      displayColor: AppColors.lightPrimaryText,
    ),
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: AppColors.lightInputField,
    //   hintStyle: GoogleFonts.dmSans(color: AppColors.lightSecondaryText),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkPrimaryText,
      error: AppColors.darkAlertText,
    ),
    cardColor: AppColors.darkCardBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.darkPrimaryText),
    ),
    textTheme: GoogleFonts.dmSansTextTheme().apply(
      bodyColor: AppColors.darkPrimaryText,
      displayColor: AppColors.darkPrimaryText,
    ),
    // inputDecorationTheme: InputDecorationTheme(
    //   filled: true,
    //   fillColor: AppColors.darkInputField,
    //   hintStyle: GoogleFonts.dmSans(color: AppColors.darkSecondaryText),
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
