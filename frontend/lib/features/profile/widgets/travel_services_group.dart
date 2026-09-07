import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/ai/view/ai_chat_bottom_sheet.dart';
import 'package:frontend/features/contact/view/contact_screen.dart';
import 'package:frontend/features/history/view/history_screen.dart';
import 'package:frontend/features/profile/widgets/profile_common_widgets.dart';
import 'package:get/get.dart';

class TravelServicesGroup extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color dividerColor;
  final Color primaryText;
  final Color secondaryText;

  const TravelServicesGroup({
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
          title: 'travel_services'.tr,
          textColor: primaryText,
        ),
        const SizedBox(height: 8),
        ProfileCardContainer(
          cardBg: cardBg,
          borderColor: borderColor,
          children: [
            // 1. My Bookings
            ProfileActionTile(
              icon: FontAwesomeIcons.ticket,
              iconColor: AppColors.green,
              title: 'my_bookings'.tr,
              subtitle: 'View active tickets & past travel history',
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
              onTap: () => Get.to(() => const HistoryScreen()),
            ),
            ProfileDivider(color: dividerColor),

            // 2. AI Assistant
            ProfileActionTile(
              icon: FontAwesomeIcons.wandMagicSparkles,
              iconColor: const Color(0xFF8B5CF6),
              title: 'ai_assistant'.tr,
              subtitle: 'ai_subtitle'.tr,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AiChatBottomSheet(),
              ),
            ),
            ProfileDivider(color: dividerColor),

            // 3. Help Center & Hotline
            ProfileActionTile(
              icon: FontAwesomeIcons.headset,
              iconColor: const Color(0xFF3B82F6),
              title: 'help_center'.tr,
              subtitle: 'help_center_subtitle'.tr,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
              onTap: () => Get.to(() => const ContactScreen()),
            ),
          ],
        ),
      ],
    );
  }
}
