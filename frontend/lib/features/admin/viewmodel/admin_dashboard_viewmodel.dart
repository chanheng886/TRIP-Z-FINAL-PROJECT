import 'package:frontend/features/admin/models/bus.dart';
import 'package:frontend/features/admin/models/bus_route.dart';
import 'package:frontend/features/admin/models/bus_type.dart';
import 'package:frontend/features/admin/models/company.dart';
import 'package:frontend/features/admin/repository/admin_dashboard_repository.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/features/home/models/bus_location.dart';
import 'package:frontend/features/home/models/bus_schedule.dart';
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

  @override
  void onInit() {
    super.onInit();
    loadOptions();
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
      _safeLoad(() => repository.fetchRoutes(), (v) => routes.value = v, 'routes', errors),
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
