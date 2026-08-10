package com.tripz.backend.bus.dtos.ResponseDTO;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import com.tripz.backend.bus.enums.BusScheduleStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BusScheduleResponseDTO {
    private Long id;
    private Long busId;
    private String plateNumber;
    private String companyName;
    private Long busTypeId;
    private String busType;
    private Long routeId;
    private String fromLocation;
    private String toLocation;
    private LocalDate travelDate;
    private LocalTime departureTime;
    private LocalTime arrivalTime;
    private BigDecimal basePrice;
    private Long availableSeat;
    private BusScheduleStatus status;
}
