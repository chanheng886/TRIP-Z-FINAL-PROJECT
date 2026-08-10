import 'package:flutter/material.dart';

class AppColors {
  // Brand — same in both light & dark
  static const primary = Color(0xff4FD18B);
  static const accent = Color(0xffFDEFE7);

  // Light mode
  static const lightBackground = Color(0xffF7F8FC);
  static const lightCardBackground = Color(0xffEFF6F2);
  static const lightInputField = Color(0xffFFFFFF);
  static const lightPrimaryText = Color(0xff1E293B);
  static const lightSecondaryText = Color(0xff64748B);
  static const lightAlertText = Color(0xffE53E3E);

  // Dark mode — inverted, keeping brand colors consistent
  static const darkBackground = Color(0xff121417);
  static const darkCardBackground = Color(0xff1E2126);
  static const darkInputField = Color(0xff2A2E35);
  static const darkPrimaryText = Color(0xffF1F5F9);
  static const darkSecondaryText = Color(0xff94A3B8);
  static const darkAlertText = Color(0xffF87171);
}
