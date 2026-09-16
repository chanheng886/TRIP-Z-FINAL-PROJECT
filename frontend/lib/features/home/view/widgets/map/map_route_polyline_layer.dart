import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Renders the road route polyline connecting the user location to the
/// selected bus station. Falls back to a straight line if no road route exists.
class MapRoutePolylineLayer extends StatelessWidget {
  final List<LatLng> roadRoutePoints;
  final LatLng userPos;
  final LatLng destPos;

  const MapRoutePolylineLayer({
    super.key,
    required this.roadRoutePoints,
    required this.userPos,
    required this.destPos,
  });

  @override
  Widget build(BuildContext context) {
    final points = roadRoutePoints.isNotEmpty
        ? roadRoutePoints
        : [userPos, destPos];

    return PolylineLayer(
      polylines: [
        // Outer glow / casing for contrast
        Polyline(
          points: points,
          color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
          strokeWidth: 7.0,
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.round,
        ),
        // Core navigation line
        Polyline(
          points: points,
          color: const Color(0xFF2563EB),
          strokeWidth: 4.5,
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.round,
        ),
      ],
    );
  }
}
