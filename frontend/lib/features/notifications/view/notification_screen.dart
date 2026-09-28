import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/notifications/viewmodel/notification_controller.dart';
import 'package:frontend/features/notifications/widgets/notification_tile.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppColors.darkBg : const Color(0xFFF7F8FA);
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryText =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final borderColor =
        isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE2E8F0);

    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.angleLeft,
            size: 18,
            color: primaryText,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'notifications'.tr,
          style: AppFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: FaIcon(
                FontAwesomeIcons.ellipsisVertical,
                size: 16,
                color: secondaryText,
              ),
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: borderColor),
              ),
              onSelected: (val) {
                if (val == 'read_all') {
                  controller.markAllAsRead();
                  Get.snackbar(
                    'notifications'.tr,
                    'mark_all_read'.tr,
                    backgroundColor: AppColors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                } else if (val == 'clear_all') {
                  controller.clearAll();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'read_all',
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.checkDouble,
                        size: 14,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'mark_all_read'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.trashCan,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'clear_all'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Obx(() {
                  final activeFilter = controller.selectedFilter.value;
                  final unread = controller.unreadCount;

                  return Row(
                    children: [
                      _filterChip(
                        label: 'filter_all'.tr,
                        isSelected: activeFilter == 'all',
                        onTap: () => controller.selectedFilter.value = 'all',
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: 'filter_unread'.tr,
                        badgeCount: unread,
                        isSelected: activeFilter == 'unread',
                        onTap: () => controller.selectedFilter.value = 'unread',
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: 'customer_bookings'.tr,
                        isSelected: activeFilter == 'bookings',
                        onTap: () => controller.selectedFilter.value = 'bookings',
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: 'trips_scheduled'.tr,
                        isSelected: activeFilter == 'trips',
                        onTap: () => controller.selectedFilter.value = 'trips',
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 6),

            // Notification List or Empty State
            Expanded(
              child: Obx(() {
                final list = controller.filteredNotifications;

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.green.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.bellSlash,
                                size: 28,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'no_notifications'.tr,
                            style: AppFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'no_notifications_desc'.tr,
                            textAlign: TextAlign.center,
                            style: AppFonts.dmSans(
                              fontSize: 13,
                              color: secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return NotificationTile(
                      notification: item,
                      isDark: isDark,
                      cardBackground: cardBg,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                      onTap: () => controller.handleNotificationTap(context, item),
                      onDelete: () => controller.deleteNotification(item.id),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    int? badgeCount,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green : borderColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFonts.dmSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : secondaryText,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
