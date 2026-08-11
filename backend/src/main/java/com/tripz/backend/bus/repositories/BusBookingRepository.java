package com.tripz.backend.bus.repositories;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.BusBooking;

public interface BusBookingRepository extends JpaRepository<BusBooking, Long> {
    List<BusBooking> findByBusSchedule_Id(Long busScheduleId);
    List<BusBooking> findByBusSchedule_IdAndSeatNumberIn(Long busScheduleId, List<String> seatNumbers);
    List<BusBooking> findByBooking_Id(Long bookingId);   // ← new, needed by the mapper
}