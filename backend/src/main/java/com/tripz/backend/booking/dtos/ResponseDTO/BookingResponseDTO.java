package com.tripz.backend.booking.dtos.ResponseDTO;
import java.math.BigDecimal;
import java.time.LocalDate;
import com.tripz.backend.booking.enums.BookingStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponseDTO {
    private Long id;
    private Long userId;
    private String username;
    private LocalDate bookingDate;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private BookingStatus bookingStatus;
}