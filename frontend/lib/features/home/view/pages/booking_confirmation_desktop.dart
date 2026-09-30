import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/view/pages/ticket_screen.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/shared/service/payment_launcher_service.dart';
import 'package:get/get.dart';

class BookingConfirmationDesktop extends StatelessWidget {
  final BookingResponse booking;

  const BookingConfirmationDesktop({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2C2C30)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Success Icon Badge
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        color: AppColors.green,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Title & Booking Code
                  Text(
                    'booking_success'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'booking_code'.tr}: #${booking.id}',
                    style: AppFonts.dmSans(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Trip Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161922)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2C2C30)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.fromLocation.trDb,
                                    style: AppFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.departureTime,
                                    style: AppFonts.dmSans(
                                      fontSize: 13,
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.arrowRight,
                                color: colorScheme.primary,
                                size: 16,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    booking.toLocation.trDb,
                                    style: AppFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.arrivalTime,
                                    style: AppFonts.dmSans(
                                      fontSize: 13,
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        _detailRow(
                          'passenger'.tr,
                          booking.username,
                          colorScheme,
                        ),
                        _detailRow(
                          'date'.tr,
                          '${booking.travelDate.year}-${booking.travelDate.month.toString().padLeft(2, '0')}-${booking.travelDate.day.toString().padLeft(2, '0')}',
                          colorScheme,
                        ),
                        _detailRow(
                          'seats'.tr,
                          booking.seatNumbers.join(', '),
                          colorScheme,
                        ),
                        _detailRow(
                          'payment_method'.tr,
                          booking.paymentMethod.trDb,
                          colorScheme,
                        ),
                        _detailRow(
                          'status'.tr,
                          booking.bookingStatus.name.trDb,
                          colorScheme,
                        ),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total_price'.tr,
                              style: AppFonts.dmSans(
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '\$${booking.totalAmount.toStringAsFixed(2)}',
                              style: AppFonts.dmSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 4. Action Buttons
                  if (booking.paymentMethod.toLowerCase().contains('acleda')) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const FaIcon(
                          FontAwesomeIcons.buildingColumns,
                          size: 15,
                          color: Color(0xFFFFDF79),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3B66),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFD4AF37),
                              width: 1.2,
                            ),
                          ),
                          elevation: 1,
                        ),
                        onPressed: () {
                          PaymentLauncherService.launchAcledaSuperApp(
                            amount: booking.totalAmount,
                            bookingCode: '${booking.id}',
                          );
                        },
                        label: Text(
                          'open_acleda_app'.tr,
                          style: AppFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (booking.paymentMethod.toLowerCase().contains('aba')) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const FaIcon(
                          FontAwesomeIcons.buildingColumns,
                          size: 15,
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005A9C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        onPressed: () {
                          PaymentLauncherService.launchAbaMobileApp();
                        },
                        label: Text(
                          'open_aba_app'.tr,
                          style: AppFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const FaIcon(FontAwesomeIcons.ticket, size: 15),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Get.to(() => TicketScreen(booking: booking));
                            },
                            label: Text(
                              'view_ticket'.tr,
                              style: AppFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colorScheme.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Get.offAll(() => const MainApp());
                            },
                            child: Text(
                              'nav_home'.tr,
                              style: AppFonts.dmSans(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.dmSans(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: AppFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
