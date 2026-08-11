package com.tripz.backend.booking.dtos.RequestDTO;
import java.util.List;
import lombok.Data;

@Data
public class CreateBusBookingRequestDTO {
    private Long customerId;
    private Long busScheduleId;
    private String paymentMethod;
    private List<PassengerRequestDTO> passengers;    
}


