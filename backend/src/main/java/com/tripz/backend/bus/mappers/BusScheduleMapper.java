package com.tripz.backend.bus.mappers;

import org.springframework.stereotype.Component;

import com.tripz.backend.bus.dtos.RequestDTO.BusScheduleRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusScheduleResponseDTO;
import com.tripz.backend.bus.models.Bus;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.bus.models.Route;
import com.tripz.backend.bus.repositories.BusRepository;
import com.tripz.backend.bus.repositories.RouteRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BusScheduleMapper {
    private final BusRepository busRepository;
    private final RouteRepository routeRepository;
    
    //✅ Convert from DTO to entity/model
    public BusSchedule toEntity(BusScheduleRequestDTO dto){
        Bus bus = busRepository.findById(dto.getBusId())
            .orElseThrow(() -> new RuntimeException("Bus id not found!"));
        Route route = routeRepository.findById(dto.getRouteId())
            .orElseThrow(() -> new RuntimeException("Route id not found!"));
        return BusSchedule.builder()
        .bus(bus)
        .route(route)
        .travelDate(dto.getTravelDate())
        .departureTime(dto.getDepartureTime())
        .arrivalTime(dto.getArrivalTime())
        .availableSeat(dto.getAvailableSeat())
        .busScheduleStatus(dto.getStatus())
        .build();
    }

    //✅ To update
    public BusSchedule toUpdate(BusSchedule busSchedule, BusScheduleRequestDTO dto){
        Bus bus = busRepository.findById(dto.getBusId())
            .orElseThrow(() -> new RuntimeException("Bus id not found!"));
        Route route = routeRepository.findById(dto.getRouteId())
            .orElseThrow(() -> new RuntimeException("Route id not found!"));
        busSchedule.setBus(bus);
        busSchedule.setRoute(route);
        busSchedule.setTravelDate(dto.getTravelDate());
        busSchedule.setDepartureTime(dto.getDepartureTime());
        busSchedule.setArrivalTime(dto.getArrivalTime());
        busSchedule.setBusScheduleStatus(dto.getStatus());

        return busSchedule;
    }

    //✅ To Response
    public BusScheduleResponseDTO toResponse(BusSchedule busSchedule){
        return BusScheduleResponseDTO.builder()
        .id(busSchedule.getId())
        .busId(busSchedule.getBus().getId())
        .plateNumber(busSchedule.getBus().getPlateNumber())
        .companyName(busSchedule.getBus().getCompany().getCompanyName())
        .routeId(busSchedule.getRoute().getId())
        .fromLocation(busSchedule.getRoute().getFromLocation().getLocationName())
        .toLocation(busSchedule.getRoute().getToLocation().getLocationName())
        .travelDate(busSchedule.getTravelDate())
        .departureTime(busSchedule.getDepartureTime())
        .arrivalTime(busSchedule.getArrivalTime())
        .availableSeat(busSchedule.getAvailableSeat())
        .basePrice(busSchedule.getBasePrice())
        .status(busSchedule.getBusScheduleStatus())
        .build();
    }
}
