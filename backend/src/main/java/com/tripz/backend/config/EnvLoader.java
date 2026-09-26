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
        normalizeRedisUrl();
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
            if (dbUrl.startsWith("jdbc:")) {
                dbUrl = dbUrl.substring(5);
            }
            if (dbUrl.startsWith("postgres://")) {
                dbUrl = "postgresql://" + dbUrl.substring("postgres://".length());
            }

            int slashSlashIdx = dbUrl.indexOf("://");
            int atIdx = dbUrl.indexOf('@');
            if (slashSlashIdx > 0 && atIdx > slashSlashIdx) {
                String userPass = dbUrl.substring(slashSlashIdx + 3, atIdx);
                int colonIdx = userPass.indexOf(':');
                String user = (colonIdx >= 0) ? userPass.substring(0, colonIdx) : userPass;
                String pass = (colonIdx >= 0) ? userPass.substring(colonIdx + 1) : "";

                String hostAndPath = dbUrl.substring(atIdx + 1);
                int slashIdx = hostAndPath.indexOf('/');
                String host = (slashIdx >= 0) ? hostAndPath.substring(0, slashIdx) : hostAndPath;
                String path = (slashIdx >= 0) ? hostAndPath.substring(slashIdx) : "";
                if (!host.contains(":")) {
                    host = host + ":5432";
                }

                String cleanJdbcUrl = "jdbc:postgresql://" + host + path;
                System.setProperty("DB_URL", cleanJdbcUrl);
                System.setProperty("spring.datasource.url", cleanJdbcUrl);

                if (!user.isEmpty()) {
                    System.setProperty("DB_USERNAME", user);
                    System.setProperty("spring.datasource.username", user);
                }
                if (!pass.isEmpty()) {
                    System.setProperty("DB_PASSWORD", pass);
                    System.setProperty("spring.datasource.password", pass);
                }
                log.info("[EnvLoader] Parsed embedded credentials. Clean JDBC URL: {}", cleanJdbcUrl);
            } else {
                if (!dbUrl.startsWith("postgresql://")) {
                    dbUrl = "postgresql://" + dbUrl;
                }
                String cleanJdbcUrl = "jdbc:" + dbUrl;
                System.setProperty("DB_URL", cleanJdbcUrl);
                System.setProperty("spring.datasource.url", cleanJdbcUrl);
                log.info("[EnvLoader] Database URL normalized for JDBC: {}", sanitizeJdbcUrl(cleanJdbcUrl));
            }
        } else {
            log.warn("[EnvLoader] Neither DB_URL nor DATABASE_URL was found! Falling back to localhost:5432");
        }
    }

    private static String sanitizeJdbcUrl(String url) {
        return url.replaceAll(":[^/@:]+@", ":****@");
    }

    private static void normalizeRedisUrl() {
        String redisUrl = System.getProperty("REDIS_URL");
        if (redisUrl == null || redisUrl.isBlank()) {
            redisUrl = System.getenv("REDIS_URL");
        }

        if (redisUrl != null && !redisUrl.isBlank()) {
            redisUrl = redisUrl.trim();
            System.setProperty("spring.data.redis.url", redisUrl);
            log.info("[EnvLoader] Redis URL configured for Spring Data Redis: {}", sanitizeRedisUrl(redisUrl));
        } else {
            String redisHost = System.getProperty("REDIS_HOST");
            if (redisHost == null || redisHost.isBlank()) {
                redisHost = System.getenv("REDIS_HOST");
            }
            if (redisHost != null && !redisHost.isBlank()) {
                redisHost = redisHost.trim();
                if (redisHost.startsWith("https://")) {
                    redisHost = redisHost.substring("https://".length());
                } else if (redisHost.startsWith("http://")) {
                    redisHost = redisHost.substring("http://".length());
                }
                System.setProperty("REDIS_HOST", redisHost);
                System.setProperty("spring.data.redis.host", redisHost);
            }
        }
    }

    private static String sanitizeRedisUrl(String url) {
        return url.replaceAll(":[^/@:]+@", ":****@");
    }
}
