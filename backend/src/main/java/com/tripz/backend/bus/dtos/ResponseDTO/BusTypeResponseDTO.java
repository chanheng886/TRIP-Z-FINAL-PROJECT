package com.tripz.backend.bus.dtos.ResponseDTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BusTypeResponseDTO {
    private Long id;
    private String busType;
}
