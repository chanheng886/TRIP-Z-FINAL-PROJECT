package com.tripz.backend.bus.services;

import java.util.List;
import java.util.stream.Collectors;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import com.tripz.backend.bus.dtos.RequestDTO.RouteRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.RouteResponseDTO;
import com.tripz.backend.bus.mappers.RouteMapper;
import com.tripz.backend.bus.models.Location;
import com.tripz.backend.bus.models.Route;
import com.tripz.backend.bus.repositories.LocationRepository;
import com.tripz.backend.bus.repositories.RouteRepository;
import com.tripz.backend.config.RedisConfig;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RouteService {
    private final RouteMapper routeMapper;
    private final RouteRepository routeRepository;
    private final LocationRepository locationRepository;

    //✅ Get All Routes
    @Cacheable(value = RedisConfig.CACHE_ROUTES, key = "'all'")
    public List<RouteResponseDTO> getAllRoute(){
        return routeRepository.findAll()
            .stream()
            .map(routeMapper::toResponse)
            .collect(Collectors.toList());
    }

    //✅ Get Route By Id
    @Cacheable(value = RedisConfig.CACHE_ROUTES, key = "#id")
    public RouteResponseDTO getRouteById(Long id){
        return routeRepository.findById(id)
        .map(routeMapper::toResponse)
        .orElseThrow(() -> new RuntimeException("Route with id: " + id + "Not Found!"));
    }

    //✅ Get From Location and To Location
    public RouteResponseDTO getRouteByFromLocationNameAndToLocationName(String fromLocationName, String toLocationName){
        Location fromLocation = locationRepository.findByLocationName(fromLocationName)
            .orElseThrow(() -> new RuntimeException("Location name: " + fromLocationName + " Not Found!"));
        Location toLocation = locationRepository.findByLocationName(toLocationName)
            .orElseThrow(() -> new RuntimeException("Location name: " + toLocationName + " Not Found!"));

        Route route = routeRepository.findByFromLocationAndToLocation(fromLocation, toLocation)
            .orElseThrow(() -> new RuntimeException("Route from " + fromLocationName + " to " + toLocationName + " Not Found!"));
        return routeMapper.toResponse(route);
    }

    //✅ Create Route
    @CacheEvict(value = RedisConfig.CACHE_ROUTES, allEntries = true)
    public RouteResponseDTO createRoute(RouteRequestDTO dto){
        Location fromLocation = locationRepository
            .findByLocationName(dto.getFromLocation())
            .orElseThrow(() -> new RuntimeException("Location Not Found: " + dto.getFromLocation()));
        Location toLocation = locationRepository
            .findByLocationName(dto.getToLocation())   
            .orElseThrow(() -> new RuntimeException("Location Not Found: " + dto.getToLocation()));

        if (fromLocation.getId().equals(toLocation.getId())) {
            throw new IllegalArgumentException("From and To locations cannot be the same!");
        }

        if (routeRepository.existsByFromLocationAndToLocation(fromLocation, toLocation)) {
            throw new IllegalArgumentException("Route from " + fromLocation.getLocationName() + " to " + toLocation.getLocationName() + " already exists!");
        }
        
        Route route = routeMapper.toEntity(dto, fromLocation, toLocation);
        Route save = routeRepository.save(route);
        return routeMapper.toResponse(save);
    }

    //✅ Update Route
    @CacheEvict(value = RedisConfig.CACHE_ROUTES, allEntries = true)
    public RouteResponseDTO updateRoute(Long id, RouteRequestDTO dto){
        Route route = routeRepository.findById(id).orElseThrow(() -> new RuntimeException("Route with id: " + id + " Not Found!"));
        Location fromLocation = locationRepository.findByLocationName(dto.getFromLocation())
            .orElseThrow(() -> new RuntimeException("Location Not Found: " + dto.getFromLocation()));
        Location toLocation = locationRepository.findByLocationName(dto.getToLocation())
            .orElseThrow(() -> new RuntimeException("Location Not Found: " + dto.getToLocation()));

        if (fromLocation.getId().equals(toLocation.getId())) {
            throw new IllegalArgumentException("From and To locations cannot be the same!");
        }

        routeRepository.findByFromLocationAndToLocation(fromLocation, toLocation).ifPresent(existing -> {
            if (!existing.getId().equals(id)) {
                throw new IllegalArgumentException("Route from " + fromLocation.getLocationName() + " to " + toLocation.getLocationName() + " already exists!");
            }
        });

        routeMapper.toUpdate(route, fromLocation, toLocation);
        Route updated = routeRepository.save(route);
        return routeMapper.toResponse(updated);
    }

    //✅✅ Delete Route
    @CacheEvict(value = RedisConfig.CACHE_ROUTES, allEntries = true)
    public RouteResponseDTO deleteRoute(Long id){
        Route route = routeRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Route with id: " + id + "Not Found!"));
        routeRepository.delete(route);
        
        return routeMapper.toResponse(route);
    }
}
