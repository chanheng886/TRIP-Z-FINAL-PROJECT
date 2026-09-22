package com.tripz.backend.bus.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import com.tripz.backend.bus.dtos.RequestDTO.LocationRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.LocationResponseDTO;
import com.tripz.backend.bus.mappers.LocationMapper;
import com.tripz.backend.bus.models.Location;
import com.tripz.backend.bus.repositories.LocationRepository;
import com.tripz.backend.config.RedisConfig;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class LocationService {
    private final LocationRepository locationRepository;
    private final LocationMapper locationMapper;

    //✅ Get All Location
    @Cacheable(value = RedisConfig.CACHE_LOCATIONS, key = "'all'")
    public List<LocationResponseDTO> getAllLocations(){
        return locationRepository.findAll()
            .stream()
            .map(locationMapper::toResponse)
            .collect(Collectors.toList());
    }

    //✅ Get Location By Id
    @Cacheable(value = RedisConfig.CACHE_LOCATIONS, key = "#id")
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
    @CacheEvict(value = RedisConfig.CACHE_LOCATIONS, allEntries = true)
    public LocationResponseDTO createLocation(LocationRequestDTO dto){
        Location location = locationMapper.toCreateEntity(dto);
        Location saved = locationRepository.save(location);

        return locationMapper.toResponse(saved);
    }

    //✅ Update Location
    @CacheEvict(value = RedisConfig.CACHE_LOCATIONS, allEntries = true)
    public LocationResponseDTO updateLocation(Long id, LocationRequestDTO dto){
        Location location = locationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Location with id: " +id+"Not Found"));

        locationMapper.toUpdateEntity(location, dto);
        Location update = locationRepository.save(location);
        return locationMapper.toResponse(update);
    }

    //✅ Delete Location
    @CacheEvict(value = RedisConfig.CACHE_LOCATIONS, allEntries = true)
    public LocationResponseDTO deleteLocationById(Long id){
        Location location = locationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Location with id:" + id + "Not Found"));
        locationRepository.delete(location);
        return locationMapper.toResponse(location);
    }
}
