package com.tripz.backend.payment;

import com.tripz.backend.payment.dto.AbaCheckoutResponseDTO;
import com.tripz.backend.payment.dto.AbaTransactionStatusDTO;
import com.tripz.backend.payment.services.AbaPaywayService;
import com.tripz.backend.config.EnvLoader;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class AbaPaywayLiveTest {

    static {
        EnvLoader.load();
    }

    @Autowired
    private AbaPaywayService abaPaywayService;

    @Test
    void testAbaPaywayPurchaseApi() {
        String testTranId = "TZ-TEST-" + (System.currentTimeMillis() % 10000000);
        System.out.println("=== TESTING ABA PAYWAY /purchase WITH TRAN_ID: " + testTranId + " ===");

        AbaCheckoutResponseDTO response = abaPaywayService.createPurchase(testTranId, 5.00);

        System.out.println("Status: " + response.getStatus());
        System.out.println("QR String: " + response.getQrString());
        System.out.println("QR Image: " + (response.getQrImage() != null ? (response.getQrImage().substring(0, Math.min(60, response.getQrImage().length())) + "...") : "null"));
        System.out.println("Deeplink: " + response.getAbapayDeeplink());

        assertNotNull(response.getTransactionId(), "Transaction ID should not be null");

        // Test status check
        System.out.println("=== TESTING ABA PAYWAY /check-transaction-2 ===");
        AbaTransactionStatusDTO status = abaPaywayService.checkTransaction(testTranId);
        System.out.println("Check Status Approved: " + status.isApproved());
        System.out.println("Check Status PaymentStatus: " + status.getPaymentStatus());
        System.out.println("Check Status Code: " + status.getPaymentStatusCode());
    }
}
