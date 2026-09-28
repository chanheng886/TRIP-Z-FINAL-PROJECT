package com.tripz.backend.booking.services;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tripz.backend.booking.dtos.RequestDTO.BookingRequestDTO;
import com.tripz.backend.booking.dtos.RequestDTO.CreateBusBookingRequestDTO;
import com.tripz.backend.booking.dtos.RequestDTO.PassengerRequestDTO;
import com.tripz.backend.booking.dtos.ResponseDTO.BookingResponseDTO;
import com.tripz.backend.booking.enums.BookingStatus;
import com.tripz.backend.booking.enums.PaymentStatus;
import com.tripz.backend.booking.mapper.BookingMapper;
import com.tripz.backend.booking.models.Booking;
import com.tripz.backend.booking.repositories.BookingRepository;
import com.tripz.backend.bus.models.BusBooking;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.bus.repositories.BusBookingRepository;
import com.tripz.backend.bus.repositories.BusScheduleRepository;
import com.tripz.backend.config.RedisConfig;
import com.tripz.backend.notification.services.FirebaseMessagingService;
import com.tripz.backend.user.enums.UserRole;
import com.tripz.backend.user.models.User;
import com.tripz.backend.user.repositories.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class BookingService {
    private final BookingMapper bookingMapper;
    private final BookingRepository bookingRepository;
    private final BusBookingRepository busBookingRepository;
    private final UserRepository userRepository;
    private final BusScheduleRepository busScheduleRepository;
    private final FirebaseMessagingService firebaseMessagingService;

    // ✅ Get All Booking (Newest first)
    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getAllBooking() {
        return bookingRepository.findAllByOrderByIdDesc()
                .stream()
                .map(bookingMapper::toResponse)
                .collect(Collectors.toList());
    }

    // ✅ Get All Booking By User ID
    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getBookingsByUserId(Long userId) {
        return bookingRepository.findByUserIdOrderByBookingDateDesc(userId)
                .stream()
                .map(bookingMapper::toResponse)
                .collect(Collectors.toList());
    }

    // ✅ Get Booking By Booking ID
    @Transactional(readOnly = true)
    public BookingResponseDTO getBookingByBookingID(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking with id: " + id + " Not Found!"));
        return bookingMapper.toResponse(booking);
    }

    // ✅ Get All Booking By Booking Date (Newest first)
    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getAllBookingByBookingDate(LocalDate bookingDate) {
        List<Booking> booking = bookingRepository.findByBookingDateOrderByIdDesc(bookingDate);
        if (booking == null || booking.isEmpty()) {
            throw new RuntimeException("No Booking Found!!");
        }
        return booking.stream().map(bookingMapper::toResponse).collect(Collectors.toList());
    }

    // ✅ Update booking
    @Transactional
    @CacheEvict(value = RedisConfig.CACHE_SCHEDULES, allEntries = true)
    public BookingResponseDTO updateBooking(Long id, BookingRequestDTO dto) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking with id: " + id + " Not Found!"));

        Booking update = bookingMapper.toUpdate(booking, dto);
        Booking saved = bookingRepository.save(update);
        return bookingMapper.toResponse(saved);
    }

    // ✅ Update booking status only
    @Transactional
    @CacheEvict(value = RedisConfig.CACHE_SCHEDULES, allEntries = true)
    public BookingResponseDTO updateBookingStatus(Long id, BookingStatus status) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking with id: " + id + " Not Found!"));

        booking.setBookingStatus(status);
        if (status == BookingStatus.Paid || status == BookingStatus.Confirmed) {
            booking.setPaymentStatus(PaymentStatus.PAID);
        } else if (status == BookingStatus.Cancelled) {
            booking.setPaymentStatus(PaymentStatus.FAILED);
        } else if (status == BookingStatus.Pending) {
            booking.setPaymentStatus(PaymentStatus.PENDING);
        }
        Booking saved = bookingRepository.save(booking);
        return bookingMapper.toResponse(saved);
    }

    // ✅ Delete Booking
    @Transactional
    @CacheEvict(value = RedisConfig.CACHE_SCHEDULES, allEntries = true)
    public BookingResponseDTO deleteBooking(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking with id: " + id + " Not Found!"));
        bookingRepository.delete(booking);

        return bookingMapper.toResponse(booking);
    }

    // ✅ Create Booking with BusBooking entries
    @Transactional
    @CacheEvict(value = RedisConfig.CACHE_SCHEDULES, allEntries = true)
    public BookingResponseDTO createBooking(CreateBusBookingRequestDTO dto) {
        // 1. Convert DTO → Booking entity
        String method = dto.getPaymentMethod();
        if (method == null || method.isBlank()) {
            method = "Pay at Station";
        }

        Booking booking = Booking.builder()
                .user(userRepository.findById(dto.getCustomerId())
                        .orElseThrow(() -> new RuntimeException("Customer not found")))
                .bookingDate(LocalDate.now())
                .paymentMethod(method)
                .bookingStatus(BookingStatus.Pending)
                .paymentStatus(PaymentStatus.PENDING)
                .departureNotified(false)
                .totalAmount(BigDecimal.ZERO)
                .build();

        booking = bookingRepository.save(booking);

        // 2. Fetch bus schedule
        BusSchedule schedule = busScheduleRepository.findById(dto.getBusScheduleId())
                .orElseThrow(() -> new RuntimeException("Bus schedule not found"));

        BigDecimal total = BigDecimal.ZERO;

        // 3. Create BusBooking entries from PassengerRequestDTO
        for (PassengerRequestDTO passenger : dto.getPassengers()) {
            BusBooking busBooking = BusBooking.builder()
                    .booking(booking)
                    .busSchedule(schedule)
                    .passengerName(passenger.getName())
                    .seatNumber(passenger.getSeatNumber())
                    .price(schedule.getBasePrice())
                    .build();

            busBookingRepository.save(busBooking);
            total = total.add(schedule.getBasePrice());
        }

        // 4. Update total amount
        booking.setTotalAmount(total);
        booking = bookingRepository.save(booking);

        // 5. Notify all admins of the new booking
        notifyAdminsNewBooking(booking, schedule, dto.getPassengers().size());

        // 6. Convert entity → Response DTO
        return bookingMapper.toResponse(booking);
    }

    private void notifyAdminsNewBooking(Booking booking, BusSchedule schedule, int seatCount) {
        try {
            List<User> admins = userRepository.findByRole(UserRole.Admin);
            if (admins == null || admins.isEmpty()) {
                return;
            }

            String fromCity = schedule.getRoute().getFromLocation().getLocationName();
            String toCity = schedule.getRoute().getToLocation().getLocationName();
            String customerName = booking.getUser() != null ? booking.getUser().getUsername() : "A customer";

            String title = "New Ticket Booking! 🎟️";
            String body = String.format("%s booked %d seat(s) for %s → %s ($%.2f)",
                    customerName, seatCount, fromCity, toCity, booking.getTotalAmount());

            Map<String, String> data = new HashMap<>();
            data.put("type", "ADMIN_NEW_BOOKING");
            data.put("bookingId", String.valueOf(booking.getId()));
            data.put("customer", customerName);
            data.put("route", fromCity + " → " + toCity);
            data.put("seats", String.valueOf(seatCount));
            data.put("amount", String.valueOf(booking.getTotalAmount()));

            for (User admin : admins) {
                if (admin.getFcmToken() != null && !admin.getFcmToken().isBlank()) {
                    firebaseMessagingService.sendPushNotification(admin.getFcmToken(), title, body, data);
                    log.info("🔔 [Admin Notification] Notified admin '{}' of new booking #{}", admin.getUsername(), booking.getId());
                }
            }
        } catch (Exception e) {
            log.warn("⚠️ [Admin Notification] Error dispatching admin push notification: {}", e.getMessage());
        }
    }
}
