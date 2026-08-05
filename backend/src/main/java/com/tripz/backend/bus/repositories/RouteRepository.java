package com.tripz.backend.bus.repositories;
import org.springframework.data.jpa.repository.JpaRepository;

import com.tripz.backend.bus.models.Location;
import com.tripz.backend.bus.models.Route;

public interface RouteRepository extends JpaRepository<Route, Long> {

    Route findByFromLocationAndToLocation(Location fromLocation, Location toLocation);

}