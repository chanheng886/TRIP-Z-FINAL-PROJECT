package com.tripz.backend.bus.controllers;
import java.time.LocalDate;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping; 
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.tripz.backend.bus.dtos.RequestDTO.BusScheduleRequestDTO;
import com.tripz.backend.bus.dtos.RequestDTO.BusScheduleSearchRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusScheduleResponseDTO;
import com.tripz.backend.bus.services.BusScheduleService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/bus-schedules")
@RequiredArgsConstructor
public class BusScheduleController {
    private final BusScheduleService busScheduleService;


    //✅✅ Get All Bus Schedule
    @GetMapping
    public List<BusScheduleResponseDTO> getAllBusSchedules(){
        return busScheduleService.getAllBusSchedule();
    }

    @GetMapping("/{id}")
    public BusScheduleResponseDTO getBusScheduleById(@PathVariable Long id){
        return busScheduleService.getBusScheduleById(id);
    }

    @GetMapping("/search")
    public ResponseEntity<List<BusScheduleResponseDTO>> getAllBusScheduleByFromLocationToLocationAndTravelDate
    (
        @RequestParam Long fromLocationId,
        @RequestParam Long toLocationId,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate travelDate
    
    ){
        BusScheduleSearchRequestDTO dto = BusScheduleSearchRequestDTO.builder()
        .fromLocation(fromLocationId)
        .toLocation(toLocationId)
        .travelDate(travelDate)
        .build();
        return ResponseEntity.ok(busScheduleService.searchBusSchedules(dto));
    }

    
    @PostMapping
    public BusScheduleResponseDTO createBusSchedule(@Valid @RequestBody BusScheduleRequestDTO dto){
        return busScheduleService.createBusSchedule(dto);
    }


    @PutMapping("/{id}")
    public BusScheduleResponseDTO updateBusSchedule(@PathVariable Long id, @Valid @RequestBody BusScheduleRequestDTO dto){
        return busScheduleService.updateBusSchedule(id, dto);
    }


    @DeleteMapping("/{id}")
    public BusScheduleResponseDTO deleteBusSchedule(@PathVariable Long id){
        return busScheduleService.deleteBusSchedule(id);
    }
}
