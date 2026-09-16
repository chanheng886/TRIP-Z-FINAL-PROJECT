package com.tripz.backend.booking.enums;

/**
 * Payment status for a booking.
 * Tracks whether the payment has been confirmed by the payment gateway.
 */
public enum PaymentStatus {
    /** Initial state — booking created but payment not yet confirmed */
    PENDING,
    /** Payment confirmed by payment gateway (ABA callback, Bakong, etc.) */
    PAID,
    /** Payment failed or cancelled */
    FAILED
}
