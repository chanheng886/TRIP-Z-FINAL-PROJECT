package com.tripz.backend.bus.dtos.ResponseDTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CompanyResponseDTO {
    private Long id;
    private String companyName;
    private String imageUrl;
}
