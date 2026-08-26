package com.tripz.backend.ai;

import java.math.BigDecimal;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiChatResponseDTO {
    private String reply;
    private List<BusRecommendation> recommendations;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BusRecommendation {
        private Long busScheduleId;
        private String companyName;
        private String busType;
        private String fromLocation;
        private String toLocation;
        private String departureTime;
        private String arrivalTime;
        private BigDecimal price;
        private Long availableSeats;
    }
}
