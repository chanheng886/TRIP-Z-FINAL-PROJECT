package com.tripz.backend.bus.services;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import com.tripz.backend.bus.dtos.RequestDTO.BusRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusResponseDTO;
import com.tripz.backend.bus.mappers.BusMapper;
import com.tripz.backend.bus.models.Bus;
import com.tripz.backend.bus.repositories.BusRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BusService {
    private final BusMapper busMapper;
    private final BusRepository busRepository;

    //✅ Get All Bus
    public List<BusResponseDTO> getAllBus(){
        return busRepository.findAll()
            .stream().map(busMapper::toResponse).collect(Collectors.toList());
    }

    //✅ Get Bus By Id
    public BusResponseDTO getBusByID(Long id){
        return busRepository.findById(id)
            .map(busMapper::toResponse)
            .orElseThrow(() -> new RuntimeException("Bus with id: " + id + " = Not Found!"));
    }

    //✅ Get Bus By Company Name
    public List<BusResponseDTO> getBusesByCompany(String companyName){
        return busRepository.findByCompany_CompanyName(companyName)
            .stream().map(busMapper::toResponse).collect(Collectors.toList());
    }

    //✅ Create Bus 
    public BusResponseDTO createBus(BusRequestDTO dto){
        Bus bus = busMapper.toEntity(dto);
        Bus save = busRepository.save(bus);

        return busMapper.toResponse(save);
    }

    //✅ Update Bus
    public BusResponseDTO updateBus(Long id, BusRequestDTO dto){
        Bus bus = busRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bus with id: " + id + " = Not Found!"));
        
        busMapper.toUpdate(bus, dto);
        Bus update = busRepository.save(bus);

        return busMapper.toResponse(update);
    }

    //✅ Delete Bus
    public BusResponseDTO deleteBusById(Long id){
        Bus bus = busRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bus with id: " + id + "Now found!"));
        busRepository.delete(bus);
        return busMapper.toResponse(bus);
    }
}