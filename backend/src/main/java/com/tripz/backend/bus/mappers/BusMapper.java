package com.tripz.backend.bus.mappers;
import org.springframework.stereotype.Component;
import com.tripz.backend.bus.dtos.RequestDTO.BusRequestDTO;
import com.tripz.backend.bus.dtos.ResponseDTO.BusResponseDTO;
import com.tripz.backend.bus.models.Bus;
import com.tripz.backend.bus.models.BusType;
import com.tripz.backend.bus.models.Company;
import com.tripz.backend.bus.repositories.BusTypeRepository;
import com.tripz.backend.bus.repositories.CompanyRepository;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class BusMapper {
    private final BusTypeRepository busTypeRepository;
    private final CompanyRepository busCompanyRepository;
        //✅✅ Request || change from entity into bus model
        public Bus toEntity(BusRequestDTO dto){
            BusType busType = busTypeRepository.findByBusType(dto.getBusType())
                .orElseThrow(() -> new RuntimeException("No Bus Type Found!"));
            Company companyName =  busCompanyRepository.findByCompanyName(dto.getCompanyName())
                .orElseThrow(() -> new RuntimeException("Company not found!"));
            Bus bus = Bus.builder()
            .company(companyName)
            .busType(busType)
            .imageUrl(dto.getImageUrl())
            .seatCapacity(dto.getSeatCapacity())
            .plateNumber(dto.getPlateNumber()).build();

            return bus;
        }

        //✅✅ Request || update bus
        public void toUpdate(Bus bus, BusRequestDTO dto){
            BusType busType = busTypeRepository.findByBusType(dto.getBusType())
                .orElseThrow(() -> new RuntimeException("No Bus Type Found!"));
            Company comapnyName = busCompanyRepository.findByCompanyName(dto.getCompanyName())
                .orElseThrow(() -> new RuntimeException("Company Not Found!"));

            bus.setCompany(comapnyName);
            bus.setBusType(busType);
            bus.setSeatCapacity(dto.getSeatCapacity());
            bus.setImageUrl(dto.getImageUrl());
            bus.setPlateNumber(dto.getPlateNumber());
        }

        public BusResponseDTO toResponse(Bus bus){
            return BusResponseDTO.builder()
                .id(bus.getId())
                .companyId(bus.getCompany().getId())
                .companyName(bus.getCompany().getCompanyName())
                .busType(bus.getBusType().getBusType())
                .seatCapacity(bus.getSeatCapacity().toString())
                .plateNumber(bus.getPlateNumber())
                .imageUrl(bus.getImageUrl()).build();
        }
}
