package com.tripz.backend.bus.services;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import com.tripz.backend.bus.dtos.RequestDTO.BusBookingRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusBookingResponseDTO;
import com.tripz.backend.bus.mappers.BusBookingMapper;
import com.tripz.backend.bus.models.BusBooking;
import com.tripz.backend.bus.repositories.BusBookingRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BusBookingService {
    private final BusBookingRepository busBookingRepository;
    private final BusBookingMapper busBookingMapper;

    //✅ Get all bus booking
    public List<BusBookingResponseDTO> getAllBusBooking(){
        return busBookingRepository.findAll()
            .stream().map(busBookingMapper::toResponse)
            .collect(Collectors.toList());
    }

    //✅ Get Bus Booking By Id
    public BusBookingResponseDTO getBusBookingById(Long id){
        return busBookingRepository.findById(id)
            .map(busBookingMapper::toResponse)
            .orElseThrow(() -> new RuntimeException("Booking withd id: " + id + " Not Found!"));
    } 

    //✅ Create Booking
    public BusBookingResponseDTO createBusBooking(BusBookingRequestDTO dto){
        BusBooking booking = busBookingMapper.toEntity(dto);
        BusBooking save = busBookingRepository.save(booking);
        return busBookingMapper.toResponse(save);
    }
    
    
    //✅ Update booking
    public BusBookingResponseDTO updateBooking(Long id, BusBookingRequestDTO dto){
        BusBooking busBooking = busBookingRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bus Booking with id: " + id + " Not Found!"));
        BusBooking update = busBookingMapper.toUpdate(busBooking, dto);
        BusBooking save = busBookingRepository.save(update);
        return busBookingMapper.toResponse(save);
    }
}
