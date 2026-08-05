package com.tripz.backend.bus.repositories;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.tripz.backend.bus.models.Location;

public interface LocationRepository extends JpaRepository<Location, Long> {
    Optional<Location> findByLocationName(String locationName);
}
