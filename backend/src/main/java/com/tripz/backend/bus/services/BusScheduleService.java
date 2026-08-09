package com.tripz.backend.bus.services;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import com.tripz.backend.bus.dtos.RequestDTO.BusScheduleRequestDTO;
import com.tripz.backend.bus.dtos.RequestDTO.BusScheduleSearchRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusScheduleResponseDTO;
import com.tripz.backend.bus.mappers.BusScheduleMapper;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.bus.repositories.BusScheduleRepository;
import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor
public class BusScheduleService {
    private final BusScheduleRepository busScheduleRepository;
    private final BusScheduleMapper busScheduleMapper;

    //✅✅ Get All Bus Schedule
    public List<BusScheduleResponseDTO> getAllBusSchedule(){
        return busScheduleRepository.findAll()
            .stream()
            .map(busScheduleMapper::toResponse)
            .collect(Collectors.toList());
    }

    // Get Bus Schedule by id
    public BusScheduleResponseDTO getBusScheduleById(Long id){
        BusSchedule busSchedule = busScheduleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bus schedule with id: " + id + "Not Found!!"));        
        return busScheduleMapper.toResponse(busSchedule);
    }


    //✅ (For customer)
    public List<BusScheduleResponseDTO> searchBusSchedules(BusScheduleSearchRequestDTO dto){
        List<BusSchedule> schedules = busScheduleRepository
            .findByRoute_FromLocation_IdAndRoute_ToLocation_IdAndTravelDateAndAvailableSeatGreaterThan(
                dto.getFromLocation(), 
                dto.getToLocation(), 
                dto.getTravelDate(), 
                0L);
        
        return schedules.stream().map(busScheduleMapper::toResponse).collect(Collectors.toList());
    }

    //✅✅ Create Bus Schedule
    public BusScheduleResponseDTO createBusSchedule(BusScheduleRequestDTO dto){
        BusSchedule schedule = busScheduleMapper.toEntity(dto);
        BusSchedule saved = busScheduleRepository.save(schedule);
        return busScheduleMapper.toResponse(saved);
    }

    //✅✅ Update Bus Schedule
    public BusScheduleResponseDTO updateBusSchedule(Long id, BusScheduleRequestDTO dto){
        BusSchedule schedule = busScheduleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Schedule with id: " + "Not Found!"));
        BusSchedule updated = busScheduleMapper.toUpdate(schedule, dto);
        BusSchedule saved = busScheduleRepository.save(updated);
        return busScheduleMapper.toResponse(saved);
    }

    //✅✅ Delete Bus Schedule
    public BusScheduleResponseDTO deleteBusSchedule(Long id){
        BusSchedule busSchedule = busScheduleRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bus Schedule with id: " + id + "Not Found!"));
        
        busScheduleRepository.delete(busSchedule);
        return busScheduleMapper.toResponse(busSchedule);
    }
}
