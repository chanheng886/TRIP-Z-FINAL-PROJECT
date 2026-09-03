import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/features/home/data/bus_station_repository.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class UserLocationService extends GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final Rx<BusStation?> nearestStation = Rx<BusStation?>(null);
  final RxDouble distanceToNearestKm = 0.0.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxString locationStatus = "Locating...".obs;
  final RxBool hasGpsFix = false.obs;
  final RxString detectedCityName = "".obs;

  StreamSubscription<Position>? _positionStreamSub;
  final BusStationRepository _stationRepo = BusStationRepository();

  LatLng get userLatLng {
    if (currentPosition.value != null) {
      return LatLng(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
      );
    }
    // Default fallback to Phnom Penh Central
    return const LatLng(11.5564, 104.9282);
  }

  @override
  void onInit() {
    super.onInit();
    // Delay slightly to ensure Activity is fully rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      determinePosition();
    });
  }

  @override
  void onClose() {
    _positionStreamSub?.cancel();
    super.onClose();
  }

  void startLocationStream() {
    _positionStreamSub?.cancel();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    try {
      _positionStreamSub =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              debugPrint(
                "📍 GPS Live Stream: Lat=${position.latitude}, Lng=${position.longitude}",
              );
              currentPosition.value = position;
              hasGpsFix.value = true;
              _calculateNearestStation(position.latitude, position.longitude);
              locationStatus.value = "GPS Live";
            },
            onError: (e) {
              debugPrint("Location stream error: $e");
            },
          );
    } catch (e) {
      debugPrint("Failed to start location stream: $e");
    }
  }

  Future<Position?> determinePosition({bool showErrors = false}) async {
    isLoadingLocation.value = true;
    locationStatus.value = "Detecting GPS...";

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationStatus.value = "GPS turned off";
        _findNearestToDefault();
        if (showErrors) {
          Get.snackbar(
            "Location Service Disabled",
            "Please turn on Location / GPS in your device settings",
            snackPosition: SnackPosition.BOTTOM,
            mainButton: TextButton(
              onPressed: () => Geolocator.openLocationSettings(),
              child: const Text("SETTINGS"),
            ),
          );
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationStatus.value = "Permission denied";
          _findNearestToDefault();
          if (showErrors) {
            Get.snackbar(
              "Permission Denied",
              "Location permission is needed to find stations near you",
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationStatus.value = "Permission blocked";
        _findNearestToDefault();
        if (showErrors) {
          Get.snackbar(
            "Permission Required",
            "Please grant Location permission in App Settings",
            snackPosition: SnackPosition.BOTTOM,
            mainButton: TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text("SETTINGS"),
            ),
          );
        }
        return null;
      }

      // Start live stream
      startLocationStream();

      // Quick last known position
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        currentPosition.value = lastKnown;
        hasGpsFix.value = true;
        _calculateNearestStation(lastKnown.latitude, lastKnown.longitude);
      }

      // Fresh accurate GPS fix
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint(
        "📍 GPS Locked: Lat=${position.latitude}, Lng=${position.longitude}",
      );
      currentPosition.value = position;
      hasGpsFix.value = true;
      _calculateNearestStation(position.latitude, position.longitude);
      locationStatus.value = "GPS Ready";
      return position;
    } catch (e) {
      debugPrint("determinePosition catch: $e");
      if (currentPosition.value == null) {
        _findNearestToDefault();
      }
      return currentPosition.value;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  void _findNearestToDefault() {
    _calculateNearestStation(11.5564, 104.9282);
  }

  void _calculateNearestStation(double userLat, double userLng) {
    final stations = _stationRepo.getAllStations();
    if (stations.isEmpty) return;

    BusStation? closest;
    double minDistanceMeters = double.infinity;

    for (final station in stations) {
      final distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        station.latitude,
        station.longitude,
      );
      if (distance < minDistanceMeters) {
        minDistanceMeters = distance;
        closest = station;
      }
    }

    if (closest != null) {
      nearestStation.value = closest;
      detectedCityName.value = closest.city;
      distanceToNearestKm.value = double.parse(
        (minDistanceMeters / 1000.0).toStringAsFixed(1),
      );
    }
  }

  double calculateDistanceToStationKm(BusStation station) {
    final userPos = userLatLng;
    final meters = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      station.latitude,
      station.longitude,
    );
    return double.parse((meters / 1000.0).toStringAsFixed(1));
  }
}
