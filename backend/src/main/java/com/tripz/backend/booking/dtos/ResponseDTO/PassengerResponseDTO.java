package com.tripz.backend.booking.dtos.ResponseDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PassengerResponseDTO {
    private String name;
    private String seatNumber;
}

