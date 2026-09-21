import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Social login buttons row (Facebook, Twitter/X, Google) matching the reference design.
class SocialLoginButtons extends StatelessWidget {
  final bool isDarkMode;

  const SocialLoginButtons({super.key, required this.isDarkMode});

  Widget _buildSocialCircle({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF242731) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDarkMode ? const Color(0xFF333846) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Facebook
            _buildSocialCircle(
              icon: const FaIcon(
                FontAwesomeIcons.facebookF,
                size: 18,
                color: Color(0xFF1877F2),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Facebook sign-in coming soon',
                      style: AppFonts.dmSans(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),

            // Twitter / X
            _buildSocialCircle(
              icon: const FaIcon(
                FontAwesomeIcons.twitter,
                size: 18,
                color: Color(0xFF0284C7),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Twitter sign-in coming soon',
                      style: AppFonts.dmSans(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),

            // Google+ / Google
            _buildSocialCircle(
              icon: const FaIcon(
                FontAwesomeIcons.google,
                size: 18,
                color: Color(0xFFEA4335),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Google sign-in coming soon',
                      style: AppFonts.dmSans(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'or_use_email_account'.tr,
          style: AppFonts.dmSans(
            fontSize: 12.5,
            color: isDarkMode
                ? const Color(0xFF94A3B8)
                : const Color(0xFF94A3B8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
