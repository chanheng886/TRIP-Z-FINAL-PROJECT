package com.tripz.backend.bus.repositories;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.BusBooking;
public interface BusBookingRepository extends JpaRepository<BusBooking, Long> {

    
}