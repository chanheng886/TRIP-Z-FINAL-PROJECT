import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:get/get.dart';

/// Full-screen overlay list panel showing all filtered bus stations.
/// Appears when the user toggles the list view mode.
class MapStationListView extends StatelessWidget {
  final List<BusStation> stations;
  final BusStation? selectedStation;
  final String selectedCity;
  final bool isKhmer;
  final UserLocationService userLocService;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final void Function(BusStation station) onStationTap;

  const MapStationListView({
    super.key,
    required this.stations,
    required this.selectedStation,
    required this.selectedCity,
    required this.isKhmer,
    required this.userLocService,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      top: 150,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${stations.length} Bus Stations',
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    selectedCity,
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: stations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final station = stations[index];
                  final isSelected = selectedStation?.id == station.id;
                  final distanceKm =
                      userLocService.calculateDistanceToStationKm(station);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFDCFCE7),
                      child: FaIcon(
                        FontAwesomeIcons.bus,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF22C55E),
                      ),
                    ),
                    title: Text(
                      station.localizedName(isKhmer),
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.localizedAddress(isKhmer),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.dmSans(
                              fontSize: 12, color: textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$distanceKm km away',
                          style: AppFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () => Get.back(result: station),
                      child: Text(
                        'Select',
                        style: AppFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                    ),
                    onTap: () => onStationTap(station),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
