import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/features/admin/view/admin_dashboard_screen.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/history/view/history_screen.dart';
import 'package:frontend/features/notifications/model/app_notification.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find<NotificationController>();

  static const String _storageKey = 'tripz_notifications_list_v1';

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxString selectedFilter = 'all'.obs;

  bool get _isAdmin {
    final authVM =
        Get.isRegistered<AuthViewmodel>() ? Get.find<AuthViewmodel>() : null;
    return authVM?.currentUser?.role == UserRole.Admin;
  }

  int get unreadCount => notifications
      .where((n) => !n.isRead && (_isAdmin || n.type != 'ADMIN_NEW_BOOKING'))
      .length;

  List<AppNotification> get filteredNotifications {
    final visibleList = _isAdmin
        ? notifications
        : notifications.where((n) => n.type != 'ADMIN_NEW_BOOKING').toList();

    final filter = selectedFilter.value;
    if (filter == 'unread') {
      return visibleList.where((n) => !n.isRead).toList();
    } else if (filter == 'bookings') {
      return visibleList
          .where((n) =>
              n.type == 'ADMIN_NEW_BOOKING' ||
              n.type == 'BOOKING_CONFIRMED' ||
              n.type == 'BOOKING')
          .toList();
    } else if (filter == 'trips') {
      return visibleList.where((n) => n.type == 'DEPARTURE_ALERT').toList();
    }
    return visibleList.toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        notifications.assignAll(
          decoded
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      } else {
        // Seed default initial notifications so screen has context immediately
        _seedInitialNotifications();
      }
    } catch (e) {
      debugPrint('⚠️ [NotificationController] Error loading notifications: $e');
    }
  }

  void _seedInitialNotifications() {
    final now = DateTime.now();
    notifications.assignAll([
      AppNotification(
        id: 'welcome_1',
        title: 'Welcome to Trip-Z! 🚌',
        body: 'Book buses across Cambodia seamlessly with real-time departure reminders.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        type: 'SYSTEM',
      ),
      AppNotification(
        id: 'safety_tip_1',
        title: 'Boarding Guidelines 🧳',
        body: 'Arrive at the terminal at least 20 minutes before departure for smooth luggage check-in.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
        type: 'SYSTEM',
      ),
    ]);
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('⚠️ [NotificationController] Error saving notifications: $e');
    }
  }

  void addNotification({
    required String title,
    required String body,
    String type = 'SYSTEM',
    Map<String, dynamic> data = const {},
  }) {
    // Drop admin-only notifications if current user is not Admin
    if (type == 'ADMIN_NEW_BOOKING' && !_isAdmin) {
      debugPrint('🛡️ [NotificationController] Dropped admin notification for non-admin user.');
      return;
    }

    final item = AppNotification(
      id: '${DateTime.now().millisecondsSinceEpoch}_${notifications.length}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: type,
      data: data,
    );

    // Insert at top so newest is first
    notifications.insert(0, item);
    _saveToStorage();
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
      _saveToStorage();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    notifications.refresh();
    _saveToStorage();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _saveToStorage();
  }

  void clearAll() {
    notifications.clear();
    _saveToStorage();
  }

  void handleNotificationTap(BuildContext context, AppNotification notification) {
    markAsRead(notification.id);

    if (notification.type == 'ADMIN_NEW_BOOKING') {
      if (_isAdmin) {
        if (Get.isRegistered<AdminDashboardViewmodel>(tag: 'adminDashboard')) {
          Get.find<AdminDashboardViewmodel>(tag: 'adminDashboard').switchTab(5);
        }
        Get.to(() => const AdminDashboardScreen(initialIndex: 5));
      } else {
        Get.to(() => const HistoryScreen());
      }
    } else {
      Get.to(() => const HistoryScreen());
    }
  }
}
