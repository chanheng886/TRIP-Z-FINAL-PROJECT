import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/service/ticket_notification_service.dart';
import 'package:get/get.dart';

class ImminentDepartureBanner extends StatelessWidget {
  const ImminentDepartureBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TicketNotificationService>()) {
      return const SizedBox.shrink();
    }

    final service = Get.find<TicketNotificationService>();

    return Obx(() {
      final booking = service.imminentBooking.value;
      final mins = service.minutesRemaining.value;

      if (booking == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.clock,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$mins ${'mins_remaining'.tr.toUpperCase()}',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to history or view ticket
                    try {
                      Get.offAll(() => const MainApp());
                    } catch (_) {}
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'view_ticket'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: Color(0xFFDC2626),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.bus,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.fromLocation} → ${booking.toLocation}',
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${'departs_in'.tr} $mins ${'mins_remaining'.tr} (${booking.departureTime}) • Seats: ${booking.seatNumbers.join(', ')}',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'departure_alert_hurry'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFEF08A), // warm accent yellow
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
