import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/core/config/firebase_options.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/view/admin_dashboard_screen.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/history/view/history_screen.dart';
import 'package:frontend/features/notifications/viewmodel/notification_controller.dart';
import 'package:frontend/shared/service/auth_service.dart';
import 'package:frontend/shared/service/base_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level background message handler required by FirebaseMessaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔔 [FCM Background] Message received: ${message.messageId} | ${message.data}");
}

class PushNotificationService extends GetxService {
  static PushNotificationService get to => Get.find<PushNotificationService>();

  final RxString fcmToken = ''.obs;
  final RxBool isInitialized = false.obs;

  static const String _prefLastTokenKey = 'last_registered_fcm_token_user_';

  @override
  void onInit() {
    super.onInit();
    init();
  }

  /// Initializes Firebase and FirebaseMessaging listeners
  Future<void> init() async {
    try {
      // 1. Initialize Firebase App
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options != null) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }

      // 2. Register background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Request permissions on iOS and Android 13+
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 [FCM] Notification authorization status: ${settings.authorizationStatus}');

      // 4. Retrieve initial device token
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          fcmToken.value = token;
          debugPrint('✅ [FCM] Device Token: $token');
          await registerTokenWithBackend();
        }
      } catch (tokenError) {
        debugPrint('⚠️ [FCM] Error fetching device token: $tokenError');
      }

      // 5. Listen for token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        debugPrint('🔄 [FCM] Device token refreshed: $newToken');
        registerTokenWithBackend();
      });

      // 6. Listen for incoming foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // 7. Handle notification click when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationNavigation(message);
      });

      // 8. Check if app was launched from a terminated state notification tap
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationNavigation(initialMessage);
        });
      }

      isInitialized.value = true;
    } catch (e) {
      debugPrint('⚠️ [FCM] Firebase push notifications disabled or credentials not yet added: $e');
    }
  }

  /// Sends the device FCM token to the backend for the currently authenticated user
  Future<void> registerTokenWithBackend() async {
    final token = fcmToken.value;
    if (token.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final isPaused = prefs.getBool('pause_notifications') ?? false;
    if (isPaused) {
      debugPrint('🔕 [FCM] Registration skipped: user has paused notifications.');
      return;
    }

    if (!Get.isRegistered<AuthViewmodel>()) return;
    final authVM = Get.find<AuthViewmodel>();
    final userId = authVM.currentUser?.id;
    if (userId == null) {
      debugPrint('ℹ️ [FCM] User not logged in. Will register token upon login.');
      return;
    }

    try {
      final userTokenPrefKey = '$_prefLastTokenKey$userId';
      final lastToken = prefs.getString(userTokenPrefKey);

      // Skip duplicate network call if token already registered for this user
      if (lastToken == token) {
        debugPrint('ℹ️ [FCM] Device token already up-to-date on backend for user #$userId.');
        return;
      }

      final authToken = await AuthService().getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final url = Uri.parse('${BaseUrl.users}/$userId/fcm-token');
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        await prefs.setString(userTokenPrefKey, token);
        debugPrint('✅ [FCM] Successfully registered device token with backend for user #$userId');
      } else {
        debugPrint('⚠️ [FCM] Backend token registration returned code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to send token to backend: $e');
    }
  }

  /// Unregisters FCM token on backend when user logs out so this device stops receiving their alerts
  Future<void> unregisterTokenWithBackend(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userTokenPrefKey = '$_prefLastTokenKey$userId';
      await prefs.remove(userTokenPrefKey);

      final authToken = await AuthService().getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final url = Uri.parse('${BaseUrl.users}/$userId/fcm-token');
      await http.patch(
        url,
        headers: headers,
        body: json.encode({'fcmToken': ''}),
      );
      debugPrint('✅ [FCM] Cleared FCM token on backend for user #$userId on logout.');
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to clear token on backend: $e');
    }
  }

  /// Syncs pause status with backend so FCM server-side push notifications are stopped/restored
  Future<void> syncPauseStatusWithBackend(bool isPaused) async {
    if (!Get.isRegistered<AuthViewmodel>()) return;
    final authVM = Get.find<AuthViewmodel>();
    final userId = authVM.currentUser?.id;
    if (userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = await AuthService().getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final url = Uri.parse('${BaseUrl.users}/$userId/fcm-token');
      // If paused, send empty string to backend to disable FCM pushes for this user
      // If unpaused, send the current fcmToken to restore FCM pushes
      final tokenToSend = isPaused ? '' : fcmToken.value;
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode({'fcmToken': tokenToSend}),
      );

      if (response.statusCode == 200) {
        if (isPaused) {
          await prefs.remove(_prefLastTokenKey);
          debugPrint('🔕 [FCM] Successfully paused push notifications on backend for user #$userId');
        } else {
          await prefs.setString(_prefLastTokenKey, fcmToken.value);
          debugPrint('🔔 [FCM] Successfully resumed push notifications on backend for user #$userId');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Failed to sync pause status with backend: $e');
    }
  }

  /// Displays an in-app heads-up snackbar when a push arrives while app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('🔔 [FCM Foreground] Title: ${message.notification?.title}, Data: ${message.data}');

    // If notifications are paused by the user, suppress foreground alerts
    final prefs = await SharedPreferences.getInstance();
    final isPaused = prefs.getBool('pause_notifications') ?? false;
    if (isPaused) {
      debugPrint('🔕 [FCM Foreground] Alert suppressed because user enabled Pause Notifications.');
      return;
    }

    final title = message.notification?.title ?? 'Trip-Z Notification';
    final body = message.notification?.body ?? 'You have a new update regarding your trip.';

    final isDepartureAlert = message.data['type'] == 'DEPARTURE_ALERT';
    final isAdminNewBooking = message.data['type'] == 'ADMIN_NEW_BOOKING';

    final authVM =
        Get.isRegistered<AuthViewmodel>() ? Get.find<AuthViewmodel>() : null;
    final isAdmin = authVM?.currentUser?.role == UserRole.Admin;

    // If an admin notification arrives on a device where a Customer is logged in,
    // suppress it completely so the customer never receives admin alerts.
    if (isAdminNewBooking && !isAdmin) {
      debugPrint('🛡️ [FCM Foreground] Suppressed admin notification for non-admin user.');
      return;
    }

    // Auto-refresh admin dashboard viewmodel if currently active and user is admin
    if (isAdminNewBooking && isAdmin && Get.isRegistered<AdminDashboardViewmodel>()) {
      Get.find<AdminDashboardViewmodel>().loadOptions();
    }

    // Save notification persistently to NotificationController
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().addNotification(
        title: title,
        body: body,
        type: (message.data['type'] as String?) ??
            (isAdminNewBooking
                ? 'ADMIN_NEW_BOOKING'
                : (isDepartureAlert ? 'DEPARTURE_ALERT' : 'SYSTEM')),
        data: Map<String, dynamic>.from(message.data),
      );
    }

    final Color snackBg = isDepartureAlert
        ? const Color(0xFFDC2626)
        : (isAdminNewBooking ? const Color(0xFF0F172A) : const Color(0xFF00B14F));

    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: snackBg,
      colorText: Colors.white,
      icon: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: FaIcon(
          isDepartureAlert
              ? FontAwesomeIcons.bus
              : (isAdminNewBooking
                  ? FontAwesomeIcons.ticket
                  : FontAwesomeIcons.bell),
          color: isAdminNewBooking ? AppColors.green : Colors.white,
          size: 18,
        ),
      ),
      shouldIconPulse: true,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      duration: Duration(seconds: isDepartureAlert ? 10 : (isAdminNewBooking ? 8 : 5)),
      isDismissible: true,
      mainButton: isDepartureAlert
          ? TextButton(
              onPressed: () {
                Get.back();
                _handleNotificationNavigation(message);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View Ticket',
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
            )
          : ((isAdminNewBooking && isAdmin)
              ? TextButton(
                  onPressed: () {
                    Get.back();
                    _handleNotificationNavigation(message);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Bookings',
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              : (message.data['type'] == 'BOOKING_CONFIRMED'
                  ? TextButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => const HistoryScreen());
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Ticket',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null)),
      boxShadows: [
        BoxShadow(
          color: snackBg.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      onTap: (_) {
        Get.back();
        _handleNotificationNavigation(message);
      },
    );
  }

  /// Navigates to history / ticket tab or admin dashboard when user interacts with a notification
  void _handleNotificationNavigation(RemoteMessage message) {
    try {
      final authVM =
          Get.isRegistered<AuthViewmodel>() ? Get.find<AuthViewmodel>() : null;
      final isAdmin = authVM?.currentUser?.role == UserRole.Admin;

      if (message.data['type'] == 'ADMIN_NEW_BOOKING') {
        if (isAdmin) {
          if (Get.isRegistered<AdminDashboardViewmodel>(tag: 'adminDashboard')) {
            Get.find<AdminDashboardViewmodel>(tag: 'adminDashboard').switchTab(5);
          }
          Get.to(() => const AdminDashboardScreen(initialIndex: 5));
        } else {
          Get.to(() => const HistoryScreen());
        }
      } else if (message.data['type'] == 'DEPARTURE_ALERT' ||
          message.data['type'] == 'BOOKING_CONFIRMED' ||
          message.data['type'] == 'BOOKING') {
        Get.to(() => const HistoryScreen());
      } else {
        Get.offAll(() => const MainApp());
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Navigation error on notification tap: $e');
    }
  }
}
