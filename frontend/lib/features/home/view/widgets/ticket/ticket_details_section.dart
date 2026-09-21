import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_detail_row.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:get/get.dart';

/// Middle section of e-ticket displaying journey details, passenger, seats, and price
class TicketDetailsSection extends StatelessWidget {
  final BookingResponse booking;
  final ColorScheme colorScheme;

  const TicketDetailsSection({
    super.key,
    required this.booking,
    required this.colorScheme,
  });

  static FaIconData getPaymentIcon(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('station') || lower.contains('cash')) {
      return FontAwesomeIcons.moneyBillWave;
    }
    if (lower.contains('paypal')) return FontAwesomeIcons.paypal;
    if (lower.contains('master')) return FontAwesomeIcons.ccMastercard;
    if (lower.contains('acleda') || lower.contains('aba') || lower.contains('bank')) {
      return FontAwesomeIcons.buildingColumns;
    }
    return FontAwesomeIcons.creditCard;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        children: [
          TicketDetailRow(
            icon: FontAwesomeIcons.calendarDay,
            label: 'date'.tr,
            value:
                '${booking.travelDate.day.toString().padLeft(2, '0')}/${booking.travelDate.month.toString().padLeft(2, '0')}/${booking.travelDate.year}',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          TicketDetailRow(
            icon: FontAwesomeIcons.clock,
            label: 'departure'.tr,
            value: booking.departureTime,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          TicketDetailRow(
            icon: FontAwesomeIcons.clock,
            label: 'arrival'.tr,
            value: booking.arrivalTime,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          TicketDetailRow(
            icon: FontAwesomeIcons.user,
            label: 'passenger'.tr,
            value: booking.username,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          TicketDetailRow(
            icon: FontAwesomeIcons.couch,
            label: 'seats'.tr,
            value: booking.seatNumbers.join(', '),
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          TicketDetailRow(
            icon: getPaymentIcon(booking.paymentMethod),
            label: 'payment_method'.tr,
            value: booking.paymentMethod.trDb,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          TicketDetailRow(
            icon: FontAwesomeIcons.moneyBillWave,
            label: 'total_price'.tr,
            value: '\$${booking.totalAmount.toStringAsFixed(2)}',
            valueColor: AppColors.green,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}
