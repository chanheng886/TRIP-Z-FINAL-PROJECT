import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/home/view/widgets/bus_station_detail_bottom_sheet.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

/// Builds a [Marker] for a single bus station on the map.
/// Highlights the currently selected station with a larger green circle.
class MapStationMarker extends Marker {
  MapStationMarker({
    required BusStation station,
    required bool isSelected,
    required VoidCallback onSelectStation,
    required BuildContext context,
  }) : super(
          point: LatLng(station.latitude, station.longitude),
          width: isSelected ? 58 : 44,
          height: isSelected ? 58 : 44,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              onSelectStation();
              BusStationDetailBottomSheet.show(
                context,
                station: station,
                onSelectAsOrigin: (st) => Get.back(result: st),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.all(isSelected ? 6 : 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF22C55E) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : const Color(0xFF22C55E),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.bus,
                  size: isSelected ? 20 : 16,
                  color: isSelected ? Colors.white : const Color(0xFF22C55E),
                ),
              ),
            ),
          ),
        );
}
