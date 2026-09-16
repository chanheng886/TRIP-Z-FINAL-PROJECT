import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/view/widgets/bus_station_detail_bottom_sheet.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:get/get.dart';

/// Bottom horizontal scrolling card carousel showing filtered bus stations.
/// Each card shows station info and a Select button.
class MapStationCarousel extends StatelessWidget {
  final List<BusStation> stations;
  final BusStation? selectedStation;
  final bool isKhmer;
  final UserLocationService userLocService;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final void Function(BusStation station) onStationTap;

  const MapStationCarousel({
    super.key,
    required this.stations,
    required this.selectedStation,
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
      left: 0,
      right: 0,
      bottom: 24,
      child: SizedBox(
        height: 185,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            final isSelected = selectedStation?.id == station.id;
            final distanceKm =
                userLocService.calculateDistanceToStationKm(station);

            return GestureDetector(
              onTap: () {
                onStationTap(station);
                BusStationDetailBottomSheet.show(
                  context,
                  station: station,
                  onSelectAsOrigin: (st) => Get.back(result: st),
                );
              },
              child: Container(
                width: 310,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF22C55E)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF22C55E).withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Station Header Row
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: FaIcon(
                              FontAwesomeIcons.busSimple,
                              size: 18,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.localizedName(isKhmer),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    station.city,
                                    style: AppFonts.dmSans(
                                      fontSize: 12,
                                      color: const Color(0xFF22C55E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: textSecondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$distanceKm km away',
                                    style: AppFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Address
                    Text(
                      station.localizedAddress(isKhmer),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.dmSans(
                          fontSize: 12, color: textSecondary),
                    ),
                    const Spacer(),

                    // Footer: Opening Hours + Select Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: Color(0xFF22C55E)),
                            const SizedBox(width: 4),
                            Text(
                              station.openingHours,
                              style: AppFonts.dmSans(
                                  fontSize: 11, color: textSecondary),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () => Get.back(result: station),
                          child: Text(
                            'Select',
                            style: AppFonts.dmSans(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
