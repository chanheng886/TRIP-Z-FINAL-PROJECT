package com.tripz.backend.bus.repositories;

import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.Location;
import com.tripz.backend.bus.models.Route;

public interface RouteRepository extends JpaRepository<Route, Long> {
    @Override
    @EntityGraph(attributePaths = {"fromLocation", "toLocation"})
    List<Route> findAll();

    Route findByFromLocationAndToLocation(Location fromLocation, Location toLocation);

}