package com.tripz.backend.notification.scheduler;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.tripz.backend.booking.models.Booking;
import com.tripz.backend.booking.repositories.BookingRepository;
import com.tripz.backend.bus.models.BusBooking;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.notification.services.FirebaseMessagingService;
import com.tripz.backend.user.models.User;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
@RequiredArgsConstructor
public class DepartureAlertScheduler {

    private final com.tripz.backend.bus.repositories.BusBookingRepository busBookingRepository;
    private final BookingRepository bookingRepository;
    private final FirebaseMessagingService firebaseMessagingService;

    /**
     * Runs every minute to evaluate bookings where departure is between 15 and 30 minutes away.
     */
    @Scheduled(cron = "0 * * * * *")
    @Transactional
    public void checkAndAlertImminentDepartures() {
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        List<BusBooking> candidates = busBookingRepository.findImminentCandidates(today);
        if (candidates.isEmpty()) {
            return;
        }

        // Group by booking ID to ensure only 1 notification is dispatched per booking
        Map<Long, List<BusBooking>> groupedByBooking = candidates.stream()
            .collect(Collectors.groupingBy(bb -> bb.getBooking().getId()));

        for (Map.Entry<Long, List<BusBooking>> entry : groupedByBooking.entrySet()) {
            List<BusBooking> seatBookings = entry.getValue();
            BusBooking first = seatBookings.get(0);
            Booking booking = first.getBooking();
            BusSchedule schedule = first.getBusSchedule();

            LocalTime departureTime = schedule.getDepartureTime();
            LocalDateTime departureDateTime = LocalDateTime.of(today, departureTime);

            long minutesRemaining = Duration.between(now, departureDateTime).toMinutes();

            // Check if remaining time falls within the 15-30 minute window
            if (minutesRemaining >= 15 && minutesRemaining <= 30) {
                User user = booking.getUser();
                String toCity = schedule.getRoute().getToLocation().getLocationName();
                String timeFormatted = departureTime.toString().length() >= 5 
                    ? departureTime.toString().substring(0, 5) 
                    : departureTime.toString();

                String title = "Trip-Z Departure Alert 🚌";
                String body = String.format("Your bus to %s departs in %d minutes (at %s). Please head to your station!",
                        toCity, minutesRemaining, timeFormatted);

                Map<String, String> data = new HashMap<>();
                data.put("type", "DEPARTURE_ALERT");
                data.put("bookingId", String.valueOf(booking.getId()));
                data.put("minutesRemaining", String.valueOf(minutesRemaining));
                data.put("destination", toCity);
                data.put("departureTime", timeFormatted);

                log.info("🔔 [Departure Alert] Booking #{}: {} mins left for user {} (phone: {}) to {}",
                        booking.getId(), minutesRemaining, user.getUsername(), user.getPhone(), toCity);

                // Dispatch FCM push notification
                if (user.getFcmToken() != null && !user.getFcmToken().isBlank()) {
                    firebaseMessagingService.sendPushNotification(user.getFcmToken(), title, body, data);
                } else {
                    log.debug("ℹ️ [Departure Alert] User {} does not have an FCM token registered.", user.getUsername());
                }

                // Mark booking as alerted so duplicate notifications are never sent
                booking.setDepartureNotified(true);
                bookingRepository.save(booking);
            }
        }
    }
}
