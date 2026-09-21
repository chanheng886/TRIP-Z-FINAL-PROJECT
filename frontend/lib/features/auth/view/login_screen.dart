import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/view/register_screen.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/auth/widgets/auth_button.dart';
import 'package:frontend/features/auth/widgets/auth_footer_link.dart';
import 'package:frontend/features/auth/widgets/auth_header_art.dart';
import 'package:frontend/features/auth/widgets/auth_remember_row.dart';
import 'package:frontend/features/auth/widgets/auth_text_field.dart';
import 'package:frontend/features/auth/widgets/auth_top_nav_bar.dart';
import 'package:frontend/features/auth/widgets/social_login_buttons.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

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
      if (widget.onLoginSuccess != null) {
        Get.back();
        widget.onLoginSuccess!();
      } else {
        Get.offAll(() => const MainApp());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.lightAlertText,
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
                  isRegister: false,
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
                            'login_to_your_account'.tr,
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

                          // 3. Username / Email Input Field
                          AuthTextField(
                            controller: _usernameController,
                            label: 'Email or username',
                            hint: 'name@ | username',
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'username_required'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. Password Input Field
                          AuthTextField(
                            controller: _passwordController,
                            label: 'password'.tr,
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
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // 5. Options Row: Remember Me & Forgot Password
                          AuthRememberRow(
                            rememberMe: _rememberMe,
                            onRememberMeChanged: (val) {
                              setState(() => _rememberMe = val);
                            },
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 24),

                          // 6. Pill LOGIN Action Button
                          Obx(() {
                            final authVM = Get.find<AuthViewmodel>();
                            return AuthButton(
                              text: 'LOGIN',
                              isLoading: authVM.isLoading.value,
                              onPressed: () => _handleLogin(authVM),
                            );
                          }),
                          const SizedBox(height: 24),

                          // 7. Footer: Don't have an account? Register here
                          AuthFooterLink(
                            promptText: 'dont_have_account_q'.tr,
                            actionText: 'register_here'.tr,
                            isDarkMode: isDarkMode,
                            onTap: () {
                              Get.off(
                                () => RegisterScreen(
                                  onRegisterSuccess: widget.onLoginSuccess,
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
