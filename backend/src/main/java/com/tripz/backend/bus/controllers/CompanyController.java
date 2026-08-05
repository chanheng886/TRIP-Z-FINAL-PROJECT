package com.tripz.backend.bus.controllers;
import java.util.List;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.tripz.backend.bus.dtos.RequestDTO.CompanyRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.CompanyResponseDTO;
import com.tripz.backend.bus.services.CompanyService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/bus-company")
@RequiredArgsConstructor
@Tag(name = "bus-company")
public class CompanyController {
    private final CompanyService companyService;
    //✅✅ Get All Bus Company
    @GetMapping
    public List<CompanyResponseDTO> getAllBusCompany(){
        return companyService.getAllCompany();
    }

    //✅✅ Get Bus Company By ID
    @GetMapping("/{id}")
    public CompanyResponseDTO getBusCompanyByid(@PathVariable Long id){
        return companyService.getCompanyByID(id);
    }

    //✅✅ Get Bus Company By Company Name
    @GetMapping("/name/{companyName}")
    public CompanyResponseDTO getBusCompanyByCompanyName(@PathVariable String companyName){
        return companyService.getCompanyByCompanyName(companyName);
    }

    //✅✅ Create Bus Company
    @PostMapping
    public CompanyResponseDTO createBusCompany(@Valid @RequestBody CompanyRequestDTO request){
        return companyService.createBusCompany(request);
    }

    //✅✅ Update Bus Company
    @PutMapping("/{id}")
    public CompanyResponseDTO updateBusCompany(@PathVariable Long id, @RequestBody CompanyRequestDTO request){
        return companyService.updateCompany(id, request);
    }

    //✅✅ Delete Bus Company By Id
    @DeleteMapping("/{id}")
    public CompanyResponseDTO deleteBusCompany(@PathVariable Long id){
        return companyService.deleteCompanyById(id);
    }
}