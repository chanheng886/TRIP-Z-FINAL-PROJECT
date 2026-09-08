import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/profile/view/edit_profile_screen.dart';
import 'package:frontend/shared/widgets/user_avatar.dart';
import 'package:get/get.dart';

class HeroProfileCard extends StatelessWidget {
  final User? user;
  final bool isAdmin;
  final bool isDark;

  const HeroProfileCard({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final username = user?.username.isNotEmpty == true
        ? user!.username
        : 'User';
    final email = user?.email.isNotEmpty == true
        ? user!.email
        : 'user@tripz.kh';
    final memberId = 'TRIPZ-USR-${user?.id ?? 1024}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E222A), Color(0xFF15181E)]
              : const [Color(0xFF1C1F2E), Color(0xFF2A3048)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3440) : const Color(0xFF3B4261),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar with Online indicator (tap to edit profile)
              UserAvatar(
                profileImage: user?.profileImage,
                username: username,
                size: 66,
                fontSize: 26,
                showOnlineIndicator: true,
                isDark: isDark,
                borderColor: AppColors.green.withValues(alpha: 0.5),
                borderWidth: 2,
                onTap: () => Get.to(() => const EditProfileScreen()),
              ),
              const SizedBox(width: 16),
              // Name, Role & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            username,
                            style: AppFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.18)
                            : AppColors.green.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isAdmin
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                              : AppColors.green.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.star_rounded,
                            size: 12,
                            color: isAdmin
                                ? const Color(0xFFFBBF24)
                                : AppColors.greenBright,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAdmin
                                ? 'administrator'.tr.toUpperCase()
                                : 'tier_gold'.tr.toUpperCase(),
                            style: AppFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isAdmin
                                  ? const Color(0xFFFBBF24)
                                  : AppColors.greenBright,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Profile Icon Button
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Get.to(() => const EditProfileScreen()),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 14),

          // Member ID & Quick Copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${'member_id'.tr}: ',
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    memberId,
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: memberId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.green,
                      duration: const Duration(seconds: 2),
                      content: Text(
                        'copied'.tr,
                        style: AppFonts.dmSans(color: Colors.white),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.copy,
                        size: 11,
                        color: AppColors.greenBright,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greenBright,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
