package com.tripz.backend.config;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
@RequiredArgsConstructor
public class DatabaseSchemaFixer implements ApplicationRunner {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(ApplicationArguments args) {
        log.info("🔧 [DatabaseSchemaFixer] Checking and applying database schema migrations...");
        try {
            // 1. Add departure_notified column if not exists
            jdbcTemplate.execute("ALTER TABLE booking ADD COLUMN IF NOT EXISTS departure_notified BOOLEAN DEFAULT false");
            jdbcTemplate.execute("UPDATE booking SET departure_notified = false WHERE departure_notified IS NULL");
            jdbcTemplate.execute("ALTER TABLE booking ALTER COLUMN departure_notified SET DEFAULT false");
            log.info("✅ [DatabaseSchemaFixer] 'booking.departure_notified' column verified.");
        } catch (Exception e) {
            log.warn("⚠️ [DatabaseSchemaFixer] departure_notified migration note: {}", e.getMessage());
        }

        try {
            // 2. Add payment_status column if not exists
            jdbcTemplate.execute("ALTER TABLE booking ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50) DEFAULT 'PENDING'");
            jdbcTemplate.execute("UPDATE booking SET payment_status = 'PENDING' WHERE payment_status IS NULL");
            jdbcTemplate.execute("ALTER TABLE booking ALTER COLUMN payment_status SET DEFAULT 'PENDING'");
            log.info("✅ [DatabaseSchemaFixer] 'booking.payment_status' column verified.");
        } catch (Exception e) {
            log.warn("⚠️ [DatabaseSchemaFixer] payment_status migration note: {}", e.getMessage());
        }

        try {
            // 3. Add fcm_token column to tb_users if not exists
            jdbcTemplate.execute("ALTER TABLE tb_users ADD COLUMN IF NOT EXISTS fcm_token TEXT");
            log.info("✅ [DatabaseSchemaFixer] 'tb_users.fcm_token' column verified.");
        } catch (Exception e) {
            log.warn("⚠️ [DatabaseSchemaFixer] fcm_token migration note: {}", e.getMessage());
        }
    }
}
