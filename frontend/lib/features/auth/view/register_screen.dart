import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/auth/widgets/auth_button.dart';
import 'package:frontend/features/auth/widgets/auth_footer_link.dart';
import 'package:frontend/features/auth/widgets/auth_gender_selector.dart';
import 'package:frontend/features/auth/widgets/auth_header_art.dart';
import 'package:frontend/features/auth/widgets/auth_text_field.dart';
import 'package:frontend/features/auth/widgets/auth_top_nav_bar.dart';
import 'package:frontend/features/auth/widgets/registration_success_dialog.dart';
import 'package:frontend/features/auth/widgets/social_login_buttons.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegisterSuccess;
  const RegisterScreen({super.key, this.onRegisterSuccess});

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
      // Show "Thank you for your registration!" modal
      await RegistrationSuccessDialog.show(
        context,
        onContinue: () {
          if (widget.onRegisterSuccess != null) {
            Get.back();
            widget.onRegisterSuccess!();
          } else {
            Get.offAll(() => const MainApp());
          }
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.lightAlertText,
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
    final cardBg = isDarkMode ? AppColors.darkSurface : Colors.white;
    final primaryTextColor = isDarkMode
        ? AppColors.darkPrimaryText
        : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: cardBg,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // ────────────────── TOP CURVED BRAND HEADER ──────────────────
            Stack(
              children: [
                AuthHeaderArt(
                  isRegister: true,
                  isDarkMode: isDarkMode,
                  height: 250,
                ),
                const AuthTopNavBar(),
              ],
            ),

            // ────────────── WHITE / DARK ROUNDED FORM CARD ──────────────
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(34),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDarkMode ? 0.4 : 0.08,
                      ),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Title
                          Text(
                            'create_new_account'.tr,
                            textAlign: TextAlign.center,
                            style: AppFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 2. Social Login Icons Row & "or use your email account"
                          SocialLoginButtons(isDarkMode: isDarkMode),
                          const SizedBox(height: 24),

                          // 3. Email Input Field (Highlighted green outline like reference)
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'name@ |',
                            isDarkMode: isDarkMode,
                            isHighlighted: true,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'email_required'.tr;
                              }
                              if (!GetUtils.isEmail(value.trim())) {
                                return 'invalid_email'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. Name / Username Input Field
                          AuthTextField(
                            controller: _usernameController,
                            label: 'Name',
                            hint: 'enter_username'.tr,
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'username_required'.tr;
                              }
                              if (value.trim().length < 3) {
                                return 'username_too_short'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 5. Phone Input Field
                          AuthTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            hint: '012 345 678',
                            isDarkMode: isDarkMode,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'phone_required'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 6. Gender Selection Segmented Row
                          AuthGenderSelector(
                            selectedGender: _selectedGender,
                            genders: _genders,
                            isDarkMode: isDarkMode,
                            onGenderChanged: (gender) {
                              setState(() {
                                _selectedGender = gender;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // 7. Password Input Field
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            isDarkMode: isDarkMode,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              splashRadius: 20,
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: FaIcon(
                                _obscurePassword
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                color: isDarkMode
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                size: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'password_required'.tr;
                              }
                              if (value.length < 6) {
                                return 'password_too_short'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // 8. Pill REGISTER Action Button
                          Obx(() {
                            final authVM = Get.find<AuthViewmodel>();
                            return AuthButton(
                              text: 'REGISTER',
                              isLoading: authVM.isLoading.value,
                              onPressed: () => _handleRegister(authVM),
                            );
                          }),
                          const SizedBox(height: 24),

                          // 9. Footer: Already have an account? Login here
                          AuthFooterLink(
                            promptText: 'already_have_account_q'.tr,
                            actionText: 'login_here'.tr,
                            isDarkMode: isDarkMode,
                            onTap: () {
                              Get.off(
                                () => LoginScreen(
                                  onLoginSuccess: widget.onRegisterSuccess,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
