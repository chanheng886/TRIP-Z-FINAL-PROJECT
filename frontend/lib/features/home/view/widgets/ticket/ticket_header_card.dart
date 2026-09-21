import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:get/get.dart';

/// Top branded banner for e-ticket with status badge and route
class TicketHeaderCard extends StatelessWidget {
  final BookingResponse booking;

  const TicketHeaderCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (booking.bookingStatus) {
      BookingStatus.Pending => const Color(0xFFF59E0B),
      BookingStatus.Paid => AppColors.green,
      BookingStatus.Confirmed => AppColors.green,
      BookingStatus.Cancelled => const Color(0xFFEF4444),
    };

    final statusText = switch (booking.bookingStatus) {
      BookingStatus.Pending => 'payment_pending_badge'.tr,
      BookingStatus.Paid => 'paid_badge'.tr,
      BookingStatus.Confirmed => 'status_confirmed'.tr,
      BookingStatus.Cancelled => 'status_cancelled'.tr,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xff4FD18B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.busSimple,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TRIP-Z E-TICKET',
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusText,
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            booking.fromLocation.trDb,
            style: AppFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          FaIcon(
            FontAwesomeIcons.arrowDown,
            color: Colors.white.withValues(alpha: 0.8),
            size: 13,
          ),
          const SizedBox(height: 3),
          Text(
            booking.toLocation.trDb,
            style: AppFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
