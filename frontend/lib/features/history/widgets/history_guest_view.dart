import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:get/get.dart';

/// Prompt shown to unauthenticated guests visiting the tickets history
class HistoryGuestView extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const HistoryGuestView({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.ticket,
                  size: 32,
                  color: AppColors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'login_to_view_tickets'.tr,
              textAlign: TextAlign.center,
              style: AppFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'login_to_view_tickets_desc'.tr,
              textAlign: TextAlign.center,
              style: AppFonts.dmSans(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Get.to(
                  () => LoginScreen(
                    onLoginSuccess: onLoginSuccess,
                  ),
                );
              },
              icon: const FaIcon(
                FontAwesomeIcons.arrowRightToBracket,
                size: 14,
                color: Colors.white,
              ),
              label: Text(
                'login'.tr,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
