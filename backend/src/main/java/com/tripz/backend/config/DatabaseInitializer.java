package com.tripz.backend.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@RequiredArgsConstructor
@Slf4j
public class DatabaseInitializer implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        try {
            log.info("Checking and adjusting booking table check constraints for new booking statuses...");
            jdbcTemplate.execute("ALTER TABLE booking DROP CONSTRAINT IF EXISTS booking_status_check");
            jdbcTemplate.execute("ALTER TABLE booking ADD CONSTRAINT booking_status_check CHECK (status >= 0 AND status <= 10)");
            log.info("Booking table status check constraint updated successfully.");
        } catch (Exception e) {
            log.warn("Database constraint adjustment warning: {}", e.getMessage());
        }
    }
}
