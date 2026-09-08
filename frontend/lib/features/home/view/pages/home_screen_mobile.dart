import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/view/pages/bus_schedule_mobile.dart';
import 'package:frontend/features/home/view/pages/search_screen_mobile.dart';
import 'package:frontend/features/home/view/widgets/date_picker_widget.dart';
import 'package:frontend/features/home/view/widgets/home_map_background_painter.dart';
import 'package:frontend/features/home/view/widgets/home_search_card.dart';
import 'package:frontend/features/home/view/widgets/pickup_location_card.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/features/profile/view/profile_screen.dart';
import 'package:frontend/shared/model/bus_location.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:frontend/shared/widgets/user_avatar.dart';
import 'package:get/get.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile> {
  final TextEditingController fromLocation = TextEditingController();
  final TextEditingController toLocation = TextEditingController();
  final TextEditingController leavingDate = TextEditingController();
  final TextEditingController returnDate = TextEditingController();
  int? fromLocationId;
  int? toLocationId;

  late final BusLocationViewmodel _locVM;
  late final UserLocationService _userLocService;
  Worker? _nearestStationWorker;

  @override
  void initState() {
    super.initState();
    _locVM = Get.isRegistered<BusLocationViewmodel>()
        ? Get.find<BusLocationViewmodel>()
        : Get.put(
            BusLocationViewmodel(BusLocationRepository(BusLocationService())),
          );
    _userLocService = Get.isRegistered<UserLocationService>()
        ? Get.find<UserLocationService>()
        : Get.put(UserLocationService());

    _initDefaultLocations();

    // Listen to nearest detected station via GPS to auto-set departure if empty
    _nearestStationWorker = ever(_userLocService.nearestStation, (BusStation? station) {
      if (station != null && fromLocation.text.isEmpty && mounted) {
        _handleStationSelected(station, showNotification: false);
      }
    });
  }

  void _initDefaultLocations() {
    // Default leaving date to today if empty
    if (leavingDate.text.isEmpty) {
      final now = DateTime.now();
      leavingDate.text =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }

    // Default departure to nearest detected station or Phnom Penh
    final nearest = _userLocService.nearestStation.value;
    if (nearest != null) {
      _handleStationSelected(nearest, showNotification: false);
    } else {
      _setDepartureCity('Phnom Penh');
    }
  }

  void _setDepartureCity(String cityName) {
    final match = _locVM.locations.firstWhereOrNull(
      (l) =>
          l.locationName.toLowerCase() == cityName.toLowerCase() ||
          cityName.toLowerCase().contains(l.locationName.toLowerCase()) ||
          l.locationName.toLowerCase().contains(cityName.toLowerCase()),
    );
    if (match != null) {
      setState(() {
        fromLocation.text = match.locationName;
        fromLocationId = match.id;
      });
    } else {
      setState(() {
        fromLocation.text = cityName;
        final lower = cityName.toLowerCase();
        if (lower.contains('phnom penh')) {
          fromLocationId = 1;
        } else if (lower.contains('siem reap')) {
          fromLocationId = 2;
        } else if (lower.contains('sihanoukville')) {
          fromLocationId = 3;
        } else if (lower.contains('battambang')) {
          fromLocationId = 4;
        } else if (lower.contains('kampot')) {
          fromLocationId = 5;
        }
      });
    }
  }

  @override
  void dispose() {
    _nearestStationWorker?.dispose();
    fromLocation.dispose();
    toLocation.dispose();
    leavingDate.dispose();
    returnDate.dispose();
    super.dispose();
  }

  void _swapLocations() {
    setState(() {
      final tempName = fromLocation.text;
      final tempId = fromLocationId;
      fromLocation.text = toLocation.text;
      fromLocationId = toLocationId;
      toLocation.text = tempName;
      toLocationId = tempId;
    });
  }

  Future<void> _selectFromLocation() async {
    final result = await Get.to<BusLocation>(() => const SearchScreenMobile());
    if (result != null) {
      setState(() {
        fromLocation.text = result.locationName;
        fromLocationId = result.id;
      });
    }
  }

  Future<void> _selectToLocation() async {
    final result = await Get.to<BusLocation>(() => const SearchScreenMobile());
    if (result != null) {
      setState(() {
        toLocation.text = result.locationName;
        toLocationId = result.id;
      });
    }
  }

  Future<void> _selectLeavingDate() async {
    final picked = await datePopUpPicker(
      context,
      initaialDate: leavingDate.text.isNotEmpty
          ? DateTime.tryParse(leavingDate.text)
          : null,
    );
    if (picked != null) {
      setState(() {
        leavingDate.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final picked = await datePopUpPicker(
      context,
      initaialDate: returnDate.text.isNotEmpty
          ? DateTime.tryParse(returnDate.text)
          : null,
    );
    if (picked != null) {
      setState(() {
        returnDate.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _handleStationSelected(
    BusStation station, {
    bool showNotification = true,
  }) {
    setState(() {
      // 1. Resolve matched BusLocation (city / province) from location database
      BusLocation? match;
      if (_locVM.locations.isNotEmpty) {
        match = _locVM.locations.firstWhereOrNull(
          (l) =>
              station.city.toLowerCase() == l.locationName.toLowerCase() ||
              station.city.toLowerCase().contains(
                l.locationName.toLowerCase(),
              ) ||
              l.locationName.toLowerCase().contains(
                station.city.toLowerCase(),
              ) ||
              station.name.toLowerCase().contains(l.locationName.toLowerCase()),
        );
      }

      // 2. Set departure location to the city/province (e.g. "Phnom Penh")
      if (match != null) {
        fromLocation.text = match.locationName;
        fromLocationId = match.id;
      } else {
        fromLocation.text = station.city;
        final lower = station.city.toLowerCase();
        if (lower.contains('phnom penh')) {
          fromLocationId = 1;
        } else if (lower.contains('siem reap')) {
          fromLocationId = 2;
        } else if (lower.contains('sihanoukville')) {
          fromLocationId = 3;
        } else if (lower.contains('battambang')) {
          fromLocationId = 4;
        } else if (lower.contains('kampot')) {
          fromLocationId = 5;
        }
      }

      // If destination was previously identical to departure, clear it
      if (toLocationId != null && toLocationId == fromLocationId) {
        toLocation.clear();
        toLocationId = null;
      }
    });

    if (showNotification && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF22C55E),
          content: Text(
            "Departure set to: ${fromLocation.text} (${station.name})",
            style: AppFonts.dmSans(fontSize: 14, color: Colors.white),
          ),
        ),
      );
    }
  }

  void _handleFindBus() {
    if (fromLocationId == null ||
        toLocationId == null ||
        leavingDate.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF1E293B),
          content: Text(
            "Please select From, To, and Leaving Date",
            style: AppFonts.dmSans(fontSize: 14, color: Colors.white),
          ),
        ),
      );
      return;
    }

    if (fromLocationId == toLocationId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.redAccent,
          content: Text(
            'same_location_error'.tr,
            style: AppFonts.dmSans(fontSize: 14, color: Colors.white),
          ),
        ),
      );
      return;
    }

    Get.to(
      () => BusScheduleMobile(
        fromLocationId: fromLocationId!,
        toLocationId: toLocationId!,
        fromLocationName: fromLocation.text,
        toLocationName: toLocation.text,
        travelDate: DateTime.parse(leavingDate.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDarkMode ? AppColors.darkBg : const Color(0xFFF7F8FA);
    final textPrimary = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final textSecondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Top Subtle Map Line Texture Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: CustomPaint(
              painter: HomeMapBackgroundPainter(isDarkMode: isDarkMode),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Obx(() {
                // Reactive trigger on language changes
                final _ = languageController.locale.value;
                final currentUser = Get.find<AuthViewmodel>().currentUser;
                final user = currentUser?.username ?? 'User';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header: Welcome, [User] & Avatar
                    _buildHeader(
                      currentUser: currentUser,
                      username: user,
                      isDarkMode: isDarkMode,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 24),

                    // Main Search Bus Card
                    HomeSearchCard(
                      fromLocationName: fromLocation.text,
                      toLocationName: toLocation.text,
                      leavingDate: leavingDate.text,
                      returnDate: returnDate.text,
                      onFromTap: _selectFromLocation,
                      onToTap: _selectToLocation,
                      onLeavingTap: _selectLeavingDate,
                      onReturnTap: _selectReturnDate,
                      onSwap: _swapLocations,
                      onFindBus: _handleFindBus,
                    ),
                    const SizedBox(height: 24),

                    // Pick Up Location / Tracking Map Section
                    PickupLocationCard(
                      onStationSelected: _handleStationSelected,
                    ),

                    // Space for floating button / bottom navigation padding
                    const SizedBox(height: 80),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required User? currentUser,
    required String username,
    required bool isDarkMode,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Greeting & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'welcome'.tr + (username.isNotEmpty ? ', $username' : '!'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    FlutterRemix.map_pin_2_fill,
                    size: 14,
                    color: Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'where do you want to go?'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Right: Dynamic User Avatar
        UserAvatar(
          profileImage: currentUser?.profileImage,
          username: username,
          size: 48,
          isDark: isDarkMode,
          showBorder: true,
          borderColor: isDarkMode ? const Color(0xFF2C313C) : Colors.white,
          borderWidth: 2,
          onTap: () => Get.to(() => const ProfileScreen()),
        ),
      ],
    );
  }
}
