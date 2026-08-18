package com.tripz.backend.booking.controllers;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tripz.backend.booking.dtos.RequestDTO.BookingRequestDTO;
import com.tripz.backend.booking.dtos.RequestDTO.CreateBusBookingRequestDTO;
import com.tripz.backend.booking.dtos.ResponseDTO.BookingResponseDTO;
import com.tripz.backend.booking.enums.BookingStatus;
import com.tripz.backend.booking.services.BookingService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/booking")
@RequiredArgsConstructor
@Tag(name = "Bus-Booking")
public class BookingController {
    private final BookingService bookingService;

    @GetMapping
    public List<BookingResponseDTO> getAllBooking(){
        return bookingService.getAllBooking();
    }

    @GetMapping("/user/{userId}")
    public List<BookingResponseDTO> getBookingsByUserId(@PathVariable Long userId){
        return bookingService.getBookingsByUserId(userId);
    }

    @GetMapping("/{id}")
    public BookingResponseDTO getBookingById(@PathVariable Long id){
        return bookingService.getBookingByBookingID(id);
    }

    @GetMapping("/date/{date}")
public ResponseEntity<List<BookingResponseDTO>> getBookingsByDate(@PathVariable LocalDate date) {
    return ResponseEntity.ok(bookingService.getAllBookingByBookingDate(date));
}


    @PostMapping
    public ResponseEntity<BookingResponseDTO> createBooking(@Valid @RequestBody CreateBusBookingRequestDTO dto){
        BookingResponseDTO response = bookingService.createBooking(dto);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public BookingResponseDTO updateBooking(@PathVariable Long id, @RequestBody BookingRequestDTO dto){
        return bookingService.updateBooking(id, dto);
    }

    @PatchMapping("/{id}/status")
    public BookingResponseDTO updateBookingStatus(@PathVariable Long id, @RequestBody Map<String, String> body){
        BookingStatus status = BookingStatus.valueOf(body.get("status"));
        return bookingService.updateBookingStatus(id, status);
    }

    @DeleteMapping("/{id}")
    public BookingResponseDTO deleteBooking(@PathVariable Long id){
        return bookingService.deleteBooking(id);
    }
}
