import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/features/home/view/pages/ticket_screen.dart';
import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

class BookingConfirmationMobile extends StatelessWidget {
  final BookingResponse booking;

  const BookingConfirmationMobile({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.check,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'booking_success'.tr,
                style: AppFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${'booking_code'.tr}: #${booking.id}',
                style: AppFonts.dmSans(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.fromLocation.trDb,
                                style: AppFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                booking.departureTime,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.busSimple,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                booking.toLocation.trDb,
                                style: AppFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                booking.arrivalTime,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _row('passenger'.tr, booking.username),
                    _row(
                      'date'.tr,
                      '${booking.travelDate.year}-${booking.travelDate.month.toString().padLeft(2, '0')}-${booking.travelDate.day.toString().padLeft(2, '0')}',
                    ),
                    _row('seats'.tr, booking.seatNumbers.join(', ')),
                    _row('Payment', booking.paymentMethod.trDb),
                    _row('status'.tr, booking.bookingStatus.name.trDb),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'total_price'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '\$${booking.totalAmount.toStringAsFixed(2)}',
                          style: AppFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.ticket, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                  ),
                  onPressed: () {
                    Get.to(() => TicketScreen(booking: booking));
                  },
                  label: Text(
                    'view_ticket'.tr,
                    style: AppFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.dmSans(fontSize: 13, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: AppFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
