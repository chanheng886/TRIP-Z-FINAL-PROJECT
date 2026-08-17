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

import com.tripz.backend.bus.dtos.RequestDTO.RouteRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.RouteResponseDTO;
import com.tripz.backend.bus.services.RouteService;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/api/v1/bus-route")
@Tag(name = "Bus-Route")
@RequiredArgsConstructor
public class RouteController {
    private final RouteService routeService;

    @GetMapping
    public List<RouteResponseDTO> getAllRoute(){
        return routeService.getAllRoute();
    }

    @GetMapping("/{id}")
    public RouteResponseDTO getRouteById(@PathVariable Long id){
        return routeService.getRouteById(id);
    }

    @GetMapping("/name/{fromLocation}/{toLocation}")
    public RouteResponseDTO getRouteByFromLocationAndToLcoation(@PathVariable String fromLocation, @PathVariable String toLocation){
        return routeService.getRouteByFromLocationNameAndToLocationName(fromLocation, toLocation);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public RouteResponseDTO createBusRoute(@RequestBody RouteRequestDTO request){
        return routeService.createRoute(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public RouteResponseDTO updateRoute(@PathVariable Long id, @RequestBody RouteRequestDTO request){
        return routeService.updateRoute(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public RouteResponseDTO deleteRouteById(@PathVariable Long id){
        return routeService.deleteRoute(id);
    }


}
