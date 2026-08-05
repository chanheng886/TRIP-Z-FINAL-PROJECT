package com.tripz.backend.bus.mappers;

import org.springframework.stereotype.Component;

import com.tripz.backend.bus.dtos.RequestDTO.LocationRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.LocationResponseDTO;
import com.tripz.backend.bus.models.Location;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class LocationMapper {
    // private final LocationRepository locationRepository;
    
    //✅ Request || Create to Entity
    public Location toCreateEntity(LocationRequestDTO dto){
        Location location = new Location();
        location.setLocationName(dto.getLocationName());
        location.setImageUrl(dto.getImageUrl());

        return location;
    }

    //✅ Update to Entity
    public void toUpdateEntity(Location location, LocationRequestDTO dto){
        location.setLocationName(dto.getLocationName());
        location.setImageUrl(dto.getImageUrl());
    }

    //✅ Response || Display
    public LocationResponseDTO toResponse(Location location){
    return LocationResponseDTO.builder()
    .id(location.getId())
    .locationName(location.getLocationName())
    .imageUrl(location.getImageUrl()).build();       
    }
}
