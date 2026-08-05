package com.tripz.backend.booking.dtos.RequestDTO;
import java.math.BigDecimal;
import java.time.LocalDate;
import com.tripz.backend.booking.enums.BookingStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingRequestDTO { 
    @NotNull(message = "User id is required")
    private Long userId;

    @NotNull(message = "Booking date is required") 
    private LocalDate bookingDate;
    
    @NotNull(message = "Total amount is required") 
    private BigDecimal totalAmount;

    @NotBlank(message = "Payment method is required") 
    private String paymentMethod;

    @NotNull(message = "Payment method is required") 
    private BookingStatus bookingStatus;
}