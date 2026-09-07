package com.tripz.backend.bus.repositories;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tripz.backend.bus.enums.BusScheduleStatus;
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

    @Query("""
        SELECT COUNT(bs) > 0 FROM BusSchedule bs
        WHERE bs.bus.id = :busId
        AND bs.travelDate = :travelDate
        AND bs.busScheduleStatus != :cancelledStatus
        AND (:newDepartureTime < bs.arrivalTime AND :newArrivalTime > bs.departureTime)
    """)
    boolean existsOverlappingSchedule(
        @Param("busId") Long busId,
        @Param("travelDate") LocalDate travelDate,
        @Param("newDepartureTime") LocalTime newDepartureTime,
        @Param("newArrivalTime") LocalTime newArrivalTime,
        @Param("cancelledStatus") BusScheduleStatus cancelledStatus
    );

    @Query("""
        SELECT COUNT(bs) > 0 FROM BusSchedule bs
        WHERE bs.bus.id = :busId
        AND bs.id != :scheduleId
        AND bs.travelDate = :travelDate
        AND bs.busScheduleStatus != :cancelledStatus
        AND (:newDepartureTime < bs.arrivalTime AND :newArrivalTime > bs.departureTime)
    """)
    boolean existsOverlappingScheduleExcludingId(
        @Param("busId") Long busId,
        @Param("scheduleId") Long scheduleId,
        @Param("travelDate") LocalDate travelDate,
        @Param("newDepartureTime") LocalTime newDepartureTime,
        @Param("newArrivalTime") LocalTime newArrivalTime,
        @Param("cancelledStatus") BusScheduleStatus cancelledStatus
    );
}