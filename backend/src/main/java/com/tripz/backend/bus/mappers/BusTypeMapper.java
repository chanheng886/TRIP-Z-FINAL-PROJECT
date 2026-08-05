package com.tripz.backend.bus.mappers;

import org.springframework.stereotype.Component;

import com.tripz.backend.bus.dtos.RequestDTO.BusTypeRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusTypeResponseDTO;
import com.tripz.backend.bus.models.BusType;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BusTypeMapper {

    //✅✅ Convert from dto to entity
    public BusType toEntity(BusTypeRequestDTO dto){
        BusType busType = new BusType();
        busType.setBusType(dto.getBusType());
        return busType;
    }    

    //✅✅ Update
    public BusType toUpdate(BusType busType, BusTypeRequestDTO dto){
        busType.setBusType(dto.getBusType());
        return busType;
    }

    //✅✅ Display datas
    public BusTypeResponseDTO toResponse(BusType busType){
        return BusTypeResponseDTO.builder()
        .id(busType.getId())
        .busType(busType.getBusType()).build();
    }
}
