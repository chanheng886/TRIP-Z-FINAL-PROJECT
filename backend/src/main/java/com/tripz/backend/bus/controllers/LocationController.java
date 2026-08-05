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

import com.tripz.backend.bus.dtos.RequestDTO.LocationRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.LocationResponseDTO;
import com.tripz.backend.bus.services.LocationService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/bus-locations")
@Tag(name = "Bus-Location")
@RequiredArgsConstructor
public class LocationController {
    private final LocationService locationService;

    //✅ Get All Locations
    @GetMapping
    public List<LocationResponseDTO> getAllLocations(){
        return locationService.getAllLocations();
    }

    //✅ Get Location By Id
    @GetMapping("{id}")
    public LocationResponseDTO getLocationById(@PathVariable Long id){
        return locationService.getLocationById(id);
    }

    //✅ Get Location By Location name
    @GetMapping("/name/{locationName}")
    public LocationResponseDTO getLcoationByLocationName(@PathVariable String locationName){
        return locationService.getLocationByLocationName(locationName);
    }

    //✅ Create Location
    @PostMapping("/create")
    public LocationResponseDTO createLocation(@Valid @RequestBody LocationRequestDTO dto){
        return locationService.createLocation(dto);
    }

    //✅ Update Location
    @PutMapping("/{id}")
    public LocationResponseDTO updateLocation(@PathVariable Long id, @Valid @RequestBody LocationRequestDTO dto){
        return locationService.updateLocation(id, dto);
    }

    //✅ Delete Location By Id
    @DeleteMapping("delete/{id}")
    public LocationResponseDTO deleteLocationById(@PathVariable Long id){
        return locationService.deleteLocationById(id);
    }

}
