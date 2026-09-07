import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
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
            _buildSearchHeader(
              context,
              isDark,
              cardBg,
              borderColor,
              primaryTextColor,
              secondaryTextColor,
              languageController,
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
                  return _buildEmptyState(
                    primaryTextColor,
                    secondaryTextColor,
                    cardBg,
                    borderColor,
                    isDark,
                  );
                }

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    // GPS Action Tile (shown when not searching)
                    if (!isSearching) ...[
                      _buildGpsTile(isDark, borderColor),
                      const SizedBox(height: 20),

                      // Popular Destinations
                      _buildPopularDestinations(
                        cardBg,
                        borderColor,
                        primaryTextColor,
                        secondaryTextColor,
                        isDark,
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
                      (loc) => _buildLocationCard(
                        loc: loc,
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

  Widget _buildSearchHeader(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    LanguageController languageController,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12141A) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: borderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Back Button and Screen Title
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: FaIcon(
                  FontAwesomeIcons.angleLeft,
                  size: 24,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'select_destination'.tr.isNotEmpty
                          ? 'select_destination'.tr
                          : 'Select Destination',
                      style: AppFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      'Pick city or terminal in Cambodia',
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focusNode.hasFocus ? AppColors.green : borderColor,
                width: _focusNode.hasFocus ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 15,
                  color: _focusNode.hasFocus
                      ? AppColors.green
                      : secondaryTextColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    cursorColor: AppColors.green,
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search city, province, or station...',
                      hintStyle: AppFonts.dmSans(
                        fontSize: 14,
                        color: secondaryTextColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    splashRadius: 18,
                    icon: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: secondaryTextColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.xmark,
                        size: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      controller.searchQuery.value = '';
                      setState(() {});
                    },
                  )
                else
                  const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsTile(bool isDark, Color borderColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLocatingGps ? null : _handleGpsLocation,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.green.withValues(alpha: 0.15),
                      AppColors.green.withValues(alpha: 0.05),
                    ]
                  : [
                      AppColors.green.withValues(alpha: 0.10),
                      AppColors.greenBright.withValues(alpha: 0.03),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.green.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.greenBright],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLocatingGps
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Use My Current Location',
                          style: AppFonts.dmSans(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'GPS',
                            style: AppFonts.dmSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isLocatingGps
                          ? 'Acquiring GPS fix and nearest station...'
                          : 'Auto-detect closest bus terminal to you',
                      style: AppFonts.dmSans(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 13,
                color: AppColors.green.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularDestinations(
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.fire,
                size: 13,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              Text(
                'Popular Destinations',
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
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSpots.map((spot) {
            final name = spot['name'] as String;
            final dynamic icon = spot['icon'];
            final localizedName = name.trDb;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectPopularSpot(name),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(icon, size: 12, color: AppColors.green),
                      const SizedBox(width: 6),
                      Text(
                        localizedName,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationCard({
    required BusLocation loc,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    final localizedName = loc.locationName.trDb;
    final hasDualLanguage = localizedName != loc.locationName;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectLocation(loc),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.locationDot,
                      size: 16,
                      color: AppColors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedName,
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasDualLanguage
                            ? '${loc.locationName} • Cambodia'
                            : 'Cambodia • Station & Terminal',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF242A36)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'select'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 9,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardBg,
    Color borderColor,
    bool isDark,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2430)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.mapLocationDot,
                  size: 32,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'no_data'.tr,
              style: AppFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No cities or stations matched "${controller.searchQuery.value}".\nTry checking spelling or exploring popular spots.',
              textAlign: TextAlign.center,
              style: AppFonts.dmSans(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cardBg,
                foregroundColor: AppColors.green,
                side: BorderSide(color: borderColor),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                _searchController.clear();
                controller.searchQuery.value = '';
                setState(() {});
              },
              icon: const FaIcon(FontAwesomeIcons.xmark, size: 12),
              label: Text(
                'Clear Search',
                style: AppFonts.dmSans(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
