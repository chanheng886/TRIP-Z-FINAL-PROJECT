package com.tripz.backend.config;

import lombok.extern.slf4j.Slf4j;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Utility to load environment variables from a local .env file into
 * JVM System properties if they are not already set in the system environment.
 */
@Slf4j
public final class EnvLoader {

    private static final AtomicBoolean LOADED = new AtomicBoolean(false);

    private EnvLoader() {}

    public static void load() {
        if (!LOADED.compareAndSet(false, true)) {
            return;
        }

        // Candidates to search for .env
        String[] candidatePaths = {
            ".env",
            "backend/.env",
            "../backend/.env",
            "../../backend/.env"
        };

        File envFile = null;
        for (String path : candidatePaths) {
            File f = new File(path);
            if (f.exists() && f.isFile()) {
                envFile = f;
                break;
            }
        }

        if (envFile == null) {
            log.info("[EnvLoader] No .env file found in candidate paths. Relying on OS environment variables.");
            normalizeDatabaseUrl();
            return;
        }

        log.info("[EnvLoader] Loading environment variables from: {}", envFile.getAbsolutePath());

        try (BufferedReader reader = new BufferedReader(new FileReader(envFile, StandardCharsets.UTF_8))) {
            String line;
            int loadedCount = 0;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }

                int eqIdx = line.indexOf('=');
                if (eqIdx <= 0) {
                    continue;
                }

                String key = line.substring(0, eqIdx).trim();
                String value = line.substring(eqIdx + 1).trim();

                // Strip surrounding quotes if present
                if ((value.startsWith("\"") && value.endsWith("\"") && value.length() >= 2) ||
                    (value.startsWith("'") && value.endsWith("'") && value.length() >= 2)) {
                    value = value.substring(1, value.length() - 1);
                }

                // Set in System properties if not already explicitly set via JVM -D flags
                if (System.getProperty(key) == null) {
                    System.setProperty(key, value);
                    loadedCount++;
                }
            }
            log.info("[EnvLoader] Loaded {} environment variables from .env file into System properties.", loadedCount);
        } catch (IOException e) {
            log.warn("[EnvLoader] Failed to read .env file: {}", e.getMessage());
        }

        normalizeDatabaseUrl();
    }

    private static void normalizeDatabaseUrl() {
        String dbUrl = System.getProperty("DB_URL");
        if (dbUrl == null || dbUrl.isBlank()) {
            dbUrl = System.getenv("DB_URL");
        }
        if (dbUrl == null || dbUrl.isBlank()) {
            dbUrl = System.getenv("DATABASE_URL");
        }
        if (dbUrl == null || dbUrl.isBlank()) {
            dbUrl = System.getProperty("DATABASE_URL");
        }

        if (dbUrl != null && !dbUrl.isBlank()) {
            dbUrl = dbUrl.trim();
            if (dbUrl.startsWith("postgres://")) {
                dbUrl = "jdbc:postgresql://" + dbUrl.substring("postgres://".length());
            } else if (dbUrl.startsWith("postgresql://")) {
                dbUrl = "jdbc:postgresql://" + dbUrl.substring("postgresql://".length());
            } else if (!dbUrl.startsWith("jdbc:")) {
                dbUrl = "jdbc:postgresql://" + dbUrl;
            }
            System.setProperty("DB_URL", dbUrl);
            System.setProperty("spring.datasource.url", dbUrl);
            log.info("[EnvLoader] Database URL normalized for JDBC: {}", sanitizeJdbcUrl(dbUrl));
        } else {
            log.warn("[EnvLoader] Neither DB_URL nor DATABASE_URL was found! Falling back to localhost:5432");
        }
    }

    private static String sanitizeJdbcUrl(String url) {
        return url.replaceAll(":[^/@:]+@", ":****@");
    }
}
