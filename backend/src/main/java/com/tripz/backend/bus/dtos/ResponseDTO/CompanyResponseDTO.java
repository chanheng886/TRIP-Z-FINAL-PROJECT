package com.tripz.backend.bus.dtos.ResponseDTO;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CompanyResponseDTO {
    private Long id;
    private String companyName;
    private String imageUrl;
}
