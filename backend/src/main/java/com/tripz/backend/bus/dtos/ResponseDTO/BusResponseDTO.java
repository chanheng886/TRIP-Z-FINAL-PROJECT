package com.tripz.backend.bus.dtos.ResponseDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BusResponseDTO {
    private Long id;
    private Long companyId;
    private String companyName;
    private String busType;
    private String plateNumber;
    private String seatCapacity;
    private String imageUrl;
}
