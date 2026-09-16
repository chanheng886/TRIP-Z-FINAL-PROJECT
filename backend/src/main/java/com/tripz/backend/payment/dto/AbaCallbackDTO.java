package com.tripz.backend.payment.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * ABA Payway callback payload POSTed by ABA servers after payment completion.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AbaCallbackDTO {
    @JsonProperty("merchant_id")
    private String merchantId;

    @JsonProperty("tran_id")
    private String tranId;

    @JsonProperty("amount")
    private String amount;

    @JsonProperty("payment_status")
    private String paymentStatus; // "0" = success, "9" = cancelled

    @JsonProperty("payment_option")
    private String paymentOption; // "abapay", "cards", "abapay_deeplink"

    @JsonProperty("status")
    private String status;

    @JsonProperty("hash")
    private String hash; // RSA-signed verification hash from ABA
}
