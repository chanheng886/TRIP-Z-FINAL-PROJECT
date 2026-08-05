package com.tripz.backend.bus.dtos.ResponseDTO;

import java.math.BigDecimal;
import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BusBookingResponseDTO {
    private Long id;
    private Long bookingId;
    private LocalDate bookingDate;
    private Long busScheduleId;
    private String fromLocation;
    private String toLocation;
    private LocalDate travelDate;
    private String passengerName;
    private String seatNumber;
    private BigDecimal price;    
}
