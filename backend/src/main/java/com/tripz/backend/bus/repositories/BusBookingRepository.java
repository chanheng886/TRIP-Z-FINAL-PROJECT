package com.tripz.backend.bus.repositories;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.BusBooking;

import java.time.LocalDate;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BusBookingRepository extends JpaRepository<BusBooking, Long> {
    List<BusBooking> findByBusSchedule_Id(Long busScheduleId);
    List<BusBooking> findByBusSchedule_IdAndSeatNumberIn(Long busScheduleId, List<String> seatNumbers);
    List<BusBooking> findByBooking_Id(Long bookingId);   // ← new, needed by the mapper

    @Query("""
        SELECT DISTINCT bb FROM BusBooking bb
        JOIN FETCH bb.booking b
        JOIN FETCH b.user u
        JOIN FETCH bb.busSchedule s
        JOIN FETCH s.route r
        JOIN FETCH r.fromLocation fl
        JOIN FETCH r.toLocation tl
        WHERE b.bookingStatus <> com.tripz.backend.booking.enums.BookingStatus.Cancelled
          AND (b.departureNotified IS NULL OR b.departureNotified = false)
          AND s.travelDate = :today
    """)
    List<BusBooking> findImminentCandidates(@Param("today") LocalDate today);
}