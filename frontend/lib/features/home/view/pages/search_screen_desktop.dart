import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/view/widgets/search/search_empty_state.dart';
import 'package:frontend/features/home/view/widgets/search/search_location_card.dart';
import 'package:frontend/features/home/view/widgets/search/search_popular_destinations.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:get/get.dart';

class SearchScreenDesktop extends StatefulWidget {
  const SearchScreenDesktop({super.key});

  @override
  State<SearchScreenDesktop> createState() => _SearchScreenDesktopState();
}

class _SearchScreenDesktopState extends State<SearchScreenDesktop> {
  late final BusLocationViewmodel controller;
  final TextEditingController _searchController = TextEditingController();
  bool _isLocatingGps = false;

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
                nearest.city.toLowerCase().contains(l.locationName.toLowerCase()) ||
                l.locationName.toLowerCase().contains(nearest.city.toLowerCase()) ||
                nearest.name.toLowerCase().contains(l.locationName.toLowerCase()),
          );
          if (match != null) {
            Get.back(result: match);
            return;
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLocatingGps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDarkMode ? const Color(0xFF12161E) : const Color(0xFFF7F8FC);
    final cardBg = isDarkMode ? const Color(0xFF1E222B) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF2C2C30) : const Color(0xFFE2E8F0);
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 18,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          'search_city_terminal'.tr,
          style: AppFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Bar Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        size: 16,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: AppFonts.dmSans(
                            fontSize: 15,
                            color: primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'search_destination'.tr,
                            hintStyle: AppFonts.dmSans(
                              color: secondaryTextColor,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            controller.searchQuery.value = '';
                          },
                        ),
                      const SizedBox(width: 8),
                      // GPS Detect Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green.withValues(alpha: 0.12),
                          foregroundColor: AppColors.green,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isLocatingGps ? null : _handleGpsLocation,
                        icon: _isLocatingGps
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.green,
                                ),
                              )
                            : const FaIcon(FontAwesomeIcons.locationCrosshairs, size: 14),
                        label: Text(
                          'use_current_location'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Popular Destinations Section
                SearchPopularDestinations(
                  popularSpots: _popularSpots,
                  onSelectSpot: (cityName) {
                    _searchController.text = cityName;
                    controller.searchQuery.value = cityName;
                  },
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                  isDark: isDarkMode,
                ),
                const SizedBox(height: 24),

                // 3. Search Results / Available Locations Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'all_destinations'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    Obx(() {
                      final count = controller.filteredLocations.length;
                      return Text(
                        '$count terminal${count == 1 ? '' : 's'}',
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Locations List / Grid
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(color: AppColors.green),
                      ),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          controller.errorMessage.value,
                          style: AppFonts.dmSans(color: Colors.redAccent),
                        ),
                      ),
                    );
                  }

                  final results = controller.filteredLocations;
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
                      isDark: isDarkMode,
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3.2,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final location = results[index];
                      return SearchLocationCard(
                        location: location,
                        onTap: () => Get.back(result: location),
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isDark: isDarkMode,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
