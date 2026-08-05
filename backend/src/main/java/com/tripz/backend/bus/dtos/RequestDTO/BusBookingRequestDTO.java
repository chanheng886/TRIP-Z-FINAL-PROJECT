package com.tripz.backend.bus.dtos.RequestDTO;
import java.math.BigDecimal;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BusBookingRequestDTO {
    @NotNull(message = "Booking id is required")
    private Long bookingId;

    @NotNull(message = "Bus Schedule id is required")
    private Long busScheduleId;

    @NotBlank(message = "Passenger name can not be null")
    @Size(max = 50, message = "Passenger name must be less than 50 characters")
    private String passengerName;

    @NotBlank(message = "Seat number can not be null")
    private String seatNumber;

    @NotNull(message = "Price can not be null")
    private BigDecimal price;  
}
