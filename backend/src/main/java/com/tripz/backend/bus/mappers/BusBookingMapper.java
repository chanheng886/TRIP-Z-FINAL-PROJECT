package com.tripz.backend.bus.mappers;

import org.springframework.stereotype.Component;

import com.tripz.backend.booking.models.Booking;
import com.tripz.backend.booking.repositories.BookingRepository;
import com.tripz.backend.bus.dtos.RequestDTO.BusBookingRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusBookingResponseDTO;
import com.tripz.backend.bus.models.BusBooking;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.bus.repositories.BusScheduleRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BusBookingMapper {
    private final BookingRepository bookingRepository;
    private final BusScheduleRepository busScheduleRepository;
    //✅ Convert from DTO to entity

    public BusBooking toEntity(BusBookingRequestDTO dto){
        Booking booking = bookingRepository.findById(dto.getBookingId())
            .orElseThrow(() -> new RuntimeException("Booking not found!"));

        BusSchedule busSchedule = busScheduleRepository.findById(dto.getBusScheduleId())
            .orElseThrow(() -> new RuntimeException("Bus Schedule Not Found!"));
        return BusBooking.builder()
        .booking(booking)
        .busSchedule(busSchedule)
        .passengerName(dto.getPassengerName())
        .seatNumber(dto.getSeatNumber())
        .price(dto.getPrice())
        .build();
    }

    public BusBooking toUpdate(BusBooking busBooking, BusBookingRequestDTO dto){
        Booking bookings = bookingRepository.findById(dto.getBookingId())
            .orElseThrow(() -> new RuntimeException("Booking not found!"));

        BusSchedule busSchedule = busScheduleRepository.findById(dto.getBusScheduleId())
            .orElseThrow(() -> new RuntimeException("Bus Schedule Not Found!"));
        
        busBooking.setBooking(bookings);
        busBooking.setBusSchedule(busSchedule);
        busBooking.setPassengerName(dto.getPassengerName());
        busBooking.setSeatNumber(dto.getSeatNumber());
        busBooking.setPrice(dto.getPrice());
        return busBooking;
    }

    public BusBookingResponseDTO toResponse(BusBooking busBooking){
        return BusBookingResponseDTO.builder()
        .id(busBooking.getId())
        .bookingDate(busBooking.getBooking().getBookingDate())
        .busScheduleId(busBooking.getBusSchedule().getId())
        .fromLocation(busBooking.getBusSchedule().getRoute().getFromLocation().getLocationName())
        .toLocation(busBooking.getBusSchedule().getRoute().getToLocation().getLocationName())
        .travelDate(busBooking.getBusSchedule().getTravelDate())
        .passengerName(busBooking.getPassengerName())
        .seatNumber(busBooking.getSeatNumber())
        .price(busBooking.getPrice())
        .build();
    }
}
