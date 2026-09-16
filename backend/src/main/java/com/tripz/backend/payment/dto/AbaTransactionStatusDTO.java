package com.tripz.backend.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AbaTransactionStatusDTO {
    private String tranId;
    private boolean isApproved;
    private String paymentStatus;
    private Integer paymentStatusCode;
    private String message;
}
