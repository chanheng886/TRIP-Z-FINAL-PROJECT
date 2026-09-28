import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/model/bus.dart';
import 'package:frontend/features/admin/model/bus_route.dart';
import 'package:frontend/features/admin/model/bus_type.dart';
import 'package:frontend/features/admin/model/company.dart';
import 'package:frontend/features/admin/repository/admin_dashboard_repository.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/shared/model/bus_location.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';

class AdminDashboardViewmodel extends GetxController {
  final AdminDashboardRepository repository;
  AdminDashboardViewmodel(this.repository);

  final RxBool isLoadingOptions = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = "".obs;
  final RxString successMessage = "".obs;
  final RxString bookingError = "".obs;

  final RxList<BusLocation> locations = <BusLocation>[].obs;
  final RxList<Company> companies = <Company>[].obs;
  final RxList<Bus> buses = <Bus>[].obs;
  final RxList<BusRoute> routes = <BusRoute>[].obs;
  final RxList<BusType> busTypes = <BusType>[].obs;
  final RxList<BusSchedule> schedules = <BusSchedule>[].obs;
  final RxList<BookingResponse> bookings = <BookingResponse>[].obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  Timer? _pollTimer;
  int _lastKnownMaxBookingId = 0;

  @override
  void onInit() {
    super.onInit();
    loadOptions();
    _startBookingPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void _startBookingPolling() {
    _pollTimer?.cancel();
    // Poll every 12 seconds when viewing all bookings
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      if (selectedDate.value == null && !isLoadingOptions.value) {
        await refreshBookingsSilently();
      }
    });
  }

  Future<void> refreshBookingsSilently() async {
    try {
      final freshBookings = await repository.fetchBookings();
      freshBookings.sort((a, b) => b.id.compareTo(a.id));

      if (_lastKnownMaxBookingId > 0 && freshBookings.isNotEmpty) {
        final newBookings =
            freshBookings.where((b) => b.id > _lastKnownMaxBookingId).toList();
        if (newBookings.isNotEmpty) {
          final latest = newBookings.first;
          _triggerNewBookingAlert(latest, count: newBookings.length);
        }
      }

      if (freshBookings.isNotEmpty) {
        _lastKnownMaxBookingId = freshBookings
            .map((b) => b.id)
            .reduce((max, id) => id > max ? id : max);
      }

      bookings.value = freshBookings;
    } catch (_) {}
  }

  void _triggerNewBookingAlert(BookingResponse latest, {int count = 1}) {
    Get.snackbar(
      'New Booking Alert! 🎟️',
      count > 1
          ? '$count new bookings received! Latest from ${latest.username} (\$${latest.totalAmount.toStringAsFixed(2)})'
          : 'New booking #${latest.id} from ${latest.username}: ${latest.fromLocation} → ${latest.toLocation} (\$${latest.totalAmount.toStringAsFixed(2)})',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      icon: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const FaIcon(
          FontAwesomeIcons.ticket,
          color: AppColors.green,
          size: 18,
        ),
      ),
      duration: const Duration(seconds: 7),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
    );
  }

  Future<void> loadOptions() async {
    isLoadingOptions.value = true;
    errorMessage.value = "";
    bookingError.value = "";

    final errors = <String>[];

    await Future.wait([
      _safeLoad(() => repository.fetchLocations(), (v) => locations.value = v, 'locations', errors),
      _safeLoad(() => repository.fetchCompanies(), (v) => companies.value = v, 'companies', errors),
      _safeLoad(() => repository.fetchBuses(), (v) => buses.value = v, 'buses', errors),
      _safeLoad(() => repository.fetchRoutes(), (v) {
        final seen = <String>{};
        final unique = <BusRoute>[];
        for (final r in v) {
          final key =
              '${r.fromLocation.trim().toLowerCase()}->${r.toLocation.trim().toLowerCase()}';
          if (seen.add(key)) {
            unique.add(r);
          }
        }
        routes.value = unique;
      }, 'routes', errors),
      _safeLoad(() => repository.fetchBusTypes(), (v) => busTypes.value = v, 'bus types', errors),
      _safeLoad(() => repository.fetchSchedules(), (v) => schedules.value = v, 'schedules', errors),
      _safeLoadBooking(() => repository.fetchBookings(), (v) => bookings.value = v),
    ]);

    if (errors.isNotEmpty) {
      errorMessage.value = 'Failed to load: ${errors.join(', ')}';
    }

    isLoadingOptions.value = false;
  }

  Future<void> _safeLoadBooking(
    Future<List<BookingResponse>> Function() fetch,
    void Function(List<BookingResponse>) assign,
  ) async {
    try {
      final data = await fetch();
      data.sort((a, b) => b.id.compareTo(a.id));
      if (data.isNotEmpty) {
        _lastKnownMaxBookingId =
            data.map((b) => b.id).reduce((max, id) => id > max ? id : max);
      }
      assign(data);
    } catch (e) {
      bookingError.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> _safeLoad<T>(
    Future<List<T>> Function() fetch,
    void Function(List<T>) assign,
    String label,
    List<String> errors,
  ) async {
    try {
      final data = await fetch();
      assign(data);
    } catch (e) {
      errors.add(label);
    }
  }

  final RxBool isUploadingImage = false.obs;

  Future<String?> uploadImage({
    required List<int> bytes,
    required String filename,
    String folder = 'tripz/locations',
  }) async {
    isUploadingImage.value = true;
    errorMessage.value = '';
    try {
      final url = await repository.uploadImage(
        bytes: bytes,
        filename: filename,
        folder: folder,
      );
      return url;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<bool> createLocation({
    required String locationName,
    required String imageUrl,
  }) {
    return _run(() => repository.createLocation(
          locationName: locationName,
          imageUrl: imageUrl,
        ));
  }

  Future<bool> createCompany({
    required String companyName,
    required String imageUrl,
  }) {
    return _run(() => repository.createCompany(
          companyName: companyName,
          imageUrl: imageUrl,
        ));
  }

  Future<bool> createBusType({
    required String busType,
  }) {
    return _run(() => repository.createBusType(busType: busType));
  }

  Future<bool> createBus({
    required String companyName,
    required String busType,
    required int seatCapacity,
    required String plateNumber,
    required String imageUrl,
  }) {
    return _run(() => repository.createBus(
          companyName: companyName,
          busType: busType,
          seatCapacity: seatCapacity,
          plateNumber: plateNumber,
          imageUrl: imageUrl,
        ));
  }

  Future<bool> createRoute({
    required String fromLocation,
    required String toLocation,
  }) {
    return _run(() => repository.createRoute(
          fromLocation: fromLocation,
          toLocation: toLocation,
        ));
  }

  Future<bool> createBusSchedule({
    required int busId,
    required int routeId,
    required String travelDate,
    required String departureTime,
    required String arrivalTime,
    required int availableSeat,
    required String status,
    required double basePrice,
    required int busTypeId,
  }) {
    return _run(() => repository.createBusSchedule(
          busId: busId,
          routeId: routeId,
          travelDate: travelDate,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
          availableSeat: availableSeat,
          status: status,
          basePrice: basePrice,
          busTypeId: busTypeId,
        ));
  }

  Future<bool> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    isSubmitting.value = true;
    errorMessage.value = "";
    try {
      final result = await repository.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
      final updated = BookingResponse.fromJson(result);
      final index = bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        bookings[index] = updated;
      }
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> loadBookingsByDate(DateTime date) async {
    selectedDate.value = date;
    isSubmitting.value = true;
    bookingError.value = "";
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final result = await repository.fetchBookingsByDate(dateStr);
      bookings.value = result;
    } catch (e) {
      bookingError.value = e.toString().replaceFirst('Exception: ', '');
      bookings.clear();
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> clearDateFilter() async {
    selectedDate.value = null;
    await loadOptions();
  }

  Future<bool> _run(Future<Map<String, dynamic>> Function() action) async {
    isSubmitting.value = true;
    errorMessage.value = "";
    successMessage.value = "";
    try {
      await action();
      successMessage.value = "Saved successfully!";
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
