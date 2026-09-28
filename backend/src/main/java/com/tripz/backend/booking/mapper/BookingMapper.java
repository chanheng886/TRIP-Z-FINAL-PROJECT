package com.tripz.backend.booking.mapper;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;
import com.tripz.backend.booking.dtos.RequestDTO.BookingRequestDTO;
import com.tripz.backend.booking.dtos.ResponseDTO.BookingResponseDTO;
import com.tripz.backend.booking.models.Booking;
import com.tripz.backend.bus.models.BusBooking;
import com.tripz.backend.bus.repositories.BusBookingRepository;
import com.tripz.backend.user.models.User;
import com.tripz.backend.user.repositories.UserRepository;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BookingMapper {
    private final UserRepository userRepository;
    private final BusBookingRepository busBookingRepository;

    public Booking toEntity(BookingRequestDTO dto){
        User user = userRepository.findById(dto.getUserId())
            .orElseThrow(() -> new RuntimeException("User not found!"));
        return Booking.builder()
        .user(user)
        .bookingDate(dto.getBookingDate())
        .totalAmount(dto.getTotalAmount())
        .paymentMethod(dto.getPaymentMethod())
        .bookingStatus(dto.getBookingStatus())
        .build();
    }

    public Booking toUpdate(Booking booking, BookingRequestDTO dto){
        User user = userRepository.findById(dto.getUserId())
            .orElseThrow(() -> new RuntimeException("User not found!"));
        booking.setUser(user);
        booking.setBookingDate(dto.getBookingDate());
        booking.setTotalAmount(dto.getTotalAmount());
        booking.setPaymentMethod(dto.getPaymentMethod());
        booking.setBookingStatus(dto.getBookingStatus());
        return booking;
    }

    public BookingResponseDTO toResponse(Booking booking){
        if (booking == null) {
            return null;
        }

        List<BusBooking> busBookings = busBookingRepository.findByBooking_Id(booking.getId());

        List<String> seatNumbers = (busBookings != null)
            ? busBookings.stream()
                .map(BusBooking::getSeatNumber)
                .filter(s -> s != null)
                .collect(Collectors.toList())
            : List.of();

        Long userId = (booking.getUser() != null) ? booking.getUser().getId() : null;
        String username = (booking.getUser() != null && booking.getUser().getUsername() != null)
                ? booking.getUser().getUsername()
                : "Guest";

        BookingResponseDTO.BookingResponseDTOBuilder builder = BookingResponseDTO.builder()
            .id(booking.getId())
            .userId(userId)
            .username(username)
            .bookingDate(booking.getBookingDate())
            .totalAmount(booking.getTotalAmount() != null ? booking.getTotalAmount() : java.math.BigDecimal.ZERO)
            .paymentMethod(booking.getPaymentMethod() != null ? booking.getPaymentMethod() : "Pay at Station")
            .bookingStatus(booking.getBookingStatus())
            .seatNumbers(seatNumbers);

        if (busBookings != null && !busBookings.isEmpty()) {
            var busBooking = busBookings.get(0);
            var schedule = (busBooking != null) ? busBooking.getBusSchedule() : null;
            if (schedule != null) {
                var route = schedule.getRoute();
                String from = (route != null && route.getFromLocation() != null)
                        ? route.getFromLocation().getLocationName()
                        : "";
                String to = (route != null && route.getToLocation() != null)
                        ? route.getToLocation().getLocationName()
                        : "";

                builder
                    .fromLocation(from)
                    .toLocation(to)
                    .travelDate(schedule.getTravelDate())
                    .departureTime(schedule.getDepartureTime())
                    .arrivalTime(schedule.getArrivalTime());
            }
        }

        return builder.build();
    }
}