package com.tripz.backend.bus.dtos.RequestDTO;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import com.tripz.backend.bus.enums.BusScheduleStatus;
import com.tripz.backend.bus.models.BusType;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BusScheduleRequestDTO {
    @NotNull(message = "Bus id is required")
    private Long busId;
    
    @NotNull(message = "Route id is required")
    private Long routeId;

    @NotNull(message = "Travel date is required")
    private LocalDate travelDate;

    @NotNull(message = "Departure time is required")
    private LocalTime departureTime;

    @NotNull(message = "Arrivals Time is Required")
    private LocalTime arrivalTime;

    @NotNull(message = "Available seats is required")
    private Long availableSeat;

    @NotNull(message = "Status is required")
    private BusScheduleStatus status;

    @NotNull(message = "price can not be null")
    private BigDecimal basePrice;

    @NotNull(message = "Bus type can not be null")
    private Long busTypeId;
}
