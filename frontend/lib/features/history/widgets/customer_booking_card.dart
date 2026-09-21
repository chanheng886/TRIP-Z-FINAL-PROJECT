import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/history/widgets/history_info_chip.dart';
import 'package:frontend/features/home/view/pages/ticket_screen.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:get/get.dart';

/// Card displaying customer booking details, status, and tap-to-view navigation
class CustomerBookingCard extends StatelessWidget {
  final BookingResponse booking;

  const CustomerBookingCard({
    super.key,
    required this.booking,
  });

  static Color statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.Paid:
      case BookingStatus.Confirmed:
        return const Color(0xFF22C55E);
      case BookingStatus.Pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.Cancelled:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final color = statusColor(booking.bookingStatus);
    final dateStr =
        '${booking.travelDate.day.toString().padLeft(2, '0')}/${booking.travelDate.month.toString().padLeft(2, '0')}/${booking.travelDate.year}';

    return GestureDetector(
      onTap: () {
        Get.to(() => TicketScreen(booking: booking));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2126) : Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            // Card Header with Route and Status Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${booking.fromLocation.trDb} → ${booking.toLocation.trDb}',
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
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.bookingStatus.name.trDb,
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body with Details Chips
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      HistoryInfoChip(
                        icon: FontAwesomeIcons.calendarDay,
                        text: dateStr,
                      ),
                      const SizedBox(width: 10),
                      HistoryInfoChip(
                        icon: FontAwesomeIcons.clock,
                        text: booking.departureTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      HistoryInfoChip(
                        icon: FontAwesomeIcons.couch,
                        text: booking.seatNumbers.join(', '),
                      ),
                      const SizedBox(width: 10),
                      HistoryInfoChip(
                        icon: FontAwesomeIcons.dollarSign,
                        text: '\$${booking.totalAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Tap to view ticket',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 12,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
