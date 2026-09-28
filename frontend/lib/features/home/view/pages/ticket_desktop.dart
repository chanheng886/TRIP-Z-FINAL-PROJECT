import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/core/utils/image_saver/image_saver.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_card.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_details_section.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_info_row.dart';
import 'package:frontend/features/home/view/widgets/ticket/ticket_pending_notice.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:get/get.dart';

class TicketDesktop extends StatefulWidget {
  final BookingResponse booking;
  const TicketDesktop({super.key, required this.booking});

  @override
  State<TicketDesktop> createState() => _TicketDesktopState();
}

class _TicketDesktopState extends State<TicketDesktop> {
  final GlobalKey _ticketKey = GlobalKey();
  bool _isSaving = false;
  bool _copiedReference = false;

  Future<void> _saveTicket() async {
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
            width: 480,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ticket_saved_success'.tr,
                    style: AppFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
            width: 480,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              '${'ticket_saved_failed'.tr} (${e.toString().replaceFirst("Exception: ", "")})',
              style: AppFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
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

  void _copyBookingReference() {
    Clipboard.setData(ClipboardData(text: 'TRIPZ-BK-${widget.booking.id}'));
    setState(() => _copiedReference = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedReference = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final booking = widget.booking;

    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C3240) : const Color(0xFFE2E8F0);
    final primaryText =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isPending = booking.bookingStatus == BookingStatus.Pending;

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
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.angleLeft,
            color: colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAll(() => const MainApp());
            }
          },
        ),
        title: Row(
          children: [
            Text(
              'ticket_details'.tr,
              style: AppFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 14),
            // Booking Reference Pill
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _copyBookingReference,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF282E3D)
                      : const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#TRIPZ-BK-${booking.id}',
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    FaIcon(
                      _copiedReference
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.copy,
                      size: 11,
                      color: _copiedReference ? AppColors.green : secondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Home button
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: OutlinedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.house, size: 13),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: borderColor, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () => Get.offAll(() => const MainApp()),
              label: Text(
                'nav_home'.tr,
                style: AppFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 920;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 20,
                  vertical: 20,
                ),
                child: isWide
                    ? _buildWideTwoColumnLayout(
                        booking: booking,
                        qrData: qrData,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        statusColor: statusColor,
                        statusText: statusText,
                        isPending: isPending,
                      )
                    : _buildMediumSingleColumnLayout(
                        booking: booking,
                        qrData: qrData,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        statusColor: statusColor,
                        statusText: statusText,
                        isPending: isPending,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 1. WIDE DESKTOP TWO-COLUMN LAYOUT (Screen Width >= 920px)
  // =========================================================================
  Widget _buildWideTwoColumnLayout({
    required BookingResponse booking,
    required String qrData,
    required bool isDark,
    required ColorScheme colorScheme,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required Color statusColor,
    required String statusText,
    required bool isPending,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Physical Boarding Pass E-Ticket Card
        SizedBox(
          width: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _ticketKey,
                child: TicketCard(
                  booking: booking,
                  qrData: qrData,
                  isDark: isDark,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(height: 16),
              // Hint below ticket card
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    size: 13,
                    color: secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Present digital QR code or printed ticket when boarding',
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Right Column: Journey Details, Notices, and Desktop Action Buttons
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Status Overview Card
              _buildDesktopStatusHeaderCard(
                booking: booking,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                statusColor: statusColor,
                statusText: statusText,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // 2. Pending Notice Banner (if pending)
              if (isPending) ...[
                TicketPendingNotice(isDark: isDark, colorScheme: colorScheme),
                const SizedBox(height: 20),
              ],

              // 3. Quick Journey Itinerary & Fare Breakdown
              _buildDesktopItineraryCard(
                booking: booking,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // 4. Important Travel Guidelines
              _buildDesktopTravelGuidelines(
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
              ),
              const SizedBox(height: 28),

              // 5. Desktop Action Buttons Bar
              _buildActionButtons(colorScheme: colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. MEDIUM SINGLE COLUMN LAYOUT (Tablet / Small Desktop 600px - 919px)
  // =========================================================================
  Widget _buildMediumSingleColumnLayout({
    required BookingResponse booking,
    required String qrData,
    required bool isDark,
    required ColorScheme colorScheme,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required Color statusColor,
    required String statusText,
    required bool isPending,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status overview
            _buildDesktopStatusHeaderCard(
              booking: booking,
              cardBg: cardBg,
              borderColor: borderColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
              statusColor: statusColor,
              statusText: statusText,
              isDark: isDark,
            ),
            const SizedBox(height: 18),

            // E-Ticket Boarding Pass
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

            if (isPending) ...[
              TicketPendingNotice(isDark: isDark, colorScheme: colorScheme),
              const SizedBox(height: 14),
            ],

            _buildDesktopTravelGuidelines(
              cardBg: cardBg,
              borderColor: borderColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            _buildActionButtons(colorScheme: colorScheme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  /// Top Status Card for Desktop
  Widget _buildDesktopStatusHeaderCard({
    required BookingResponse booking,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required Color statusColor,
    required String statusText,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(
                booking.bookingStatus == BookingStatus.Cancelled
                    ? FontAwesomeIcons.ban
                    : FontAwesomeIcons.ticket,
                color: statusColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Trip Status: ',
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.fromLocation.trDb} → ${booking.toLocation.trDb}',
                  style: AppFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Fare',
                style: AppFonts.dmSans(
                  fontSize: 11,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${booking.totalAmount.toStringAsFixed(2)}',
                style: AppFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Itinerary & Details Card
  Widget _buildDesktopItineraryCard({
    required BookingResponse booking,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
    final dateStr =
        '${booking.travelDate.day.toString().padLeft(2, '0')}/${booking.travelDate.month.toString().padLeft(2, '0')}/${booking.travelDate.year}';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Journey Details & Passengers',
            style: AppFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 16),
          // Route timeline grid
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF15181F) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Departure',
                        style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.departureTime,
                        style: AppFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      Text(
                        booking.fromLocation.trDb,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.bus,
                    size: 16,
                    color: AppColors.green,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Arrival',
                        style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.arrivalTime,
                        style: AppFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      Text(
                        booking.toLocation.trDb,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Detail grid rows
          _buildInfoRowItem(
            icon: FontAwesomeIcons.calendarDay,
            label: 'Travel Date',
            value: dateStr,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const Divider(height: 16, thickness: 0.6),
          _buildInfoRowItem(
            icon: FontAwesomeIcons.user,
            label: 'Passenger Name',
            value: booking.username,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const Divider(height: 16, thickness: 0.6),
          _buildInfoRowItem(
            icon: FontAwesomeIcons.couch,
            label: 'Reserved Seats',
            value: booking.seatNumbers.join(', '),
            primaryText: primaryText,
            secondaryText: secondaryText,
            isSeatTag: true,
          ),
          const Divider(height: 16, thickness: 0.6),
          _buildInfoRowItem(
            icon: TicketDetailsSection.getPaymentIcon(booking.paymentMethod),
            label: 'Payment Method',
            value: booking.paymentMethod.trDb,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowItem({
    required FaIconData icon,
    required String label,
    required String value,
    required Color primaryText,
    required Color secondaryText,
    bool isSeatTag = false,
  }) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: secondaryText),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppFonts.dmSans(fontSize: 13, color: secondaryText),
        ),
        const Spacer(),
        if (isSeatTag)
          Wrap(
            spacing: 6,
            children: value
                .split(',')
                .map(
                  (s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      s.trim(),
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                )
                .toList(),
          )
        else
          Text(
            value,
            style: AppFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
      ],
    );
  }

  /// Important Guidelines Section
  Widget _buildDesktopTravelGuidelines({
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleExclamation,
                size: 15,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 10),
              Text(
                'Important Travel Notices',
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TicketInfoRow(
            icon: FontAwesomeIcons.clock,
            text: 'Arrive at the station at least 15-30 minutes before departure',
            colorScheme: Theme.of(context).colorScheme,
          ),
          const SizedBox(height: 8),
          TicketInfoRow(
            icon: FontAwesomeIcons.qrcode,
            text: 'Show the digital QR code on this ticket to board the bus',
            colorScheme: Theme.of(context).colorScheme,
          ),
          const SizedBox(height: 8),
          TicketInfoRow(
            icon: FontAwesomeIcons.suitcaseRolling,
            text: 'Standard baggage allowance: 1 carry-on and 1 check-in bag (up to 20kg)',
            colorScheme: Theme.of(context).colorScheme,
          ),
        ],
      ),
    );
  }

  /// Action Buttons (Download, Print, Home)
  Widget _buildActionButtons({required ColorScheme colorScheme}) {
    return Row(
      children: [
        // 1. SAVE / DOWNLOAD TICKET (PNG)
        Expanded(
          flex: 2,
          child: SizedBox(
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
                      FontAwesomeIcons.download,
                      size: 16,
                      color: Colors.white,
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppColors.green.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isSaving ? null : _saveTicket,
              label: Text(
                _isSaving ? 'saving_ticket'.tr : 'download_ticket'.tr,
                style: AppFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // 2. BACK TO HOME
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.house, size: 14),
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
