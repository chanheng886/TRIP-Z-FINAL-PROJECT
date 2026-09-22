import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/shared/service/booking_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketNotificationService extends GetxService {
  final BookingRepository _bookingRepository =
      BookingRepository(BookingService());

  Timer? _checkTimer;
  final Set<int> _alertedBookingIds = <int>{};

  // Observable for UI widgets (e.g. countdown banner on Home / History screens)
  final Rx<BookingResponse?> imminentBooking = Rx<BookingResponse?>(null);
  final RxInt minutesRemaining = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initial check after app finishes rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUpcomingTickets();
    });

    // Run periodic check every 30 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkUpcomingTickets();
    });
  }

  @override
  void onClose() {
    _checkTimer?.cancel();
    super.onClose();
  }

  /// Parses travelDate + departureTime ("HH:mm:ss" or "HH:mm") into a full DateTime
  static DateTime? parseDepartureDateTime(
      DateTime travelDate, String departureTimeStr) {
    try {
      final parts = departureTimeStr.trim().split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(
          travelDate.year,
          travelDate.month,
          travelDate.day,
          hour,
          minute,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [TicketNotificationService] Error parsing departure time: $e');
    }
    return null;
  }

  /// Evaluates active bookings and triggers alerts when 15-30 minutes remain
  Future<void> checkUpcomingTickets() async {
    try {
      if (!Get.isRegistered<AuthViewmodel>()) return;
      final authVM = Get.find<AuthViewmodel>();
      final userId = authVM.currentUser?.id;
      if (userId == null) {
        imminentBooking.value = null;
        minutesRemaining.value = 0;
        return;
      }

      // Check user preferences
      final prefs = await SharedPreferences.getInstance();
      final isPaused = prefs.getBool('pause_notifications') ?? false;

      final bookings = await _bookingRepository.getUserBookings(userId);
      final now = DateTime.now();

      BookingResponse? closestImminent;
      int closestMins = 9999;

      for (final booking in bookings) {
        // Only active, uncancelled bookings
        if (booking.bookingStatus == BookingStatus.Cancelled) continue;

        final departureDt =
            parseDepartureDateTime(booking.travelDate, booking.departureTime);
        if (departureDt == null) continue;

        final diff = departureDt.difference(now);
        final mins = diff.inMinutes;

        // Imminent departure window: between 0 and 30 minutes left (e.g. 15-30 min threshold)
        if (mins >= 0 && mins <= 30) {
          if (mins < closestMins) {
            closestMins = mins;
            closestImminent = booking;
          }

          // Trigger high-priority alert if not paused and not yet notified
          if (!isPaused && !_alertedBookingIds.contains(booking.id)) {
            _alertedBookingIds.add(booking.id);
            _dispatchUrgentAlert(booking, mins);
          }
        }
      }

      // Update reactive properties for UI banner
      imminentBooking.value = closestImminent;
      minutesRemaining.value = closestImminent != null ? closestMins : 0;
    } catch (e) {
      debugPrint('⚠️ [TicketNotificationService] checkUpcomingTickets error: $e');
    }
  }

  /// Displays an urgent in-app alert banner
  void _dispatchUrgentAlert(BookingResponse booking, int minsLeft) {
    Get.snackbar(
      'departure_alert_title'.tr,
      'departure_alert_msg'.trParams({
        'to': booking.toLocation,
        'mins': '$minsLeft',
        'time': booking.departureTime,
      }),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      icon: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const FaIcon(
          FontAwesomeIcons.bus,
          color: Colors.white,
          size: 20,
        ),
      ),
      shouldIconPulse: true,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      duration: const Duration(seconds: 10),
      isDismissible: true,
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // close snackbar
          // Navigate to History tab (index 1) in MainApp
          try {
            Get.offAll(() => const MainApp());
          } catch (_) {}
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'view_ticket'.tr,
          style: AppFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFDC2626),
          ),
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFFDC2626).withValues(alpha: 0.4),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
