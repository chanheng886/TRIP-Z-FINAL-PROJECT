package com.tripz.backend.booking.mapper;
import org.springframework.stereotype.Component;
import com.tripz.backend.booking.dtos.RequestDTO.BookingRequestDTO;
import com.tripz.backend.booking.dtos.ResponseDTO.BookingResponseDTO;
import com.tripz.backend.booking.models.Booking;
import com.tripz.backend.user.models.User;
import com.tripz.backend.user.repositories.UserRepository;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BookingMapper {
    private final UserRepository userRepository;

    //✅ Convert from DTO to entity
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

    //✅ to Update
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
        return BookingResponseDTO.builder()
        .id(booking.getId())
        .userId(booking.getUser().getId())
        .username(booking.getUser().getUsername())
        .bookingDate(booking.getBookingDate())
        .totalAmount(booking.getTotalAmount())
        .paymentMethod(booking.getPaymentMethod())
        .bookingStatus(booking.getBookingStatus())
        .build();
    }
}