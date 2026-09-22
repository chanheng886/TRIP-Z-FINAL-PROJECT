package com.tripz.backend.bus.services;
import java.util.List;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import com.tripz.backend.bus.dtos.RequestDTO.BusTypeRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusTypeResponseDTO;
import com.tripz.backend.bus.mappers.BusTypeMapper;
import com.tripz.backend.bus.models.BusType;
import com.tripz.backend.bus.repositories.BusTypeRepository;
import com.tripz.backend.config.RedisConfig;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BusTypeService {
    private final BusTypeMapper busTypeMapper;
    private final BusTypeRepository busTypeRepository;

    //✅✅Get All Bus Type
    @Cacheable(value = RedisConfig.CACHE_BUS_TYPES, key = "'all'")
    public List<BusTypeResponseDTO> getAllBusType(){
        return busTypeRepository.findAll()
            .stream()
            .map(busTypeMapper::toResponse).toList();
    }

    //✅✅ Get Bus Type By Id
    @Cacheable(value = RedisConfig.CACHE_BUS_TYPES, key = "#id")
    public BusTypeResponseDTO getBusTypeById(Long id){
        return busTypeRepository.findById(id)
            .map(busTypeMapper::toResponse)
            .orElseThrow(() -> new RuntimeException("Company with id: " + id + "Not Found!"));
    }

    //✅✅ Get Bus type by type name
    public BusTypeResponseDTO getBusTypeBuyBusType(String busType){
        return busTypeRepository.findByBusType(busType)
            .map(busTypeMapper::toResponse)
            .orElseThrow(() -> new RuntimeException("Company with id: " + busType + "Not Found"));
    }

    // ✅✅ Create Bus Type
    @CacheEvict(value = RedisConfig.CACHE_BUS_TYPES, allEntries = true)
    public BusTypeResponseDTO createBusType(BusTypeRequestDTO dto){
        BusType busType = busTypeMapper.toEntity(dto);
        BusType saved = busTypeRepository.save(busType);

        return busTypeMapper.toResponse(saved);
    }

    //✅✅ Update bus type
    @CacheEvict(value = RedisConfig.CACHE_BUS_TYPES, allEntries = true)
    public BusTypeResponseDTO updateBusType(Long id, BusTypeRequestDTO dto){
        BusType bustype = busTypeRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bus type with id: " + id + "Not Found!"));

        busTypeMapper.toUpdate(bustype, dto);
        BusType updated = busTypeRepository.save(bustype);
        return busTypeMapper.toResponse(updated);

    }

    //✅✅ Delete Bus Type
    @CacheEvict(value = RedisConfig.CACHE_BUS_TYPES, allEntries = true)
    public BusTypeResponseDTO deleteBusType(Long id){
        BusType busType = busTypeRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bus type id: " + id + "Not Found"));
        busTypeRepository.delete(busType);
        return busTypeMapper.toResponse(busType);
    }
}
