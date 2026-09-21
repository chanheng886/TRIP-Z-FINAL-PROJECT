package com.tripz.backend.config;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class EnvLoaderTest {

    @Test
    void testEnvLoaderLoadsExpectedProperties() {
        EnvLoader.load();

        // Check that essential keys from .env are present in System properties
        assertNotNull(System.getProperty("JWT_SECRET"), "JWT_SECRET should be loaded from .env");
        assertNotNull(System.getProperty("GEMINI_API_KEY"), "GEMINI_API_KEY should be loaded from .env");
        assertNotNull(System.getProperty("ABA_MERCHANT_ID"), "ABA_MERCHANT_ID should be loaded from .env");
        assertNotNull(System.getProperty("ABA_API_KEY"), "ABA_API_KEY should be loaded from .env");
        assertNotNull(System.getProperty("BAKONG_ACCOUNT_ID"), "BAKONG_ACCOUNT_ID should be loaded from .env");
    }
}
