import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/home/data/bus_station_repository.dart';
import 'package:frontend/features/home/view/widgets/map/map_city_filter_chips.dart';
import 'package:frontend/features/home/view/widgets/map/map_controls.dart';
import 'package:frontend/features/home/view/widgets/map/map_route_polyline_layer.dart';
import 'package:frontend/features/home/view/widgets/map/map_search_bar.dart';
import 'package:frontend/features/home/view/widgets/map/map_station_carousel.dart';
import 'package:frontend/features/home/view/widgets/map/map_station_list_view.dart';
import 'package:frontend/features/home/view/widgets/map/map_station_marker.dart';
import 'package:frontend/features/home/view/widgets/map/map_user_marker.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/road_routing_service.dart';
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

  List<LatLng> _roadRoutePoints = [];

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

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
    _updateRoadRoute();

    if (widget.initialStation == null) {
      _posWorker = ever(_userLocService.currentPosition, (pos) {
        if (pos != null && mounted) {
          final nearest = _userLocService.nearestStation.value;
          if (nearest != null) {
            setState(() => _selectedStation = nearest);
            _updateRoadRoute();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _posWorker?.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ─── State Helpers ──────────────────────────────────────────────────────────

  Future<void> _updateRoadRoute() async {
    if (_selectedStation == null) return;
    final userPos = _userLocService.userLatLng;
    final destPos = LatLng(
      _selectedStation!.latitude,
      _selectedStation!.longitude,
    );
    final result = await RoadRoutingService().getRoadRoute(userPos, destPos);
    if (mounted) setState(() => _roadRoutePoints = result.points);
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
    setState(() => _selectedStation = station);
    _updateRoadRoute();
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
    } else {
      final cityPositions = {
        'Phnom Penh':    LatLng(11.5564, 104.9282),
        'Siem Reap':     LatLng(13.3633, 103.8564),
        'Sihanoukville': LatLng(10.6259, 103.5234),
        'Battambang':    LatLng(13.0957, 103.2022),
        'Kampot':        LatLng(10.6105, 104.1812),
      };
      if (cityPositions.containsKey(city)) {
        _mapController.move(cityPositions[city]!, 13.0);
      }
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkBg : const Color(0xFFF7F8FA);
    final cardBg = isDark ? AppColors.darkCardBackground : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
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
            // ── 1. Map + Layers ─────────────────────────────────────────────
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
                onTap: (_, __) => FocusScope.of(context).unfocus(),
              ),
              children: [
                // Tile layer
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tripz.frontend',
                ),

                // Road-route polyline
                if (_selectedStation != null)
                  MapRoutePolylineLayer(
                    roadRoutePoints: _roadRoutePoints,
                    userPos: userPos,
                    destPos: selectedLatLng,
                  ),

                // Markers: user + all stations
                MarkerLayer(
                  markers: [
                    MapUserMarker(point: userPos),
                    ..._filteredStations.map((station) {
                      final isSelected = _selectedStation?.id == station.id;
                      return MapStationMarker(
                        station: station,
                        isSelected: isSelected,
                        context: context,
                        onSelectStation: () =>
                            _selectStation(station, moveMap: true),
                      );
                    }),
                  ],
                ),
              ],
            ),

            // ── 2. Top Search + City Filters ────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MapSearchBar(
                      searchController: _searchController,
                      onSearchChanged: _filterStations,
                      showListView: _showListView,
                      onToggleView: () =>
                          setState(() => _showListView = !_showListView),
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 10),
                    MapCityFilterChips(
                      cities: _cities,
                      selectedCity: _selectedCity,
                      onCityChanged: _onCityChanged,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                    ),
                  ],
                ),
              ),
            ),

            // ── 3. Map Zoom / GPS Controls ───────────────────────────────────
            Positioned(
              right: 16,
              bottom: 220,
              child: MapControls(
                mapController: _mapController,
                userLocService: _userLocService,
                cardBg: cardBg,
                iconColor: textPrimary,
              ),
            ),

            // ── 4. Bottom: List View or Carousel ────────────────────────────
            if (_showListView)
              MapStationListView(
                stations: _filteredStations,
                selectedStation: _selectedStation,
                selectedCity: _selectedCity,
                isKhmer: isKhmer,
                userLocService: _userLocService,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onStationTap: (station) {
                  setState(() => _showListView = false);
                  _selectStation(station);
                },
              )
            else if (_filteredStations.isNotEmpty)
              MapStationCarousel(
                stations: _filteredStations,
                selectedStation: _selectedStation,
                isKhmer: isKhmer,
                userLocService: _userLocService,
                cardBg: cardBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onStationTap: _selectStation,
              ),
          ],
        ),
      );
    });
  }
}
