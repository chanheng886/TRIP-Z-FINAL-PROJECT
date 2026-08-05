package com.tripz.backend.bus.dtos.RequestDTO;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RouteRequestDTO {
    @NotBlank(message = "From Location Required")
    private String fromLocation;

    @NotBlank(message = "From Location Required")
    private String toLocation;
}