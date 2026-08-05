package com.tripz.backend.bus.dtos.RequestDTO;

import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BusScheduleSearchRequestDTO {
    private Long fromLocation;
    private Long toLocation;
    private LocalDate travelDate;
}
