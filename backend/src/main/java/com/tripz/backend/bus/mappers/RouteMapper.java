package com.tripz.backend.bus.mappers;
import org.springframework.stereotype.Component;
import com.tripz.backend.bus.dtos.RequestDTO.RouteRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.RouteResponseDTO;
import com.tripz.backend.bus.models.Location;
import com.tripz.backend.bus.models.Route;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class RouteMapper {
    public Route toEntity(RouteRequestDTO dto, Location fromLocation, Location toLocation){
        Route route = new Route();
        route.setFromLocation(fromLocation);
        route.setToLocation(toLocation);

        return route;
    }

    public void toUpdate(Route route, Location fromLocation, Location toLocation){
        route.setFromLocation(fromLocation);
        route.setToLocation(toLocation);
    }

    public RouteResponseDTO toResponse(Route route){
        return RouteResponseDTO.builder()
        .id(route.getId())
        .fromLocation(route.getFromLocation().getLocationName())
        .toLocation(route.getToLocation().getLocationName()).build();
    }
}