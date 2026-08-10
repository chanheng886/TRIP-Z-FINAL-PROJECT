import 'package:frontend/features/home/models/bus_schedule.dart';
import 'package:frontend/shared/services/bus_schedule_serivice.dart';

class BusScheduleRepository {
  final BusScheduleService busScheduleService;

  BusScheduleRepository(this.busScheduleService);

  Future<List<BusSchedule>> searchBusSchedules({
    required int fromLocationId,
    required int toLocationId,
    required DateTime travelDate,
  }) async {
    final rawList = await busScheduleService.searchBusSchedules(
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      travelDate: travelDate,
    );

    return rawList
        .map((json) => BusSchedule.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
