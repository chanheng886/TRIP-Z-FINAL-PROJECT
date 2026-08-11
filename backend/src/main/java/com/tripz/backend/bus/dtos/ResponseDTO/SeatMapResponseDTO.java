package com.tripz.backend.bus.dtos.ResponseDTO;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SeatMapResponseDTO {
    private Long busScheduleId;
    private List<String> allSeats;
    private List<String> bookedSeats;
}