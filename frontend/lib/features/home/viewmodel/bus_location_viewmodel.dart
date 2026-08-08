import 'package:frontend/features/home/models/bus_location.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:get/get.dart';

class BusLocationViewmodel extends GetxController {
  final BusLocationRepository repository;
  BusLocationViewmodel(this.repository);
  var locations = <BusLocation>[].obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;

  var searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadLocations();
  }

  void loadLocations() async {
    isLoading.value = true;
    errorMessage.value = "";
    try {
      locations.value = await repository.fetchLocation();
    } catch (e) {
      errorMessage.value = "Failed to bus lcoation";
    } finally {
      isLoading.value = false;
    }
  }

  List<BusLocation> get filteredLocations {
    if (searchQuery.value.isEmpty) {
      return locations;
    }
    return locations
        .where(
          (loc) => loc.locationName.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }
}
