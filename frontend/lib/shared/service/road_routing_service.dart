import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final double durationMinutes;
  final bool isRoadTracked;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    required this.isRoadTracked,
  });
}

class RoadRoutingService {
  static final RoadRoutingService _instance = RoadRoutingService._internal();
  factory RoadRoutingService() => _instance;
  RoadRoutingService._internal();

  // In-memory cache for road route coordinates
  final Map<String, RouteResult> _cache = {};

  String _cacheKey(LatLng start, LatLng dest) {
    return '${start.latitude.toStringAsFixed(4)},${start.longitude.toStringAsFixed(4)}->${dest.latitude.toStringAsFixed(4)},${dest.longitude.toStringAsFixed(4)}';
  }

  /// Fetches real road-network polyline points from [start] to [destination].
  /// Falls back to a direct straight line [start, destination] if the network is unavailable.
  Future<RouteResult> getRoadRoute(LatLng start, LatLng destination) async {
    final key = _cacheKey(start, destination);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    try {
      // OSRM Public Driving Routing API (GeoJSON format)
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0] as Map<String, dynamic>;
          final geometry = route['geometry'] as Map<String, dynamic>;
          final coordinates = geometry['coordinates'] as List;

          final List<LatLng> roadPoints = [];
          for (final coord in coordinates) {
            if (coord is List && coord.length >= 2) {
              final lng = (coord[0] as num).toDouble();
              final lat = (coord[1] as num).toDouble();
              roadPoints.add(LatLng(lat, lng));
            }
          }

          if (roadPoints.isNotEmpty) {
            final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
            final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;

            final result = RouteResult(
              points: roadPoints,
              distanceKm: double.parse((distanceMeters / 1000.0).toStringAsFixed(1)),
              durationMinutes: double.parse((durationSeconds / 60.0).toStringAsFixed(0)),
              isRoadTracked: true,
            );

            _cache[key] = result;
            return result;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ RoadRoutingService error: $e. Falling back to direct line.');
    }

    // Fallback: direct connection
    final fallback = RouteResult(
      points: [start, destination],
      distanceKm: 0.0,
      durationMinutes: 0.0,
      isRoadTracked: false,
    );
    return fallback;
  }
}
