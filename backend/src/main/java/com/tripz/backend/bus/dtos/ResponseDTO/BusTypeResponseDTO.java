package com.tripz.backend.bus.dtos.ResponseDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BusTypeResponseDTO {
    private Long id;
    private String busType;
}
