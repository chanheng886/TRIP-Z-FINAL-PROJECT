import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/model/user.dart';

class ProfileUserCard extends StatelessWidget {
  final User? user;
  final bool isDarkMode;
  final Color cardColor;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final VoidCallback? onTap;

  const ProfileUserCard({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.cardColor,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=300&q=80',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.green.withValues(alpha: 0.15),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          color: AppColors.green,
                          size: 22,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.green.withValues(alpha: 0.15),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          color: AppColors.green,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? 'Admin',
                      style: AppFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email.isNotEmpty == true
                          ? user!.email
                          : 'chanheng@yahoo.com',
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: secondaryText.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
