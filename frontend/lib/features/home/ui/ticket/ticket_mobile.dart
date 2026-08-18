import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketMobile extends StatelessWidget {
  final BookingResponse booking;
  const TicketMobile({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final qrData = jsonEncode({
      'bookingId': booking.id,
      'from': booking.fromLocation,
      'to': booking.toLocation,
      'date': '${booking.travelDate.year}-${booking.travelDate.month.toString().padLeft(2, '0')}-${booking.travelDate.day.toString().padLeft(2, '0')}',
      'departure': booking.departureTime,
      'arrival': booking.arrivalTime,
      'seats': booking.seatNumbers,
      'passenger': booking.username,
      'amount': booking.totalAmount,
      'status': booking.bookingStatus.name,
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: colorScheme.onSurface,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'E-Ticket',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildTicket(context, isDark, colorScheme, qrData),
            const SizedBox(height: 24),
            _buildInfoRow(
              context,
              isDark,
              colorScheme,
              FontAwesomeIcons.clock,
              'Arrive at least 15 minutes before departure',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              context,
              isDark,
              colorScheme,
              FontAwesomeIcons.idCard,
              'Present this QR code at the boarding gate',
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              context,
              isDark,
              colorScheme,
              FontAwesomeIcons.triangleExclamation,
              'Non-refundable once confirmed',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTicket(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    String qrData,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2126) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top colored header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xff4FD18B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.busSimple,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TripZ Bus',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  booking.fromLocation,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                FaIcon(
                  FontAwesomeIcons.arrowDown,
                  color: Colors.white.withOpacity(0.8),
                  size: 14,
                ),
                const SizedBox(height: 4),
                Text(
                  booking.toLocation,
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Dashed divider (scalloped edge effect)
          _buildScallopedDivider(isDark),

          // Details section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.calendarDay,
                  'Travel Date',
                  '${booking.travelDate.day.toString().padLeft(2, '0')}/${booking.travelDate.month.toString().padLeft(2, '0')}/${booking.travelDate.year}',
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.clock,
                  'Departure',
                  booking.departureTime,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.clock,
                  'Arrival',
                  booking.arrivalTime,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.user,
                  'Passenger',
                  booking.username,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.couch,
                  'Seat(s)',
                  booking.seatNumbers.join(', '),
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.creditCard,
                  'Payment',
                  booking.paymentMethod,
                ),
              ],
            ),
          ),

          // Dashed divider (scalloped edge effect)
          _buildScallopedDivider(isDark),

          // QR Code section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Text(
                  'Scan at Boarding Gate',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: colorScheme.primary,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: const Color(0xff1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Booking #${booking.id}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Bottom colored bar with status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Status',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.bookingStatus).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.bookingStatus.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(booking.bookingStatus),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.Confirmed:
        return const Color(0xff22C55E);
      case BookingStatus.Pending:
        return const Color(0xffF59E0B);
      case BookingStatus.Cancelled:
        return const Color(0xffEF4444);
    }
  }

  Widget _buildScallopedDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(30, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 2,
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    FaIconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: colorScheme.primary,
              size: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    FaIconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FaIcon(
          icon,
          size: 14,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
