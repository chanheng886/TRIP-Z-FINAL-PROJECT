import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/view/widgets/search/search_empty_state.dart';
import 'package:frontend/features/home/view/widgets/search/search_gps_tile.dart';
import 'package:frontend/features/home/view/widgets/search/search_header.dart';
import 'package:frontend/features/home/view/widgets/search/search_location_card.dart';
import 'package:frontend/features/home/view/widgets/search/search_popular_destinations.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/shared/model/bus_location.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:get/get.dart';

class SearchScreenMobile extends StatefulWidget {
  const SearchScreenMobile({super.key});

  @override
  State<SearchScreenMobile> createState() => _SearchScreenMobileState();
}

class _SearchScreenMobileState extends State<SearchScreenMobile> {
  late final BusLocationViewmodel controller;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLocatingGps = false;

  // Popular quick-pick destinations in Cambodia
  final List<Map<String, dynamic>> _popularSpots = [
    {'name': 'Phnom Penh', 'icon': FontAwesomeIcons.landmark},
    {'name': 'Siem Reap', 'icon': FontAwesomeIcons.toriiGate},
    {'name': 'Sihanoukville', 'icon': FontAwesomeIcons.umbrellaBeach},
    {'name': 'Battambang', 'icon': FontAwesomeIcons.wheatAwn},
    {'name': 'Kampot', 'icon': FontAwesomeIcons.mountainSun},
    {'name': 'Koh Kong', 'icon': FontAwesomeIcons.water},
    {'name': 'Poipet', 'icon': FontAwesomeIcons.bridge},
    {'name': 'Kep', 'icon': FontAwesomeIcons.fishFins},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BusLocationViewmodel>()
        ? Get.find<BusLocationViewmodel>()
        : Get.put(
            BusLocationViewmodel(BusLocationRepository(BusLocationService())),
          );
    _searchController.text = controller.searchQuery.value;
    _searchController.addListener(() {
      controller.searchQuery.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleGpsLocation() async {
    setState(() => _isLocatingGps = true);
    try {
      final userLocService = Get.isRegistered<UserLocationService>()
          ? Get.find<UserLocationService>()
          : Get.put(UserLocationService());

      Get.snackbar(
        "Detecting Location",
        "Finding the nearest bus terminal to you...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 2),
      );

      final pos = await userLocService.determinePosition(showErrors: true);
      if (pos != null) {
        final nearest = userLocService.nearestStation.value;
        if (nearest != null) {
          final match = controller.locations.firstWhereOrNull(
            (l) =>
                nearest.city.toLowerCase().contains(
                  l.locationName.toLowerCase(),
                ) ||
                l.locationName.toLowerCase().contains(
                  nearest.city.toLowerCase(),
                ) ||
                nearest.name.toLowerCase().contains(
                  l.locationName.toLowerCase(),
                ),
          );
          if (match != null) {
            Get.back(result: match);
            return;
          }
        }
      }
    } catch (_) {
      // handled in service
    } finally {
      if (mounted) setState(() => _isLocatingGps = false);
    }
  }

  void _selectLocation(BusLocation loc) {
    Get.back(result: loc);
  }

  void _selectPopularSpot(String spotName) {
    final match = controller.locations.firstWhereOrNull(
      (l) =>
          l.locationName.toLowerCase() == spotName.toLowerCase() ||
          spotName.toLowerCase().contains(l.locationName.toLowerCase()) ||
          l.locationName.toLowerCase().contains(spotName.toLowerCase()),
    );
    if (match != null) {
      _selectLocation(match);
    } else {
      _searchController.text = spotName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF12141A)
        : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1C202A) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C3240)
        : const Color(0xFFE2E8F0);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar & Search Box Header
            SearchHeader(
              searchController: _searchController,
              focusNode: _focusNode,
              onClear: () {
                controller.searchQuery.value = '';
              },
              cardBg: cardBg,
              borderColor: borderColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              isDark: isDark,
            ),

            // Main Body Content
            Expanded(
              child: Obx(() {
                final _ = languageController.locale.value;

                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'loading'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.triangleExclamation,
                              color: Colors.red,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => controller.loadLocations(),
                            icon: const FaIcon(
                              FontAwesomeIcons.arrowsRotate,
                              size: 14,
                            ),
                            label: Text('retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final results = controller.filteredLocations;
                final isSearching = controller.searchQuery.value
                    .trim()
                    .isNotEmpty;

                if (results.isEmpty) {
                  return SearchEmptyState(
                    searchQuery: controller.searchQuery.value,
                    onClear: () {
                      _searchController.clear();
                      controller.searchQuery.value = '';
                    },
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    isDark: isDark,
                  );
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    // GPS Action Tile (shown when not searching)
                    if (!isSearching) ...[
                      SearchGpsTile(
                        isLocatingGps: _isLocatingGps,
                        onTap: _handleGpsLocation,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      // Popular Destinations
                      SearchPopularDestinations(
                        popularSpots: _popularSpots,
                        onSelectSpot: _selectPopularSpot,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            isSearching
                                ? 'Search Results (${results.length})'
                                : 'All Destinations (${results.length})',
                            style: AppFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Destination List Cards
                    ...results.map(
                      (loc) => SearchLocationCard(
                        location: loc,
                        onTap: () => _selectLocation(loc),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDark,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
