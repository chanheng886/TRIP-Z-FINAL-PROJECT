package com.tripz.backend.bus.controllers;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripz.backend.bus.dtos.RequestDTO.BusTypeRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusTypeResponseDTO;
import com.tripz.backend.bus.services.BusTypeService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/bus-type")
@RequiredArgsConstructor
@Tag(name = "Bus-Type")
public class BusTypeController {
    private final BusTypeService busTypeService;

    //✅✅ Get All Bus Type
    @GetMapping
    public List<BusTypeResponseDTO> getAllBusType(){
        return busTypeService.getAllBusType();
    }

    //✅✅ Get Bus Type By Id
    @GetMapping("/{id}")
    public BusTypeResponseDTO getBusTypeById(@PathVariable Long id){
        return busTypeService.getBusTypeById(id);
    }

    //✅✅ Get Bus Type By Bus Type name
    @GetMapping("/name/{busType}")
    public BusTypeResponseDTO getBusTypeByBusTypeName(@Valid @PathVariable String busType){
        return busTypeService.getBusTypeBuyBusType(busType);
    }

    //✅✅ Create Bus Type
    @PostMapping
    public BusTypeResponseDTO createBusType(@Valid @RequestBody BusTypeRequestDTO dto){
        return busTypeService.createBusType(dto);
    }

    //✅✅ Update Bus Type
    @PutMapping("/{id}")
    public BusTypeResponseDTO updateBusType(@PathVariable Long id, @Valid @RequestBody BusTypeRequestDTO dto){
        return busTypeService.updateBusType(id, dto);
    }
    
}