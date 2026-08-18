import 'package:frontend/features/admin/models/bus.dart';
import 'package:frontend/features/admin/models/bus_route.dart';
import 'package:frontend/features/admin/repository/admin_dashboard_repository.dart';
import 'package:frontend/features/admin/services/admin_dashboard_service.dart';
import 'package:frontend/features/auth/models/user.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/features/home/models/bus_schedule.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:get/get.dart';

class BookingHistoryViewmodel extends GetxController {
  final BookingRepository bookingRepository;

  BookingHistoryViewmodel(this.bookingRepository);

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Customer data
  final RxList<BookingResponse> bookings = <BookingResponse>[].obs;

  // Admin data
  final RxList<Bus> buses = <Bus>[].obs;
  final RxList<BusRoute> routes = <BusRoute>[].obs;
  final RxList<BusSchedule> schedules = <BusSchedule>[].obs;

  bool get isAdmin {
    final authVM = Get.find<AuthViewmodel>();
    return authVM.currentUser?.role == UserRole.Admin;
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final authVM = Get.find<AuthViewmodel>();
      final userId = authVM.currentUser?.id;
      if (userId == null) {
        error.value = 'Please login first';
        return;
      }

      if (isAdmin) {
        await _loadAdminData();
      } else {
        await _loadCustomerBookings(userId);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAdminData() async {
    final repository = AdminDashboardRepository(AdminDashboardService());
    final results = await Future.wait([
      repository.fetchBuses(),
      repository.fetchRoutes(),
      repository.fetchSchedules(),
    ]);
    buses.assignAll(results[0] as List<Bus>);
    routes.assignAll(results[1] as List<BusRoute>);
    schedules.assignAll(results[2] as List<BusSchedule>);
  }

  Future<void> _loadCustomerBookings(int userId) async {
    final result = await bookingRepository.getUserBookings(userId);
    bookings.assignAll(result);
  }

  // Keep backward compat
  Future<void> loadBookings() => loadData();
}
