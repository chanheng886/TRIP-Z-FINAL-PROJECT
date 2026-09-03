import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/data/bus_station_repository.dart';
import 'package:frontend/features/home/view/pages/bus_stations_map_screen.dart';
import 'package:frontend/features/home/view/widgets/bus_station_detail_bottom_sheet.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class PickupLocationCard extends StatefulWidget {
  final VoidCallback? onTap;
  final void Function(BusStation station)? onStationSelected;

  const PickupLocationCard({
    super.key,
    this.onTap,
    this.onStationSelected,
  });

  @override
  State<PickupLocationCard> createState() => _PickupLocationCardState();
}

class _PickupLocationCardState extends State<PickupLocationCard> {
  final BusStationRepository _repository = BusStationRepository();
  late List<BusStation> _stations;
  final MapController _mapController = MapController();
  late final UserLocationService _userLocService;

  late final Worker _posWorker;

  @override
  void initState() {
    super.initState();
    _userLocService = Get.isRegistered<UserLocationService>()
        ? Get.find<UserLocationService>()
        : Get.put(UserLocationService());
    _stations = _repository.getAllStations();

    _posWorker = ever(_userLocService.currentPosition, (pos) {
      if (pos != null && mounted) {
        _mapController.move(
          LatLng(pos.latitude, pos.longitude),
          14.5,
        );
      }
    });
  }

  @override
  void dispose() {
    _posWorker.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _openFullMap() async {
    final result = await Get.to<BusStation>(
      () => const BusStationsMapScreen(),
    );
    if (result != null && widget.onStationSelected != null) {
      widget.onStationSelected!(result);
    }
  }

  void _recenterToUser() {
    final userPos = _userLocService.userLatLng;
    _mapController.move(userPos, 14.5);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDarkMode ? AppColors.darkCardBackground : Colors.white;
    final borderColor = isDarkMode
        ? const Color(0xFF2C313C)
        : const Color(0xFFE5E7EB);
    final textPrimary = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final textSecondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Obx(() {
      final userPos = _userLocService.userLatLng;
      final nearest = _userLocService.nearestStation.value ?? _stations.first;
      final distanceKm = _userLocService.distanceToNearestKm.value;
      final isLoading = _userLocService.isLoadingLocation.value;

      final nearestLatLng = LatLng(nearest.latitude, nearest.longitude);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & View All Action
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Pick up location'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: _openFullMap,
                  child: Row(
                    children: [
                      Text(
                        'view_all'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF22C55E),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Nearest Station Distance Banner
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.near_me_rounded,
                  size: 14,
                  color: Color(0xFF22C55E),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Nearest: ${nearest.name} ($distanceKm km away)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Real Interactive Map Card
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Stack(
                children: [
                  // 1. Real Slippy Map Tile Layer
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: userPos,
                      initialZoom: 13.8,
                      minZoom: 8.0,
                      maxZoom: 18.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.drag |
                            InteractiveFlag.pinchZoom |
                            InteractiveFlag.doubleTapZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.tripz.frontend',
                      ),

                      // Polyline Route from User to Nearest Station
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [userPos, nearestLatLng],
                            color: const Color(0xFF2563EB),
                            strokeWidth: 4.0,
                            strokeCap: StrokeCap.round,
                            strokeJoin: StrokeJoin.round,
                          ),
                        ],
                      ),

                      // Markers Layer: User GPS Marker + Bus Station Markers
                      MarkerLayer(
                        markers: [
                          // User Location Marker (Blue Ring with Pulse)
                          Marker(
                            point: userPos,
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bus Station Markers
                          ..._stations.map((station) {
                            final isNearest = station.id == nearest.id;
                            return Marker(
                              point: LatLng(
                                station.latitude,
                                station.longitude,
                              ),
                              width: isNearest ? 48 : 38,
                              height: isNearest ? 48 : 38,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  BusStationDetailBottomSheet.show(
                                    context,
                                    station: station,
                                    onSelectAsOrigin: (st) {
                                      if (widget.onStationSelected != null) {
                                        widget.onStationSelected!(st);
                                      }
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(isNearest ? 6 : 4),
                                  decoration: BoxDecoration(
                                    color: isNearest
                                        ? const Color(0xFF22C55E)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isNearest
                                          ? Colors.white
                                          : const Color(0xFF22C55E),
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isNearest
                                            ? const Color(0xFF22C55E)
                                                .withValues(alpha: 0.4)
                                            : Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.bus,
                                      size: isNearest ? 16 : 13,
                                      color: isNearest
                                          ? Colors.white
                                          : const Color(0xFF22C55E),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),

                  // 2. Bottom-Left "Tracking 📍" Pill Badge
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onStationSelected != null) {
                          widget.onStationSelected!(nearest);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF22C55E).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'tracking'.tr,
                              style: AppFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Top-Right Buttons (Locate Me + Fullscreen)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Locate Me GPS Button
                        GestureDetector(
                          onTap: () async {
                            await _userLocService.determinePosition(
                              showErrors: true,
                            );
                            _recenterToUser();
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cardBg.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.my_location_rounded,
                                size: 16,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Fullscreen / Stations Explorer
                        GestureDetector(
                          onTap: _openFullMap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fullscreen_rounded,
                                  size: 16,
                                  color: Color(0xFF22C55E),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stations',
                                  style: AppFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
