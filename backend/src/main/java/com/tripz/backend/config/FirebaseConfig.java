package com.tripz.backend.config;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import lombok.extern.slf4j.Slf4j;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Value("${firebase.config-path:classpath:firebase-service-account.json}")
    private String configPath;

    @Bean
    public FirebaseApp firebaseApp() {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        try {
            InputStream serviceAccount = null;

            if (configPath.startsWith("classpath:")) {
                String resourcePath = configPath.substring("classpath:".length()).trim();
                serviceAccount = getClass().getClassLoader().getResourceAsStream(resourcePath);
            } else {
                File file = new File(configPath);
                if (file.exists() && file.isFile()) {
                    serviceAccount = new FileInputStream(file);
                }
            }

            if (serviceAccount == null) {
                log.warn("⚠️ [Firebase] No credentials found at '{}'. FCM push notifications will run in mock mode until firebase-service-account.json is provided.", configPath);
                return null;
            }

            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();

            FirebaseApp app = FirebaseApp.initializeApp(options);
            log.info("✅ [Firebase] FirebaseApp initialized successfully for project: {}", options.getProjectId());
            return app;
        } catch (Exception e) {
            log.warn("⚠️ [Firebase] Failed to initialize FirebaseApp: {}. Push notifications will be skipped.", e.getMessage());
            return null;
        }
    }
}
