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
        List<BusBooking> busBookings = busBookingRepository.findByBooking_Id(booking.getId());

        List<String> seatNumbers = busBookings.stream()
            .map(BusBooking::getSeatNumber)
            .collect(Collectors.toList());

        BookingResponseDTO.BookingResponseDTOBuilder builder = BookingResponseDTO.builder()
            .id(booking.getId())
            .userId(booking.getUser().getId())
            .username(booking.getUser().getUsername())
            .bookingDate(booking.getBookingDate())
            .totalAmount(booking.getTotalAmount())
            .paymentMethod(booking.getPaymentMethod())
            .bookingStatus(booking.getBookingStatus())
            .seatNumbers(seatNumbers);

        if (!busBookings.isEmpty()) {
            var schedule = busBookings.get(0).getBusSchedule();
            builder
                .fromLocation(schedule.getRoute().getFromLocation().getLocationName())
                .toLocation(schedule.getRoute().getToLocation().getLocationName())
                .travelDate(schedule.getTravelDate())
                .departureTime(schedule.getDepartureTime())
                .arrivalTime(schedule.getArrivalTime());
        }

        return builder.build();
    }
}