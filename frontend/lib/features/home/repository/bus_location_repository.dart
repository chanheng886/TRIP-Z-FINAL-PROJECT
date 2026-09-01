import 'package:frontend/shared/model/bus_location.dart';
import 'package:frontend/shared/service/bus_location_service.dart';

class BusLocationRepository {
  final BusLocationService busLocationService;
  BusLocationRepository(this.busLocationService);

  Future<List<BusLocation>> fetchLocation() async {
    final data = await busLocationService.getLocations();
    return data.map((json) => BusLocation.fromJson(json)).toList();
  }
}
