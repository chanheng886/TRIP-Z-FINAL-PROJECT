import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/notifications/model/app_notification.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isDark,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    required this.onTap,
    required this.onDelete,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color iconBg;
    FaIconData icon;

    switch (notification.type) {
      case 'ADMIN_NEW_BOOKING':
        iconColor = AppColors.green;
        iconBg = AppColors.green.withValues(alpha: 0.12);
        icon = FontAwesomeIcons.ticket;
        break;
      case 'DEPARTURE_ALERT':
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFEF4444).withValues(alpha: 0.12);
        icon = FontAwesomeIcons.bus;
        break;
      case 'BOOKING_CONFIRMED':
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFF10B981).withValues(alpha: 0.12);
        icon = FontAwesomeIcons.circleCheck;
        break;
      case 'SYSTEM':
      default:
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFF3B82F6).withValues(alpha: 0.12);
        icon = FontAwesomeIcons.bell;
        break;
    }

    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const FaIcon(
          FontAwesomeIcons.trashCan,
          color: Colors.white,
          size: 18,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark
                  ? const Color(0xFF1C2230)
                  : const Color(0xFFF0FDF4))
              : cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.green.withValues(alpha: 0.35)
                : borderColor,
            width: isUnread ? 1.4 : 1.0,
          ),
          boxShadow: [
            if (isUnread)
              BoxShadow(
                color: AppColors.green.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(icon, size: 16, color: iconColor),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppFonts.dmSans(
                                fontSize: 14,
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(notification.timestamp),
                            style: AppFonts.dmSans(
                              fontSize: 11,
                              color: secondaryText,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification.body,
                        style: AppFonts.dmSans(
                          fontSize: 12.5,
                          color: isUnread
                              ? (isDark ? Colors.white70 : const Color(0xFF334155))
                              : secondaryText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
