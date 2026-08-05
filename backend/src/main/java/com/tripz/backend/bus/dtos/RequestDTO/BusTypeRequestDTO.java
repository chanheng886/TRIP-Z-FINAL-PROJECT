package com.tripz.backend.bus.dtos.RequestDTO;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BusTypeRequestDTO {
    @NotBlank(message = "Bus type required")
    @Size(max = 50, message = "Bus type must be less than 50 characters")
    private String busType;
}
