package com.tripz.backend.notification.services;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.WebpushConfig;
import com.google.firebase.messaging.WebpushNotification;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class FirebaseMessagingService {

    private final FirebaseApp firebaseApp;

    @Autowired
    public FirebaseMessagingService(@Autowired(required = false) FirebaseApp firebaseApp) {
        this.firebaseApp = firebaseApp;
    }

    /**
     * Sends an FCM push notification to a specific device token.
     *
     * @param fcmToken Target client FCM registration token
     * @param title Notification title
     * @param body Notification body
     * @param data Optional key-value data map for client deep linking
     * @return true if successfully dispatched, false otherwise
     */
    public boolean sendPushNotification(String fcmToken, String title, String body, Map<String, String> data) {
        if (fcmToken == null || fcmToken.trim().isEmpty()) {
            log.debug("[FCM] Target user does not have an FCM token registered.");
            return false;
        }

        if (firebaseApp == null) {
            log.info("[FCM Mock Mode] Notification prepared (no credentials loaded). Token: {} | Title: '{}' | Body: '{}'",
                    fcmToken.substring(0, Math.min(12, fcmToken.length())) + "...", title, body);
            return false;
        }

        try {
            Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

            Message.Builder messageBuilder = Message.builder()
                .setToken(fcmToken)
                .setNotification(notification);

            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }

            // Android specific settings: high priority heads-up alert with custom channel
            AndroidConfig androidConfig = AndroidConfig.builder()
                .setPriority(AndroidConfig.Priority.HIGH)
                .setNotification(AndroidNotification.builder()
                    .setSound("default")
                    .setClickAction("FLUTTER_NOTIFICATION_CLICK")
                    .setChannelId("tripz_departure_alerts")
                    .build())
                .build();
            messageBuilder.setAndroidConfig(androidConfig);

            // Web Push settings for browser notifications
            WebpushConfig webpushConfig = WebpushConfig.builder()
                .setNotification(WebpushNotification.builder()
                    .setTitle(title)
                    .setBody(body)
                    .setIcon("/icons/Icon-192.png")
                    .build())
                .build();
            messageBuilder.setWebpushConfig(webpushConfig);

            String messageId = FirebaseMessaging.getInstance(firebaseApp).send(messageBuilder.build());
            log.info("✅ [FCM] Departure push notification dispatched! Message ID: {}", messageId);
            return true;
        } catch (Exception e) {
            log.error("❌ [FCM] Failed to send push notification to token {}: {}", fcmToken, e.getMessage());
            return false;
        }
    }
}
