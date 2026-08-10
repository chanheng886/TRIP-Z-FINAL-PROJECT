import 'package:frontend/features/home/models/bus_schedule.dart';
import 'package:frontend/features/home/repository/bus_schedule_repository.dart';
import 'package:get/get.dart';

class BusScheduleViewmodel extends GetxController {
  final BusScheduleRepository busScheduleRepository;
  BusScheduleViewmodel(this.busScheduleRepository);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = "".obs;
  final RxList<BusSchedule> schedules = <BusSchedule>[].obs;

  Future<void> searchBusSchedule({
    required int fromLocationId,
    required int toLocationId,
    required DateTime travelDate,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final result = await busScheduleRepository.searchBusSchedules(
        fromLocationId: fromLocationId,
        toLocationId: toLocationId,
        travelDate: travelDate,
      );
      schedules.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
