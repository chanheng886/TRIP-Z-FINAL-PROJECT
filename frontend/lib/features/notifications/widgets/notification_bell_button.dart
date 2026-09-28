import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/notifications/view/notification_screen.dart';
import 'package:frontend/features/notifications/viewmodel/notification_controller.dart';
import 'package:get/get.dart';

class NotificationBellButton extends StatelessWidget {
  final double size;
  final bool? isDark;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  const NotificationBellButton({
    super.key,
    this.size = 40,
    this.isDark,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final bg = backgroundColor ??
        (dark ? AppColors.darkSurface : AppColors.lightSurface);
    final border = borderColor ??
        (dark ? const Color(0xFF2A2A2E) : const Color(0xFFE2E8F0));
    final iconCol = iconColor ??
        (dark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText);

    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);

    return InkWell(
      onTap: () => Get.to(() => const NotificationScreen()),
      borderRadius: BorderRadius.circular(size * 0.32),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size * 0.32),
          border: Border.all(color: border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.bell,
              size: size * 0.42,
              color: iconCol,
            ),
            Obx(() {
              final count = controller.unreadCount;
              if (count <= 0) return const SizedBox.shrink();

              return Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: bg,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: AppFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
