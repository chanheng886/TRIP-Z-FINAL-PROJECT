import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminBusListTile extends StatelessWidget {
  final dynamic bus;
  final Color cardBg;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;

  const AdminBusListTile({
    super.key,
    required this.bus,
    required this.cardBg,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.bus,
                size: 14,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.plateNumber,
                  style: AppFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(bus.companyName as String).trDb} • ${(bus.busType as String).trDb}',
                  style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${bus.seatCapacity} ${'seats'.tr}',
              style: AppFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminRouteListTile extends StatelessWidget {
  final dynamic route;
  final Color cardBg;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;

  const AdminRouteListTile({
    super.key,
    required this.route,
    required this.cardBg,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final from = (route.fromLocation as String).trDb;
    final to = (route.toLocation as String).trDb;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.road,
                size: 13,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    from,
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppColors.green,
                  ),
                ),
                Expanded(
                  child: Text(
                    to,
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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

class AdminScheduleListTile extends StatelessWidget {
  final BusSchedule schedule;
  final bool isDark;
  final Color cardBg;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;

  const AdminScheduleListTile({
    super.key,
    required this.schedule,
    required this.isDark,
    required this.cardBg,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired =
        schedule.isExpired || schedule.status == BusScheduleStatus.Expired;
    final isAvailable =
        !isExpired && schedule.status == BusScheduleStatus.Available;
    final accentColor = isExpired
        ? const Color(0xFFEF4444)
        : (isAvailable
            ? AppColors.green
            : (isDark ? const Color(0xFF8A8A8E) : const Color(0xFF9CA3AF)));

    final from = schedule.fromLocation.trDb;
    final to = schedule.toLocation.trDb;
    final statusLabel = isExpired ? 'expired'.tr : schedule.status.name.trDb;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpired
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                isExpired
                    ? FontAwesomeIcons.calendarXmark
                    : FontAwesomeIcons.calendarDays,
                size: 13,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$from → $to',
                  style: AppFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${schedule.plateNumber} • ${schedule.formattedDate} • ${schedule.departureTime.substring(0, 5)}',
                  style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: AppFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminBookingCard extends StatelessWidget {
  final BookingResponse booking;
  final Color cardBg;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onCancel;

  const AdminBookingCard({
    super.key,
    required this.booking,
    required this.cardBg,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    this.onMarkPaid,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (booking.bookingStatus) {
      BookingStatus.Pending => const Color(0xFFF59E0B),
      BookingStatus.Paid => AppColors.green,
      BookingStatus.Confirmed => AppColors.green,
      BookingStatus.Cancelled => const Color(0xFFEF4444),
    };

    final statusLabel = switch (booking.bookingStatus) {
      BookingStatus.Pending => 'status_pending'.tr,
      BookingStatus.Paid => 'status_paid'.tr,
      BookingStatus.Confirmed => 'status_confirmed'.tr,
      BookingStatus.Cancelled => 'status_cancelled'.tr,
    };

    final from = booking.fromLocation.trDb;
    final to = booking.toLocation.trDb;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.userCheck,
                    size: 15,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.username,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${'booking_id'.tr} #${booking.id}',
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: AppFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.route,
                  size: 12,
                  color: AppColors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$from → $to',
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _bookingInfoChip(
                FontAwesomeIcons.calendarDays,
                DateFormat('MMM dd, yyyy').format(booking.travelDate),
                secondaryText,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.clock,
                '${booking.departureTime.substring(0, 5)} - ${booking.arrivalTime.substring(0, 5)}',
                secondaryText,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.couch,
                '${'seats'.tr}: ${booking.seatNumbers.join(', ')}',
                secondaryText,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.moneyBill1,
                '\$${booking.totalAmount.toStringAsFixed(2)}',
                AppColors.green,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.creditCard,
                booking.paymentMethod.trDb,
                secondaryText,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, yyyy • hh:mm a').format(booking.bookingDate),
            style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
          ),
          if (booking.bookingStatus == BookingStatus.Pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onMarkPaid,
                    icon: const FaIcon(FontAwesomeIcons.check, size: 12, color: Colors.white),
                    label: Text(
                      'mark_as_paid'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onCancel,
                    icon: const FaIcon(FontAwesomeIcons.xmark, size: 12, color: Color(0xFFEF4444)),
                    label: Text(
                      'cancel'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ] else if (booking.bookingStatus == BookingStatus.Paid || booking.bookingStatus == BookingStatus.Confirmed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.circleCheck, size: 12, color: AppColors.green),
                  const SizedBox(width: 6),
                  Text(
                    'paid_badge'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bookingInfoChip(FaIconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
