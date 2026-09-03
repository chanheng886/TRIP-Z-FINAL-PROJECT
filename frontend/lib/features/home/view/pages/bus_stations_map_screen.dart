import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/data/bus_station_repository.dart';
import 'package:frontend/features/home/view/widgets/bus_station_detail_bottom_sheet.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class BusStationsMapScreen extends StatefulWidget {
  final BusStation? initialStation;
  final String? initialCity;

  const BusStationsMapScreen({
    super.key,
    this.initialStation,
    this.initialCity,
  });

  @override
  State<BusStationsMapScreen> createState() => _BusStationsMapScreenState();
}

class _BusStationsMapScreenState extends State<BusStationsMapScreen> {
  final BusStationRepository _repository = BusStationRepository();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late final UserLocationService _userLocService;
  late List<BusStation> _allStations;
  late List<BusStation> _filteredStations;
  late List<String> _cities;

  String _selectedCity = 'All';
  BusStation? _selectedStation;
  bool _showListView = false;
  Worker? _posWorker;

  @override
  void initState() {
    super.initState();
    _userLocService = Get.isRegistered<UserLocationService>()
        ? Get.find<UserLocationService>()
        : Get.put(UserLocationService());

    _allStations = _repository.getAllStations();
    _cities = _repository.getAvailableCities();

    if (widget.initialCity != null && widget.initialCity!.isNotEmpty) {
      _selectedCity = widget.initialCity!;
    }
    _selectedStation =
        widget.initialStation ??
        _userLocService.nearestStation.value ??
        _allStations.first;
    _filterStations();

    if (widget.initialStation == null) {
      _posWorker = ever(_userLocService.currentPosition, (pos) {
        if (pos != null && mounted) {
          final nearest = _userLocService.nearestStation.value;
          if (nearest != null) {
            setState(() {
              _selectedStation = nearest;
            });
          }
        }
      });
    }
  }

  void _filterStations() {
    setState(() {
      var list = _repository.getStationsByCity(_selectedCity);
      if (_searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.trim().toLowerCase();
        list = list.where((s) {
          return s.name.toLowerCase().contains(query) ||
              s.nameKh.toLowerCase().contains(query) ||
              s.address.toLowerCase().contains(query) ||
              s.operators.any((op) => op.toLowerCase().contains(query));
        }).toList();
      }
      _filteredStations = list;
    });
  }

  void _selectStation(BusStation station, {bool moveMap = true}) {
    setState(() {
      _selectedStation = station;
    });
    if (moveMap) {
      _mapController.move(LatLng(station.latitude, station.longitude), 15.5);
    }
  }

  void _onCityChanged(String city) {
    setState(() {
      _selectedCity = city;
      _filterStations();
    });

    if (_filteredStations.isNotEmpty) {
      _selectStation(_filteredStations.first);
    } else if (city == 'Phnom Penh') {
      _mapController.move(const LatLng(11.5564, 104.9282), 13.0);
    } else if (city == 'Siem Reap') {
      _mapController.move(const LatLng(13.3633, 103.8564), 13.0);
    } else if (city == 'Sihanoukville') {
      _mapController.move(const LatLng(10.6259, 103.5234), 13.0);
    } else if (city == 'Battambang') {
      _mapController.move(const LatLng(13.0957, 103.2022), 13.0);
    } else if (city == 'Kampot') {
      _mapController.move(const LatLng(10.6105, 104.1812), 13.0);
    }
  }

  @override
  void dispose() {
    _posWorker?.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDarkMode ? AppColors.darkBg : const Color(0xFFF7F8FA);
    final cardBg = isDarkMode ? AppColors.darkCardBackground : Colors.white;
    final textPrimary = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final textSecondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final isKhmer = Get.find<LanguageController>().isKhmer;

    return Obx(() {
      final userPos = _userLocService.userLatLng;
      final selectedLatLng = _selectedStation != null
          ? LatLng(_selectedStation!.latitude, _selectedStation!.longitude)
          : userPos;

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Stack(
          children: [
            // 1. Real Interactive Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedLatLng,
                initialZoom: 14.5,
                minZoom: 6.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: (_, __) {
                  FocusScope.of(context).unfocus();
                },
              ),
              children: [
                // Tile Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tripz.frontend',
                ),

                // Polyline Connecting User Location to Selected Station
                if (_selectedStation != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [userPos, selectedLatLng],
                        color: const Color(0xFF2563EB),
                        strokeWidth: 4.0,
                        strokeCap: StrokeCap.round,
                        strokeJoin: StrokeJoin.round,
                      ),
                    ],
                  ),

                // Markers Layer: User GPS + Bus Stations
                MarkerLayer(
                  markers: [
                    // User Location Marker
                    Marker(
                      point: userPos,
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
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
                    ..._filteredStations.map((station) {
                      final isSelected = _selectedStation?.id == station.id;
                      return Marker(
                        point: LatLng(station.latitude, station.longitude),
                        width: isSelected ? 58 : 44,
                        height: isSelected ? 58 : 44,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            _selectStation(station, moveMap: true);
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
                              color: isSelected
                                  ? const Color(0xFF22C55E)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF22C55E),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(
                                          0xFF22C55E,
                                        ).withValues(alpha: 0.5)
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
                                color: isSelected
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

            // 2. Top Header & Search Area
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Bar Row
                    Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Search Input Box
                        Expanded(
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => _filterStations(),
                                    style: AppFonts.dmSans(
                                      fontSize: 14,
                                      color: textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search bus station or city...',
                                      hintStyle: AppFonts.dmSans(
                                        fontSize: 13,
                                        color: textSecondary,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      _filterStations();
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // List / Map View Toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showListView = !_showListView;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _showListView
                                  ? const Color(0xFF22C55E)
                                  : cardBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _showListView
                                    ? Icons.map_rounded
                                    : Icons.list_rounded,
                                size: 22,
                                color: _showListView
                                    ? Colors.white
                                    : textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // City Filter Chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _cities.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final city = _cities[index];
                          final isSelected = _selectedCity == city;
                          return GestureDetector(
                            onTap: () => _onCityChanged(city),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF22C55E)
                                    : cardBg,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  city,
                                  style: AppFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Side Map Controls (Zoom In, Zoom Out, Recenter to GPS)
            Positioned(
              right: 16,
              bottom: 220,
              child: Column(
                children: [
                  _buildMapButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    cardBg: cardBg,
                    iconColor: textPrimary,
                  ),
                  const SizedBox(height: 8),
                  _buildMapButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    cardBg: cardBg,
                    iconColor: textPrimary,
                  ),
                  const SizedBox(height: 8),
                  // Recenter to User GPS
                  _buildMapButton(
                    icon: Icons.my_location_rounded,
                    onTap: () async {
                      await _userLocService.determinePosition();
                      _mapController.move(_userLocService.userLatLng, 15.0);
                    },
                    cardBg: cardBg,
                    iconColor: const Color(0xFF2563EB),
                  ),
                ],
              ),
            ),

            // 4. Bottom Station Carousel or Full List View
            if (_showListView)
              Positioned(
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
                              '${_filteredStations.length} Bus Stations',
                              style: AppFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              _selectedCity,
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
                          itemCount: _filteredStations.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final station = _filteredStations[index];
                            final isSelected =
                                _selectedStation?.id == station.id;
                            final distanceKm = _userLocService
                                .calculateDistanceToStationKm(station);

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
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
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
                              onTap: () {
                                setState(() {
                                  _showListView = false;
                                });
                                _selectStation(station);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredStations.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: SizedBox(
                  height: 185,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredStations.length,
                    itemBuilder: (context, index) {
                      final station = _filteredStations[index];
                      final isSelected = _selectedStation?.id == station.id;
                      final distanceKm = _userLocService
                          .calculateDistanceToStationKm(station);

                      return GestureDetector(
                        onTap: () {
                          _selectStation(station);
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
                                    ? const Color(
                                        0xFF22C55E,
                                      ).withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                              Text(
                                station.localizedAddress(isKhmer),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: Color(0xFF22C55E),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        station.openingHours,
                                        style: AppFonts.dmSans(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF22C55E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () => Get.back(result: station),
                                    child: Text(
                                      'Select',
                                      style: AppFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
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
              ),
          ],
        ),
      );
    });
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color cardBg,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cardBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Icon(icon, size: 20, color: iconColor)),
      ),
    );
  }
}
