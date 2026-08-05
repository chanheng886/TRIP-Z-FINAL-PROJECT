package com.tripz.backend.bus.repositories;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.BusType;

public interface BusTypeRepository extends JpaRepository<BusType, Long> {

    Optional<BusType> findByBusType(String busType);
    
}