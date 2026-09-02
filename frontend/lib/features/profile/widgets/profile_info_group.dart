import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:get/get.dart';

class ProfileInfoGroup extends StatelessWidget {
  final User? user;
  final bool isDarkMode;
  final Color cardColor;
  final Color primaryText;
  final Color secondaryText;
  final Color dividerColor;
  final Color borderColor;

  const ProfileInfoGroup({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.cardColor,
    required this.primaryText,
    required this.secondaryText,
    required this.dividerColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // 1. Role
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.user,
                  size: 18,
                  color: primaryText,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'role'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        user?.role.name ?? 'Admin',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.8, color: dividerColor),

          // 2. Phone
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.phone,
                  size: 18,
                  color: primaryText,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'phone'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        user?.phone.isNotEmpty == true
                            ? user!.phone
                            : '+855 90 918 123',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
