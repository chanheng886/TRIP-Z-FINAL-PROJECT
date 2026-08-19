package com.tripz.backend.booking.services;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.tripz.backend.booking.dtos.RequestDTO.BookingRequestDTO;
import com.tripz.backend.booking.dtos.RequestDTO.CreateBusBookingRequestDTO;
import com.tripz.backend.booking.dtos.RequestDTO.PassengerRequestDTO;
import com.tripz.backend.booking.dtos.ResponseDTO.BookingResponseDTO;
import com.tripz.backend.booking.enums.BookingStatus;
import com.tripz.backend.booking.mapper.BookingMapper;
import com.tripz.backend.booking.models.Booking;
import com.tripz.backend.booking.repositories.BookingRepository;
import com.tripz.backend.bus.models.BusBooking;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.bus.repositories.BusBookingRepository;
import com.tripz.backend.bus.repositories.BusScheduleRepository;
import com.tripz.backend.user.repositories.UserRepository;

import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BookingService {
    private final BookingMapper bookingMapper;
    private final BookingRepository bookingRepository;
    private final BusBookingRepository busBookingRepository;
    private final UserRepository userRepository;
    private final BusScheduleRepository busScheduleRepository;

    // ✅ Get All Booking
    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getAllBooking() {
        return bookingRepository.findAll()
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

    // ✅ Get All Booking By Booking Date
    @Transactional(readOnly = true)
    public List<BookingResponseDTO> getAllBookingByBookingDate(LocalDate bookingDate) {
        List<Booking> booking = bookingRepository.findByBookingDate(bookingDate);
        if (booking == null || booking.isEmpty()) {
            throw new RuntimeException("No Booking Found!!");
        }
        return booking.stream().map(bookingMapper::toResponse).collect(Collectors.toList());
    }

    // ✅ Update booking
    @Transactional
    public BookingResponseDTO updateBooking(Long id, BookingRequestDTO dto) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking with id: " + id + " Not Found!"));

        Booking update = bookingMapper.toUpdate(booking, dto);
        Booking saved = bookingRepository.save(update);
        return bookingMapper.toResponse(saved);
    }

    // ✅ Update booking status only
    @Transactional
    public BookingResponseDTO updateBookingStatus(Long id, BookingStatus status) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking with id: " + id + " Not Found!"));

        booking.setBookingStatus(status);
        Booking saved = bookingRepository.save(booking);
        return bookingMapper.toResponse(saved);
    }

    // ✅ Delete Booking
    @Transactional
    public BookingResponseDTO deleteBooking(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking with id: " + id + " Not Found!"));
        bookingRepository.delete(booking);

        return bookingMapper.toResponse(booking);
    }

    // ✅ Create Booking with BusBooking entries
    @Transactional
    public BookingResponseDTO createBooking(CreateBusBookingRequestDTO dto) {
        // 1. Convert DTO → Booking entity
        Booking booking = Booking.builder()
                .user(userRepository.findById(dto.getCustomerId())
                        .orElseThrow(() -> new RuntimeException("Customer not found")))
                .bookingDate(LocalDate.now())
                .paymentMethod(dto.getPaymentMethod())
                .bookingStatus(BookingStatus.Confirmed)
                .totalAmount(BigDecimal.ZERO)
                .build();

        bookingRepository.save(booking);

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
        bookingRepository.save(booking);

        // 5. Convert entity → Response DTO
        return bookingMapper.toResponse(booking);
    }
}
