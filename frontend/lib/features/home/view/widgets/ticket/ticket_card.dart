import 'package:flutter/material.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_details_section.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_header_card.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_qr_section.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_scalloped_divider.dart';
import 'package:frontend/shared/model/booking_response.dart';

/// Complete printable e-ticket card composed of header, details, and QR verification
class TicketCard extends StatelessWidget {
  final BookingResponse booking;
  final String qrData;
  final bool isDark;
  final ColorScheme colorScheme;

  const TicketCard({
    super.key,
    required this.booking,
    required this.qrData,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2126) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TicketHeaderCard(booking: booking),
          TicketScallopedDivider(isDark: isDark),
          TicketDetailsSection(booking: booking, colorScheme: colorScheme),
          TicketScallopedDivider(isDark: isDark),
          TicketQrSection(
            qrData: qrData,
            bookingId: booking.id,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}
