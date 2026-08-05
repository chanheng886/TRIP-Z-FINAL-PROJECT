package com.tripz.backend.bus.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.tripz.backend.bus.dtos.RequestDTO.LocationRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.LocationResponseDTO;
import com.tripz.backend.bus.mappers.LocationMapper;
import com.tripz.backend.bus.models.Location;
import com.tripz.backend.bus.repositories.LocationRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class LocationService {
    private final LocationRepository locationRepository;
    private final LocationMapper locationMapper;

    //✅ Get All Location
    public List<LocationResponseDTO> getAllLocations(){
        return locationRepository.findAll()
            .stream()
            .map(locationMapper::toResponse)
            .collect(Collectors.toList());
    }

    //✅ Get Location By Id
    public LocationResponseDTO getLocationById(Long id){
        Location location = locationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Location with id:" + id + "Not Found"));
        return locationMapper.toResponse(location);
    }

    //✅ Get Location By Location Name
    public LocationResponseDTO getLocationByLocationName(String locationName ){
        Location location = locationRepository.findByLocationName(locationName)
            .orElseThrow(() -> new RuntimeException("Location with name: " + locationName + "can't found"));
        return locationMapper.toResponse(location);
    }

    //✅ Create Location
    public LocationResponseDTO createLocation(LocationRequestDTO dto){
        Location location = locationMapper.toCreateEntity(dto);
        Location saved = locationRepository.save(location);

        return locationMapper.toResponse(saved);
    }

    //✅ Update Location
    public LocationResponseDTO updateLocation(Long id, LocationRequestDTO dto){
        Location location = locationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Location with id: " +id+"Not Found"));

        locationMapper.toUpdateEntity(location, dto);
        Location update = locationRepository.save(location);
        return locationMapper.toResponse(update);
    }

    //✅ Delete Location
    public LocationResponseDTO deleteLocationById(Long id){
        Location location = locationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Location with id:" + id + "Not Found"));
        locationRepository.delete(location);
        return locationMapper.toResponse(location);
    }
}
