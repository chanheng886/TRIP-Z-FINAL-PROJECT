import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  /// Builds a TextTheme tailored for English (DM Sans) or Khmer (Kantumruy Pro).
  /// In Khmer mode, bold weights are softened to FontWeight.w500/normal for clean, elegant typography.
  static TextTheme _buildTextTheme(Color textColor, bool isKhmer) {
    if (isKhmer) {
      final baseTheme = GoogleFonts.kantumruyProTextTheme().apply(
        bodyColor: textColor,
        displayColor: textColor,
      );

      // Clean, unbolded typography for Khmer script
      return baseTheme.copyWith(
        displayLarge: baseTheme.displayLarge?.copyWith(fontWeight: FontWeight.w500),
        displayMedium: baseTheme.displayMedium?.copyWith(fontWeight: FontWeight.w500),
        displaySmall: baseTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
        headlineLarge: baseTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w500),
        headlineMedium: baseTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
        headlineSmall: baseTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        titleLarge: baseTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
        titleMedium: baseTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        titleSmall: baseTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        bodyLarge: baseTheme.bodyLarge?.copyWith(fontWeight: FontWeight.normal),
        bodyMedium: baseTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
        bodySmall: baseTheme.bodySmall?.copyWith(fontWeight: FontWeight.normal),
        labelLarge: baseTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        labelMedium: baseTheme.labelMedium?.copyWith(fontWeight: FontWeight.normal),
        labelSmall: baseTheme.labelSmall?.copyWith(fontWeight: FontWeight.normal),
      );
    }

    return GoogleFonts.dmSansTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
  }

  static ThemeData lightTheme({bool isKhmer = false}) => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.lightBackground,
          onSurface: AppColors.lightPrimaryText,
          error: AppColors.lightAlertText,
        ),
        cardColor: AppColors.lightCardBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.lightPrimaryText),
        ),
        textTheme: _buildTextTheme(AppColors.lightPrimaryText, isKhmer),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );

  static ThemeData darkTheme({bool isKhmer = false}) => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.darkBackground,
          onSurface: AppColors.darkPrimaryText,
          error: AppColors.darkAlertText,
        ),
        cardColor: AppColors.darkCardBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.darkPrimaryText),
        ),
        textTheme: _buildTextTheme(AppColors.darkPrimaryText, isKhmer),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      );

  // Backward compatibility getters
  static ThemeData get light => lightTheme(isKhmer: false);
  static ThemeData get dark => darkTheme(isKhmer: false);
}
