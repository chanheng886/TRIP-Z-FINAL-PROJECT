import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/history/widgets/history_info_chip.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';

/// Card displaying bus schedule details in the admin history schedules tab
class AdminScheduleCard extends StatelessWidget {
  final BusSchedule schedule;

  const AdminScheduleCard({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isExpired =
        schedule.isExpired || schedule.status == BusScheduleStatus.Expired;
    final isAvailable =
        !isExpired && schedule.status == BusScheduleStatus.Available;
    final statusColor = isExpired
        ? const Color(0xFFEF4444)
        : (isAvailable ? const Color(0xFF22C55E) : const Color(0xFFF59E0B));
    final statusLabel = isExpired ? 'expired'.tr : schedule.status.name.trDb;
    final dateStr =
        '${schedule.travelDate.day.toString().padLeft(2, '0')}/${schedule.travelDate.month.toString().padLeft(2, '0')}/${schedule.travelDate.year}';

    final depTime = schedule.departureTime.length >= 5
        ? schedule.departureTime.substring(0, 5)
        : schedule.departureTime;
    final arrTime = schedule.arrivalTime.length >= 5
        ? schedule.arrivalTime.substring(0, 5)
        : schedule.arrivalTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2126) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Route and Status Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${schedule.fromLocation.trDb} → ${schedule.toLocation.trDb}',
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Metadata Chips
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    HistoryInfoChip(
                      icon: FontAwesomeIcons.calendarDay,
                      text: dateStr,
                    ),
                    const SizedBox(width: 8),
                    HistoryInfoChip(
                      icon: FontAwesomeIcons.clock,
                      text: '$depTime - $arrTime',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    HistoryInfoChip(
                      icon: FontAwesomeIcons.bus,
                      text: schedule.plateNumber,
                    ),
                    const SizedBox(width: 8),
                    HistoryInfoChip(
                      icon: FontAwesomeIcons.moneyBill1,
                      text: '\$${schedule.basePrice.toStringAsFixed(2)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    HistoryInfoChip(
                      icon: FontAwesomeIcons.couch,
                      text: '${schedule.availableSeat} seats left',
                    ),
                    const SizedBox(width: 8),
                    HistoryInfoChip(
                      icon: FontAwesomeIcons.building,
                      text: schedule.companyName.trDb,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
