import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Warning banner displayed when ticket payment status is Pending
class TicketPendingNotice extends StatelessWidget {
  final bool isDark;
  final ColorScheme colorScheme;

  const TicketPendingNotice({
    super.key,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.circleInfo,
              size: 14,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'payment_pending_badge'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'pay_at_station_notice'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.35,
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
