import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/profile/widgets/profile_common_widgets.dart';
import 'package:frontend/features/profile/widgets/profile_dialogs.dart';
import 'package:get/get.dart';

class SupportLegalGroup extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color dividerColor;
  final Color primaryText;
  final Color secondaryText;

  const SupportLegalGroup({
    super.key,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.dividerColor,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSectionTitle(
          title: 'support_and_legal'.tr,
          textColor: primaryText,
        ),
        const SizedBox(height: 8),
        ProfileCardContainer(
          cardBg: cardBg,
          borderColor: borderColor,
          children: [
            // 1. About Us
            ProfileActionTile(
              icon: FontAwesomeIcons.circleInfo,
              iconColor: const Color(0xFF64748B),
              title: 'about_us'.tr,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
              onTap: () => ProfileDialogs.showAbout(context, isDark),
            ),
            ProfileDivider(color: dividerColor),

            // 2. Privacy Policy
            ProfileActionTile(
              icon: FontAwesomeIcons.shield,
              iconColor: const Color(0xFF64748B),
              title: 'privacy_policy'.tr,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
              onTap: () => ProfileDialogs.showLegal(
                context,
                title: 'privacy_policy'.tr,
                content:
                    'Your privacy is guaranteed. TRIP-Z does not share your private data with third parties.',
                isDark: isDark,
              ),
            ),
            ProfileDivider(color: dividerColor),

            // 3. Terms of Service
            ProfileActionTile(
              icon: FontAwesomeIcons.fileContract,
              iconColor: const Color(0xFF64748B),
              title: 'terms_of_service'.tr,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
              onTap: () => ProfileDialogs.showLegal(
                context,
                title: 'terms_of_service'.tr,
                content:
                    'By using TRIP-Z bus booking, you agree to fair usage policies, punctuality at pickup terminals, and passenger conduct standards.',
                isDark: isDark,
              ),
            ),
            ProfileDivider(color: dividerColor),

            // 4. App Version
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF64748B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.codeBranch,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'app_version'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C30)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'v1.0.0 (Build 2026)',
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
