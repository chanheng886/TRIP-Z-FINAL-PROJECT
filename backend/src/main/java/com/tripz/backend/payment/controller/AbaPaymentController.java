package com.tripz.backend.payment.controller;

import com.tripz.backend.booking.models.Booking;
import com.tripz.backend.booking.repositories.BookingRepository;
import com.tripz.backend.booking.enums.PaymentStatus;
import com.tripz.backend.payment.dto.AbaCallbackDTO;
import com.tripz.backend.payment.dto.AbaCheckoutRequestDTO;
import com.tripz.backend.payment.dto.AbaCheckoutResponseDTO;
import com.tripz.backend.payment.services.AbaPaywayService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;

/**
 * AbaPaymentController
 *
 * REST endpoints for ABA Payway payment integration:
 *   POST /payment/aba/checkout  - Flutter calls this to get the checkout URL
 *   POST /payment/aba/callback  - ABA Payway servers POST payment results here
 *   GET  /payment/aba/return    - Redirect target after successful payment (detected by WebView)
 *   GET  /payment/aba/cancel    - Redirect target after user cancels payment
 */
@Slf4j
@RestController
@RequestMapping("/payment/aba")
@RequiredArgsConstructor
public class AbaPaymentController {

    private final AbaPaywayService abaPaywayService;
    private final BookingRepository bookingRepository;

    /**
     * Called by Flutter after user selects ABA Payway.
     * Directly calls ABA PayWay purchase API server-to-server and returns
     * the transaction ID, official KHQR qrString, qrImage, and abapayDeeplink.
     */
    @PostMapping("/checkout")
    public ResponseEntity<AbaCheckoutResponseDTO> createCheckout(
            @RequestBody AbaCheckoutRequestDTO request) {

        long bId = request.getBookingId() != null ? request.getBookingId() : 0;
        String millisStr = String.valueOf(System.currentTimeMillis());
        String timeSuffix = millisStr.length() > 10 ? millisStr.substring(millisStr.length() - 10) : millisStr;
        String transactionId = "TZ-" + bId + "-" + timeSuffix;
        if (transactionId.length() > 20) {
            transactionId = transactionId.substring(0, 20);
        }

        log.info("[AbaPayway] Creating checkout for bookingId={}, amount={}",
                request.getBookingId(), request.getAmount());

        AbaCheckoutResponseDTO response = abaPaywayService.createPurchase(
                transactionId,
                request.getAmount() != null ? request.getAmount() : 0.0
        );

        return ResponseEntity.ok(response);
    }

    /**
     * Polled by Flutter to check if payment is completed.
     * When ABA returns APPROVED (code 0), automatically marks the booking as PAID.
     */
    @GetMapping("/check-transaction")
    public ResponseEntity<com.tripz.backend.payment.dto.AbaTransactionStatusDTO> checkTransaction(
            @RequestParam String tran_id) {

        com.tripz.backend.payment.dto.AbaTransactionStatusDTO status = abaPaywayService.checkTransaction(tran_id);

        if (status.isApproved()) {
            try {
                String[] parts = tran_id.split("-");
                if (parts.length >= 2) {
                    Long bookingId = Long.parseLong(parts[1]);
                    Optional<Booking> bookingOpt = bookingRepository.findById(bookingId);
                    if (bookingOpt.isPresent()) {
                        Booking booking = bookingOpt.get();
                        booking.setPaymentMethod("ABA Payway");
                        booking.setPaymentStatus(PaymentStatus.PAID);
                        bookingRepository.save(booking);
                        log.info("[AbaPayway] Polling confirmed: Booking {} marked as PAID", bookingId);
                    }
                }
            } catch (Exception e) {
                log.error("[AbaPayway] Failed to update booking from poll status for tran_id={}: {}", tran_id, e.getMessage());
            }
        }

        return ResponseEntity.ok(status);
    }


    /**
     * ABA Payway sandbox/production servers POST payment results here.
     * Verifies the HMAC-SHA512 signature and updates booking payment status.
     */
    @PostMapping("/callback")
    public ResponseEntity<Map<String, String>> handleCallback(
            @RequestBody AbaCallbackDTO callback) {

        log.info("[AbaPayway] Callback received: tran_id={}, status={}",
                callback.getTranId(), callback.getPaymentStatus());

        // 1. Verify the HMAC-SHA512 signature from ABA servers
        boolean isValid = abaPaywayService.verifyCallbackSignature(callback);
        if (!isValid) {
            log.warn("[AbaPayway] Invalid callback signature for tran_id={}", callback.getTranId());
            return ResponseEntity.badRequest()
                    .body(Map.of("result", "invalid_signature"));
        }

        // 2. Extract bookingId from tran_id (format: "TZ-{bookingId}-{timestamp}")
        try {
            String[] parts = callback.getTranId().split("-");
            // parts[0]="TZ", parts[1]="{bookingId}", parts[2]="{timestamp}"
            if (parts.length >= 2) {
                Long bookingId = Long.parseLong(parts[1]);
                Optional<Booking> bookingOpt = bookingRepository.findById(bookingId);

                if (bookingOpt.isPresent()) {
                    Booking booking = bookingOpt.get();
                    // ABA Payway: "0" = payment successful
                    if ("0".equals(callback.getPaymentStatus())) {
                        booking.setPaymentMethod("ABA Payway");
                        booking.setPaymentStatus(PaymentStatus.PAID);
                        bookingRepository.save(booking);
                        log.info("[AbaPayway] Booking {} marked as PAID via ABA Payway", bookingId);
                    } else {
                        booking.setPaymentStatus(PaymentStatus.FAILED);
                        bookingRepository.save(booking);
                        log.warn("[AbaPayway] Payment FAILED/cancelled for booking {}. ABA status={}",
                                bookingId, callback.getPaymentStatus());
                    }
                } else {
                    log.warn("[AbaPayway] Booking {} not found for tran_id={}", bookingId, callback.getTranId());
                }
            }
        } catch (NumberFormatException e) {
            log.error("[AbaPayway] Could not parse bookingId from tran_id={}", callback.getTranId());
        }

        // ABA expects a "OK" response
        return ResponseEntity.ok(Map.of("result", "OK"));
    }

    /**
     * ABA Payway redirects the WebView here after a successful payment.
     * The Flutter WebView intercepts this URL to close and show the ticket screen.
     */
    @GetMapping("/return")
    public ResponseEntity<String> paymentReturn(
            @RequestParam(required = false) String tran_id,
            @RequestParam(required = false) String status) {

        log.info("[AbaPayway] Payment return: tran_id={}, status={}", tran_id, status);
        // Return a simple HTML page. The Flutter WebView intercepts this URL.
        return ResponseEntity.ok("""
                <html><body style="font-family:sans-serif;text-align:center;padding:40px">
                <h2 style="color:#10B981">&#10003; Payment Successful!</h2>
                <p>Redirecting back to TRIP-Z...</p>
                </body></html>
                """);
    }

    /**
     * ABA Payway redirects the WebView here if the user cancels payment.
     */
    @GetMapping("/cancel")
    public ResponseEntity<String> paymentCancel() {
        log.info("[AbaPayway] Payment cancelled by user.");
        return ResponseEntity.ok("""
                <html><body style="font-family:sans-serif;text-align:center;padding:40px">
                <h2 style="color:#EF4444">Payment Cancelled</h2>
                <p>Returning to TRIP-Z...</p>
                </body></html>
                """);
    }
}
