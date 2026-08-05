package com.tripz.backend.bus.mappers;

import org.springframework.stereotype.Component;

import com.tripz.backend.bus.dtos.RequestDTO.CompanyRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.CompanyResponseDTO;
import com.tripz.backend.bus.models.Company;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class CompanyMapper {

    //✅✅ generate from DTO to entity
    public Company toEntity(CompanyRequestDTO dto){
        Company company = new Company();
        company.setCompanyName(dto.getCompanyName());
        company.setImageUrl(dto.getImageUrl());

        return company;
    }

    //✅✅ Generate from DTO to entity to but update
    public Company toUpdate(Company company ,CompanyRequestDTO dto){
        company.setCompanyName(dto.getCompanyName());
        company.setImageUrl(dto.getCompanyName());
        
        return company;
    }

    //✅✅ Display all the data from entity to DTO
    public CompanyResponseDTO toResponse(Company company){
        return CompanyResponseDTO.builder()
        .id(company.getId())
        .companyName(company.getCompanyName())
        .imageUrl(company.getImageUrl()).build();
    }
}
