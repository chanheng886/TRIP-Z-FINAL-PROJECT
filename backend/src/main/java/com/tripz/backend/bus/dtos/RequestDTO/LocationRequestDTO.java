package com.tripz.backend.bus.dtos.RequestDTO;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LocationRequestDTO {

    @NotBlank(message = "Please fields the location name")
    @Size(max = 100, message = "Location name must be less than 100")
    private String locationName;
    
    @NotBlank(message = "Please fields the location name")
    @Size(max = 100, message = "Location name must be less than 100")
    private String imageUrl;
}
