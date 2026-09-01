import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:get/get.dart';
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
      'date':
          '${booking.travelDate.year}-${booking.travelDate.month.toString().padLeft(2, '0')}-${booking.travelDate.day.toString().padLeft(2, '0')}',
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
          'ticket_details'.tr,
          style: AppFonts.dmSans(
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
              'qr_code_instruction'.tr,
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
                    const FaIcon(
                      FontAwesomeIcons.busSimple,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TRIP-Z Bus',
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  booking.fromLocation.trDb,
                  style: AppFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
                  booking.toLocation.trDb,
                  style: AppFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
                  'date'.tr,
                  '${booking.travelDate.day.toString().padLeft(2, '0')}/${booking.travelDate.month.toString().padLeft(2, '0')}/${booking.travelDate.year}',
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.clock,
                  'departure'.tr,
                  booking.departureTime,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.clock,
                  'arrival'.tr,
                  booking.arrivalTime,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.user,
                  'passenger'.tr,
                  booking.username,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.couch,
                  'seats'.tr,
                  booking.seatNumbers.join(', '),
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  context,
                  isDark,
                  colorScheme,
                  FontAwesomeIcons.creditCard,
                  'Payment',
                  booking.paymentMethod.trDb,
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
                  'qr_code_instruction'.tr,
                  textAlign: TextAlign.center,
                  style: AppFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 160.0,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '#${booking.id}',
                  style: GoogleFonts.dmMono(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScallopedDivider(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: List.generate(
                (constraints.constrainWidth() / 10).floor(),
                (index) => Expanded(
                  child: Container(
                    height: 1.5,
                    color: index % 2 == 0
                        ? (isDark
                            ? const Color(0xFF2C313C)
                            : const Color(0xffE2E8F0))
                        : Colors.transparent,
                  ),
                ),
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 16,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF12161E)
                    : const Color(0xffF7F8FC),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
              ),
            ),
            Container(
              width: 16,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF12161E)
                    : const Color(0xffF7F8FC),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ],
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
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 14,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.dmSans(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              value,
              style: AppFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
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
      children: [
        FaIcon(
          icon,
          size: 14,
          color: colorScheme.onSurface.withOpacity(0.4),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppFonts.dmSans(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
