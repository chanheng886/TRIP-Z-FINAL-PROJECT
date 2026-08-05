package com.tripz.backend.bus.services;
import java.util.List;
import org.springframework.stereotype.Service;
import com.tripz.backend.bus.dtos.RequestDTO.CompanyRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.CompanyResponseDTO;
import com.tripz.backend.bus.mappers.CompanyMapper;
import com.tripz.backend.bus.models.Company;
import com.tripz.backend.bus.repositories.CompanyRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CompanyService {
    private final CompanyMapper companyMapper;
    private final CompanyRepository companyRepository;

    //✅✅ Get All Bus Company
    public List<CompanyResponseDTO> getAllCompany(){
        return companyRepository.findAll()
            .stream()
            .map(companyMapper::toResponse)
            .toList();
    }

    //✅✅ Get Bus Company By Id
    public CompanyResponseDTO getCompanyByID(Long id){
        return companyRepository.findById(id)
                .map(companyMapper::toResponse).orElseThrow(() -> new RuntimeException("Company with id: " + id + "Not Found!"));
    }

    //✅✅ Get Bus Company By Company Name
    public CompanyResponseDTO getCompanyByCompanyName(String companyName){
        return companyRepository.findByCompanyName(companyName)
            .map(companyMapper::toResponse)
            .orElseThrow(() -> new RuntimeException("No Company Found!"));
    }

    //✅✅ Create Bus Compnay
    public CompanyResponseDTO createBusCompany(CompanyRequestDTO dto){
        Company company = companyMapper.toEntity(dto);
        Company saved = companyRepository.save(company);

        return companyMapper.toResponse(saved);
    }

    //✅✅ Update Bus Company
    public CompanyResponseDTO updateCompany(Long id, CompanyRequestDTO dto){
        Company company = companyRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Company with id: " + id + "Not Found!"));
        companyMapper.toUpdate(company, dto);
        Company updated = companyRepository.save(company); 
        return companyMapper.toResponse(updated);
    }

    //✅✅ Delete Company By ID
    public CompanyResponseDTO deleteCompanyById(Long id){
        Company company = companyRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Company with id: " + id + "not found!!"));
        
        companyRepository.delete(company);
        return companyMapper.toResponse(company);
    }
}