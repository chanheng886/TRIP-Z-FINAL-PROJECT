import 'package:frontend/features/admin/models/bus.dart';
import 'package:frontend/features/admin/models/bus_route.dart';
import 'package:frontend/features/admin/models/bus_type.dart';
import 'package:frontend/features/admin/models/company.dart';
import 'package:frontend/features/admin/services/admin_dashboard_service.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/features/home/models/bus_location.dart';
import 'package:frontend/features/home/models/bus_schedule.dart';

class AdminDashboardRepository {
  final AdminDashboardService service;
  AdminDashboardRepository(this.service);

  Future<List<BusLocation>> fetchLocations() async {
    final data = await service.getLocations();
    return data
        .map((json) => BusLocation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Company>> fetchCompanies() async {
    final data = await service.getCompanies();
    return data
        .map((json) => Company.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Bus>> fetchBuses() async {
    final data = await service.getBuses();
    return data.map((json) => Bus.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<BusRoute>> fetchRoutes() async {
    final data = await service.getRoutes();
    return data
        .map((json) => BusRoute.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<BusType>> fetchBusTypes() async {
    final data = await service.getBusTypes();
    return data
        .map((json) => BusType.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<BusSchedule>> fetchSchedules() async {
    final data = await service.getSchedules();
    return data
        .map((json) => BusSchedule.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookingResponse>> fetchBookings() async {
    final data = await service.getBookings();
    return data
        .map((json) => BookingResponse.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> createLocation({
    required String locationName,
    required String imageUrl,
  }) {
    return service.createLocation(
      locationName: locationName,
      imageUrl: imageUrl,
    );
  }

  Future<Map<String, dynamic>> createCompany({
    required String companyName,
    required String imageUrl,
  }) {
    return service.createCompany(
      companyName: companyName,
      imageUrl: imageUrl,
    );
  }

  Future<Map<String, dynamic>> createBusType({
    required String busType,
  }) {
    return service.createBusType(busType: busType);
  }

  Future<Map<String, dynamic>> createBus({
    required String companyName,
    required String busType,
    required int seatCapacity,
    required String plateNumber,
    required String imageUrl,
  }) {
    return service.createBus(
      companyName: companyName,
      busType: busType,
      seatCapacity: seatCapacity,
      plateNumber: plateNumber,
      imageUrl: imageUrl,
    );
  }

  Future<Map<String, dynamic>> createRoute({
    required String fromLocation,
    required String toLocation,
  }) {
    return service.createRoute(
      fromLocation: fromLocation,
      toLocation: toLocation,
    );
  }

  Future<Map<String, dynamic>> createBusSchedule({
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
    return service.createBusSchedule(
      busId: busId,
      routeId: routeId,
      travelDate: travelDate,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      availableSeat: availableSeat,
      status: status,
      basePrice: basePrice,
      busTypeId: busTypeId,
    );
  }
}
