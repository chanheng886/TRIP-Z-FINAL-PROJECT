import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/core/utils/image_saver/image_saver.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_card.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_info_row.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_pending_notice.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:get/get.dart';

class TicketMobile extends StatefulWidget {
  final BookingResponse booking;
  const TicketMobile({super.key, required this.booking});

  @override
  State<TicketMobile> createState() => _TicketMobileState();
}

class _TicketMobileState extends State<TicketMobile> {
  final GlobalKey _ticketKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveTicketToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final boundary =
          _ticketKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception("Could not find ticket render boundary");
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to convert ticket to image bytes");
      }

      final pngBytes = byteData.buffer.asUint8List();

      await ImageSaver.saveImage(
        bytes: pngBytes,
        name: 'TRIPZ_Ticket_${widget.booking.id}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ticket_saved_success'.tr,
                    style: AppFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              '${'ticket_saved_failed'.tr} (${e.toString().replaceFirst("Exception: ", "")})',
              style: AppFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final booking = widget.booking;

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

    final isPending = booking.bookingStatus == BookingStatus.Pending;

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
            // E-Ticket wrapped in RepaintBoundary for high-res image capture
            RepaintBoundary(
              key: _ticketKey,
              child: TicketCard(
                booking: booking,
                qrData: qrData,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(height: 18),

            // Pay at Station Notice Banner if Pending
            if (isPending) ...[
              TicketPendingNotice(isDark: isDark, colorScheme: colorScheme),
              const SizedBox(height: 14),
            ],

            TicketInfoRow(
              icon: FontAwesomeIcons.clock,
              text: 'Arrive at least 15 minutes before departure',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 10),
            TicketInfoRow(
              icon: FontAwesomeIcons.qrcode,
              text: 'qr_code_instruction'.tr,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),

            // 1. SAVE TO GALLERY BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const FaIcon(
                        FontAwesomeIcons.floppyDisk,
                        size: 16,
                        color: Colors.white,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: AppColors.green.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _saveTicketToGallery,
                label: Text(
                  _isSaving ? 'saving_ticket'.tr : 'save_to_gallery'.tr,
                  style: AppFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. BACK TO HOME BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.house, size: 15),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Get.offAll(() => const MainApp()),
                label: Text(
                  'nav_home'.tr,
                  style: AppFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
