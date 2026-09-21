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
    final isGuest = user == null;
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
              value: isGuest
                  ? 'guest_user'.tr
                  : (user!.username.isNotEmpty ? user!.username : 'User'),
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
              value: isGuest
                  ? 'guest_user_desc'.tr
                  : (user!.email.isNotEmpty ? user!.email : 'No email provided'),
              badge: isGuest ? null : 'verified'.tr,
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
              value: isGuest
                  ? 'Not provided'
                  : (user!.phone.isNotEmpty ? user!.phone : 'No phone number'),
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
              iconColor: isAdmin
                  ? const Color(0xFFF59E0B)
                  : (isGuest ? const Color(0xFF94A3B8) : AppColors.green),
              title: 'role'.tr,
              value: isGuest
                  ? 'guest_user'.tr
                  : (isAdmin ? 'administrator'.tr : 'passenger_member'.tr),
              badge: isGuest ? 'GUEST' : (isAdmin ? 'ADMIN' : 'VIP'),
              badgeColor: isGuest
                  ? const Color(0xFF64748B)
                  : (isAdmin ? const Color(0xFFF59E0B) : AppColors.green),
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
