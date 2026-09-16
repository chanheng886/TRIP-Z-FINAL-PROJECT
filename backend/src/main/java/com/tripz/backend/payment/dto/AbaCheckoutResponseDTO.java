package com.tripz.backend.payment.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Returned to Flutter containing the ABA Payway checkout URL and transaction ID.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AbaCheckoutResponseDTO {
    private String checkoutUrl;
    private String transactionId;
    private String status;
    private String qrString;
    private String qrImage;
    private String abapayDeeplink;
}

