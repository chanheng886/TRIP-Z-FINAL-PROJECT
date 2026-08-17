package com.tripz.backend.bus.repositories;
import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import com.tripz.backend.bus.models.BusSchedule;

public interface BusScheduleRepository extends JpaRepository<BusSchedule, Long> {
    @Override
    @EntityGraph(attributePaths = {"bus", "bus.company", "bus.busType", "route", "route.fromLocation", "route.toLocation", "busType"})
    List<BusSchedule> findAll();

    @EntityGraph(attributePaths = {"bus", "bus.company", "bus.busType", "route", "route.fromLocation", "route.toLocation", "busType"})
    List<BusSchedule> findByRoute_FromLocation_IdAndRoute_ToLocation_IdAndTravelDateAndAvailableSeatGreaterThan(
        Long fromLocationId, 
        Long toLocationId, 
        LocalDate travelDate,
        Long availableSeat
    );
}