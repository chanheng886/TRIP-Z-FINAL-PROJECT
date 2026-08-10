package com.tripz.backend.bus.mappers;

import org.springframework.stereotype.Component;

import com.tripz.backend.bus.dtos.RequestDTO.BusScheduleRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusScheduleResponseDTO;
import com.tripz.backend.bus.models.Bus;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.bus.models.BusType;
import com.tripz.backend.bus.models.Route;
import com.tripz.backend.bus.repositories.BusRepository;
import com.tripz.backend.bus.repositories.BusTypeRepository;
import com.tripz.backend.bus.repositories.RouteRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BusScheduleMapper {
    private final BusRepository busRepository;
    private final RouteRepository routeRepository;
    private final BusTypeRepository busTypeRepository;
    
    //✅ Convert from DTO to entity/model
    public BusSchedule toEntity(BusScheduleRequestDTO dto){
        Bus bus = busRepository.findById(dto.getBusId())
            .orElseThrow(() -> new RuntimeException("Bus id not found!"));
        Route route = routeRepository.findById(dto.getRouteId())
            .orElseThrow(() -> new RuntimeException("Route id not found!"));
        
        BusType busType = busTypeRepository.findById(dto.getBusTypeId())
            .orElseThrow(() -> new RuntimeException("Bus Type Not Found!"));
        return BusSchedule.builder()
        .bus(bus)
        .route(route)
        .travelDate(dto.getTravelDate())
        .departureTime(dto.getDepartureTime())
        .arrivalTime(dto.getArrivalTime())
        .availableSeat(dto.getAvailableSeat())
        .basePrice(dto.getBasePrice())
        .busType(busType)
        .busScheduleStatus(dto.getStatus())
        .build();
    }

    //✅ To update
    public BusSchedule toUpdate(BusSchedule busSchedule, BusScheduleRequestDTO dto){
        Bus bus = busRepository.findById(dto.getBusId())
            .orElseThrow(() -> new RuntimeException("Bus id not found!"));
        Route route = routeRepository.findById(dto.getRouteId())
            .orElseThrow(() -> new RuntimeException("Route id not found!"));
        BusType busType = busTypeRepository.findById(dto.getBusTypeId())
            .orElseThrow(() -> new RuntimeException("Bus Type Not Found!"));
        busSchedule.setBus(bus);
        busSchedule.setRoute(route);
        busSchedule.setTravelDate(dto.getTravelDate());
        busSchedule.setDepartureTime(dto.getDepartureTime());
        busSchedule.setArrivalTime(dto.getArrivalTime());
        busSchedule.setBasePrice(dto.getBasePrice());
        busSchedule.setBusType(busType);
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
        .busType(busSchedule.getBusType().getBusType())
        .availableSeat(busSchedule.getAvailableSeat())
        .basePrice(busSchedule.getBasePrice())
        .busTypeId(busSchedule.getBusType().getId())
        .busType(busSchedule.getBusType().getBusType())
        .status(busSchedule.getBusScheduleStatus())
        .build();
    }
}
