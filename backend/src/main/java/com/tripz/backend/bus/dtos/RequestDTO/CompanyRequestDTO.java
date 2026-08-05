package com.tripz.backend.bus.dtos.RequestDTO;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CompanyRequestDTO {

    @NotBlank(message = "company name required")
    @Size(max = 50, message = "company name must be less than 50")
    private String companyName;

    @Size(max = 255, message = "images is too large")
    private String imageUrl;
}
