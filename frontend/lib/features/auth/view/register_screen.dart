import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGender = 'Male';
  bool _obscurePassword = true;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AuthViewmodel authVM) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authVM.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      gender: _selectedGender,
      phone: _phoneController.text.trim(),
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
                ? 'register_failed'.tr
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

    InputDecoration fieldDecoration({
      required String label,
      String? hint,
      required FaIconData icon,
      Widget? suffix,
    }) {
      return InputDecoration(
        filled: true,
        fillColor: inputFieldColor,
        labelText: label,
        hintText: hint,
        labelStyle: AppFonts.dmSans(color: secondaryText),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, top: 12),
          child: FaIcon(icon, color: AppColors.primary, size: 18),
        ),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: isDarkMode ? Colors.white : Colors.black87,
            size: 18,
          ),
        ),
        title: Obx(() {
          final _ = languageController.locale.value;
          return Text(
            'register'.tr,
            style: AppFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      const SizedBox(width: 4),
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
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Obx(() {
                  final _ = languageController.locale.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'register_subtitle'.tr,
                        textAlign: TextAlign.center,
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          color: secondaryText,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Username
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: fieldDecoration(
                          label: 'username'.tr,
                          hint: 'enter_username'.tr,
                          icon: FontAwesomeIcons.user,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'username_required'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: fieldDecoration(
                          label: 'email'.tr,
                          hint: 'enter_email'.tr,
                          icon: FontAwesomeIcons.envelope,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'email_required'.tr;
                          }
                          final emailRegex =
                              RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: fieldDecoration(
                          label: 'phone'.tr,
                          hint: 'enter_phone'.tr,
                          icon: FontAwesomeIcons.phone,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'phone_required'.tr;
                          }
                          final phoneRegex = RegExp(r'^[0-9]{9,12}$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return 'Phone must be 9-12 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Gender
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 8,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        initialValue: _selectedGender,
                        decoration: fieldDecoration(
                          label: 'gender'.tr,
                          icon: FontAwesomeIcons.venusMars,
                        ),
                        dropdownColor: inputFieldColor,
                        items: _genders
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(
                                    g == 'Male'
                                        ? 'male'.tr
                                        : (g == 'Female' ? 'female'.tr : 'other'.tr),
                                    style: AppFonts.dmSans(
                                        color: primaryText),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: fieldDecoration(
                          label: 'password'.tr,
                          hint: 'enter_password'.tr,
                          icon: FontAwesomeIcons.lock,
                          suffix: IconButton(
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'password_required'.tr;
                          }
                          if (value.length < 6) {
                            return 'password_length_error'.tr;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      // Register Button
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
                                : () => _handleRegister(authVM),
                            child: authVM.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  )
                                : Text(
                                    'create_account'.tr,
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
                              'already_have_account'.tr,
                              textAlign: TextAlign.center,
                              style: AppFonts.dmSans(color: secondaryText),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.off(() => const LoginScreen());
                            },
                            child: Text(
                              'login'.tr,
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
      ),
    );
  }
}
