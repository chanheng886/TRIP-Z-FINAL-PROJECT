import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:frontend/features/profile/widgets/logout_dialog.dart';
import 'package:get/get.dart';

/// Section header title with uniform DM Sans typography
class ProfileSectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const ProfileSectionTitle({
    super.key,
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Card container wrapping rows of tiles with rounded borders
class ProfileCardContainer extends StatelessWidget {
  final Color cardBg;
  final Color borderColor;
  final List<Widget> children;

  const ProfileCardContainer({
    super.key,
    required this.cardBg,
    required this.borderColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Information tile for user attributes (username, email, role, etc.)
class ProfileInfoTile extends StatelessWidget {
  final FaIconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? badge;
  final Color? badgeColor;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.badge,
    this.badgeColor,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: FaIcon(icon, size: 14, color: iconColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: AppFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.green).withValues(
                  alpha: isDark ? 0.18 : 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: AppFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor ?? AppColors.green,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Actionable tile for navigation and interactive shortcuts
class ProfileActionTile extends StatelessWidget {
  final FaIconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailingWidget;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;
  final VoidCallback onTap;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailingWidget,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: FaIcon(icon, size: 14, color: iconColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        color: secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            trailingWidget ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: secondaryText,
                ),
          ],
        ),
      ),
    );
  }
}

/// Preference switch tile
class ProfileSwitchTile extends StatelessWidget {
  final FaIconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primaryText;
  final bool isDark;

  const ProfileSwitchTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.primaryText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: FaIcon(icon, size: 14, color: iconColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark
                ? const Color(0xFF2C2C30)
                : const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }
}

/// Common indented divider
class ProfileDivider extends StatelessWidget {
  final Color color;
  final double indent;

  const ProfileDivider({
    super.key,
    required this.color,
    this.indent = 62,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: color, indent: indent);
  }
}

/// Logout button with dialog trigger
class ProfileLogoutButton extends StatelessWidget {
  final ProfileViewModel viewModel;
  final bool isDark;

  const ProfileLogoutButton({
    super.key,
    required this.viewModel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
          backgroundColor: const Color(
            0xFFEF4444,
          ).withValues(alpha: isDark ? 0.12 : 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => LogoutDialog.show(context, viewModel, isDark),
        icon: const FaIcon(
          FontAwesomeIcons.arrowRightFromBracket,
          size: 14,
          color: Color(0xFFEF4444),
        ),
        label: Text(
          'log_out'.tr,
          style: AppFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEF4444),
          ),
        ),
      ),
    );
  }
}
