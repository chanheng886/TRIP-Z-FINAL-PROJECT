import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/profile/widgets/profile_common_widgets.dart';
import 'package:get/get.dart';

class AccountInfoGroup extends StatelessWidget {
  final User? user;
  final bool isAdmin;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color dividerColor;
  final Color primaryText;
  final Color secondaryText;

  const AccountInfoGroup({
    super.key,
    required this.user,
    required this.isAdmin,
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
          title: 'account_info'.tr,
          textColor: primaryText,
        ),
        const SizedBox(height: 8),
        ProfileCardContainer(
          cardBg: cardBg,
          borderColor: borderColor,
          children: [
            // Username
            ProfileInfoTile(
              icon: FontAwesomeIcons.solidUser,
              iconColor: AppColors.green,
              title: 'username'.tr,
              value: user?.username.isNotEmpty == true ? user!.username : 'User',
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),
            ProfileDivider(color: dividerColor),

            // Email
            ProfileInfoTile(
              icon: FontAwesomeIcons.solidEnvelope,
              iconColor: const Color(0xFF3B82F6),
              title: 'Email',
              value: user?.email.isNotEmpty == true
                  ? user!.email
                  : 'No email provided',
              badge: 'verified'.tr,
              badgeColor: AppColors.green,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),
            ProfileDivider(color: dividerColor),

            // Phone
            ProfileInfoTile(
              icon: FontAwesomeIcons.phone,
              iconColor: const Color(0xFF10B981),
              title: 'Phone',
              value: user?.phone.isNotEmpty == true
                  ? user!.phone
                  : 'No phone number',
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),

            // Gender (if provided)
            if (user?.gender.isNotEmpty == true) ...[
              ProfileDivider(color: dividerColor),
              ProfileInfoTile(
                icon: FontAwesomeIcons.venusMars,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Gender',
                value: user!.gender,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
              ),
            ],

            ProfileDivider(color: dividerColor),

            // Role
            ProfileInfoTile(
              icon: FontAwesomeIcons.shieldHalved,
              iconColor: isAdmin ? const Color(0xFFF59E0B) : AppColors.green,
              title: 'role'.tr,
              value: isAdmin ? 'administrator'.tr : 'passenger_member'.tr,
              badge: isAdmin ? 'ADMIN' : 'VIP',
              badgeColor: isAdmin ? const Color(0xFFF59E0B) : AppColors.green,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}
