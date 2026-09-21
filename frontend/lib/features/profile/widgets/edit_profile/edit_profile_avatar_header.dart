import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/widgets/user_avatar.dart';
import 'package:get/get.dart';

/// Top profile avatar header with camera edit badge, username, and email
class EditProfileAvatarHeader extends StatelessWidget {
  final String? profileImage;
  final String username;
  final String email;
  final VoidCallback onTapChangePhoto;
  final Color pageBg;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;

  const EditProfileAvatarHeader({
    super.key,
    required this.profileImage,
    required this.username,
    required this.email,
    required this.onTapChangePhoto,
    required this.pageBg,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(48),
            onTap: onTapChangePhoto,
            child: Stack(
              children: [
                UserAvatar(
                  profileImage: profileImage,
                  username: username,
                  size: 96,
                  fontSize: 38,
                  isDark: isDark,
                  showBorder: true,
                  borderColor: AppColors.green.withValues(alpha: 0.6),
                  borderWidth: 3,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: pageBg,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.camera,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: onTapChangePhoto,
            icon: const FaIcon(
              FontAwesomeIcons.camera,
              size: 12,
              color: AppColors.green,
            ),
            label: Text(
              'change_photo'.tr.isNotEmpty
                  ? 'change_photo'.tr
                  : 'Change Photo',
              style: AppFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            username,
            style: AppFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
        ),
        Center(
          child: Text(
            email.isNotEmpty ? email : 'user@tripz.kh',
            style: AppFonts.dmSans(
              fontSize: 12,
              color: secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
