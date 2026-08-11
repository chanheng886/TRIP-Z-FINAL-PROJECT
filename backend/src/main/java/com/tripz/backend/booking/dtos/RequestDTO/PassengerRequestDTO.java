package com.tripz.backend.booking.dtos.RequestDTO;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PassengerRequestDTO {
    @NotBlank(message = "Passenger name is required")
    private String name;

    @NotBlank(message = "Seat number is required")
    private String seatNumber;
}