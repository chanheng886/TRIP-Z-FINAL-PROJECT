package com.tripz.backend.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Payload sent from Flutter to Spring Boot to initiate an ABA Payway checkout.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AbaCheckoutRequestDTO {
    private Long bookingId;
    private Double amount;
    private String currency; // "USD" or "KHR"
}
