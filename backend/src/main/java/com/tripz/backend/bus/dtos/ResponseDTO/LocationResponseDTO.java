package com.tripz.backend.bus.dtos.ResponseDTO;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LocationResponseDTO {
    private Long id;
    private String locationName;
    private String imageUrl;   
}
