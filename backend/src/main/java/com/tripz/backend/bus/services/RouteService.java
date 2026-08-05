package com.tripz.backend.bus.services;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import com.tripz.backend.bus.dtos.RequestDTO.RouteRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.RouteResponseDTO;
import com.tripz.backend.bus.mappers.RouteMapper;
import com.tripz.backend.bus.models.Location;
import com.tripz.backend.bus.models.Route;
import com.tripz.backend.bus.repositories.LocationRepository;
import com.tripz.backend.bus.repositories.RouteRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RouteService {
    private final RouteMapper routeMapper;
    private final RouteRepository routeRepository;
    private final LocationRepository locationRepository;

    //✅ Get All Routes
    public List<RouteResponseDTO> getAllRoute(){
        return routeRepository.findAll()
            .stream()
            .map(routeMapper::toResponse)
            .collect(Collectors.toList());
    }

    //✅ Get Route By Id
    public RouteResponseDTO getRouteById(Long id){
        return routeRepository.findById(id)
        .map(routeMapper::toResponse)
        .orElseThrow(() -> new RuntimeException("Route with id: " + id + "Not Found!"));
    }

    //✅ Get From Location and To Location
    public RouteResponseDTO getRouteByFromLocationNameAndToLocationName(String fromLocationName, String toLocationName){
        Location fromLocation = locationRepository.findByLocationName(fromLocationName)
            .orElseThrow(() -> new RuntimeException("Location name: " + fromLocationName + "Not Found!"));
        Location toLocation = locationRepository.findByLocationName(toLocationName)
            .orElseThrow(() -> new RuntimeException("Location name: " + toLocationName));

        Route route = routeRepository.findByFromLocationAndToLocation(fromLocation, toLocation);
        return routeMapper.toResponse(route);
    }

    //✅ Create Route
    public RouteResponseDTO createRoute(RouteRequestDTO dto){
        Location fromLocation = locationRepository
            .findByLocationName(dto.getFromLocation())
            .orElseThrow(() -> new RuntimeException("Location Not Found!"));
        Location toLocation = locationRepository
            .findByLocationName(dto.getToLocation())   
            .orElseThrow(() -> new RuntimeException("Location Not Found!"));
        
        Route route = routeMapper.toEntity(dto, fromLocation, toLocation);
        Route save = routeRepository.save(route);
        return routeMapper.toResponse(save);
    }

    //✅ Update Route
    public RouteResponseDTO updateRoute(Long id, RouteRequestDTO dto){
        Route route = routeRepository.findById(id).orElseThrow(() -> new RuntimeException("Route with id: " + id + "Not Found!"));
        Location fromLocation = locationRepository.findByLocationName(dto.getFromLocation())
            .orElseThrow(() -> new RuntimeException("Location Not Found!"));
        Location toLocation = locationRepository.findByLocationName(dto.getToLocation())
            .orElseThrow(() -> new RuntimeException("Location Not Found!"));

        routeMapper.toUpdate(route, fromLocation, toLocation);
        Route updated = routeRepository.save(route);
        return routeMapper.toResponse(updated);
    }

    //✅✅ Delete Route
    public RouteResponseDTO deleteRoute(Long id){
        Route route = routeRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Route with id: " + id + "Not Found!"));
        routeRepository.delete(route);
        
        return routeMapper.toResponse(route);
    }
}
