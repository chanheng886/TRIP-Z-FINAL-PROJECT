package com.tripz.backend.bus.dtos.RequestDTO;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class BusRequestDTO {    
    @Size(max = 100, message = "Compnay name must be less than 100 characters")
    private String companyName;

    @NotNull(message = "Bus Type is reuired")
    private String busType;
    
    private Long seatCapacity;

    @NotBlank(message = "Plate number is required")
    private String plateNumber;

    private String imageUrl;
}