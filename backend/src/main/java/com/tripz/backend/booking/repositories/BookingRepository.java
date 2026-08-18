package com.tripz.backend.booking.repositories;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.booking.models.Booking;

/**
 * BookingRepository
 */
public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByBookingDate(LocalDate bookingDate);
    List<Booking> findByUserIdOrderByBookingDateDesc(Long userId);
}