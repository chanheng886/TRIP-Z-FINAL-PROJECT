package com.tripz.backend.bus.controllers;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripz.backend.bus.dtos.RequestDTO.BusRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusResponseDTO;
import com.tripz.backend.bus.services.BusService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;

@RequestMapping("/api/v1/buses")
@RestController
@Tag(name = "Buses")
@RequiredArgsConstructor
public class BusController {
    
    private final BusService busService;

    //✅ Get all Bus
    @GetMapping
    public List<BusResponseDTO> getAllBus(){
        return busService.getAllBus();
    }

    //✅ Get Bus By Id

    @GetMapping("/{id}")
    public BusResponseDTO getBusById(@PathVariable Long id){
        return busService.getBusByID(id);
    }

    //✅ Get Bus By Company Name
    @GetMapping("/name/{companyName}")
    public List<BusResponseDTO> getBusByCompanyName(@PathVariable String companyName){
        return busService.getBusesByCompany(companyName);
    }

    //✅ Create Bus
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public BusResponseDTO createBus(@Valid @RequestBody BusRequestDTO request){
        return busService.createBus(request);
    }

    //✅Update Bus
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public BusResponseDTO updateBus(@PathVariable Long id, @Valid @RequestBody BusRequestDTO request){
        return busService.updateBus(id, request);
    }
}
