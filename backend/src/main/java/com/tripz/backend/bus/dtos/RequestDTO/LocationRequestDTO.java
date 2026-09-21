package com.tripz.backend.bus.dtos.RequestDTO;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LocationRequestDTO {

    @NotBlank(message = "Please fill in the location name")
    @Size(max = 100, message = "Location name must be less than 100 characters")
    private String locationName;
    
    @NotBlank(message = "Please provide the image URL")
    @Size(max = 1000, message = "Image URL must be less than 1000 characters")
    private String imageUrl;
}
