package com.tripz.backend.bus.controllers;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripz.backend.bus.dtos.RequestDTO.BusBookingRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusBookingResponseDTO;
import com.tripz.backend.bus.services.BusBookingService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/bus-booking")
@RequiredArgsConstructor
@Tag(name = "Bus Booking")
public class BusBookingController {
    private final BusBookingService busBookingService;

    @GetMapping
    public List<BusBookingResponseDTO> getAllBusBooking(){
        return busBookingService.getAllBusBooking();
    }

    @GetMapping("/{id}")
    public BusBookingResponseDTO getBusBookingById(@PathVariable Long id){
        return busBookingService.getBusBookingById(id);
    }

    @PostMapping
    public BusBookingResponseDTO createBusBooking(@Valid @RequestBody BusBookingRequestDTO dto){
        return busBookingService.createBusBooking(dto);
    }

    @PutMapping("/{id}")
    public BusBookingResponseDTO updateBusBooking(@PathVariable Long id, @RequestBody BusBookingRequestDTO dto){
        return busBookingService.updateBooking(id, dto);
    }
}
