import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR code validation section of e-ticket with monospace booking reference
class TicketQrSection extends StatelessWidget {
  final String qrData;
  final int bookingId;
  final ColorScheme colorScheme;

  const TicketQrSection({
    super.key,
    required this.qrData,
    required this.bookingId,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        children: [
          Text(
            'qr_code_instruction'.tr,
            textAlign: TextAlign.center,
            style: AppFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 150.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '#$bookingId',
            style: GoogleFonts.dmMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
