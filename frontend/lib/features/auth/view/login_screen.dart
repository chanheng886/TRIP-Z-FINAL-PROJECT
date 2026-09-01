import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/view/register_screen.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthViewmodel authVM) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authVM.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Get.offAll(() => const MainApp());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authVM.errorMessage.value.isEmpty
                ? 'login_failed'.tr
                : authVM.errorMessage.value,
            style: AppFonts.dmSans(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final inputFieldColor =
        isDarkMode ? AppColors.darkInputField : AppColors.lightInputField;
    final primaryText =
        isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            // Language selector button in top right
            Positioned(
              top: 12,
              right: 16,
              child: Obx(() {
                final currentLang = languageController.currentLanguage;
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (languageController.isKhmer) {
                      languageController.changeLanguage('en', 'US');
                    } else {
                      languageController.changeLanguage('km', 'KH');
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E222B)
                          : const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentLang.flag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          currentLang.nativeName,
                          style: AppFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Obx(() {
                      final _ = languageController.locale.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          // Logo
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.bus,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'TRIP-Z',
                            textAlign: TextAlign.center,
                            style: AppFonts.dmSans(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'login_subtitle'.tr,
                            textAlign: TextAlign.center,
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: inputFieldColor,
                              labelText: 'username'.tr,
                              hintText: 'enter_username'.tr,
                              labelStyle:
                                  AppFonts.dmSans(color: secondaryText),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 14, top: 12),
                                child: FaIcon(
                                  FontAwesomeIcons.user,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'username_required'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: inputFieldColor,
                              labelText: 'password'.tr,
                              hintText: 'enter_password'.tr,
                              labelStyle:
                                  AppFonts.dmSans(color: secondaryText),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 14, top: 12),
                                child: FaIcon(
                                  FontAwesomeIcons.lock,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: FaIcon(
                                  _obscurePassword
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  color: secondaryText,
                                  size: 18,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'password_required'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          // Login Button
                          SizedBox(
                            height: 52,
                            child: Obx(() {
                              final authVM = Get.find<AuthViewmodel>();
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: authVM.isLoading.value
                                    ? null
                                    : () => _handleLogin(authVM),
                                child: authVM.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      )
                                    : Text(
                                        'sign_in'.tr,
                                        style: AppFonts.dmSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'dont_have_account'.tr,
                                  textAlign: TextAlign.center,
                                  style:
                                      AppFonts.dmSans(color: secondaryText),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.off(() => const RegisterScreen());
                                },
                                child: Text(
                                  'register'.tr,
                                  style: AppFonts.dmSans(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
