import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/view/pages/bus_schedule_mobile.dart';
import 'package:frontend/features/home/view/pages/search_screen_mobile.dart';
import 'package:frontend/features/home/view/widgets/date_picker_widget.dart';
import 'package:frontend/features/home/view/widgets/home_map_background_painter.dart';
import 'package:frontend/features/home/view/widgets/home_search_card.dart';
import 'package:frontend/features/home/view/widgets/pickup_location_card.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/shared/model/bus_location.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
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

  @override
  void dispose() {
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

  void _handleStationSelected(BusStation station) {
    setState(() {
      fromLocation.text = station.name;

      // Look up location from BusLocationViewmodel
      if (Get.isRegistered<BusLocationViewmodel>()) {
        final locVM = Get.find<BusLocationViewmodel>();
        final match = locVM.locations.firstWhereOrNull((l) =>
            station.city.toLowerCase().contains(l.locationName.toLowerCase()) ||
            l.locationName.toLowerCase().contains(station.city.toLowerCase()) ||
            station.name.toLowerCase().contains(l.locationName.toLowerCase()));
        if (match != null) {
          fromLocationId = match.id;
        }
      }

      // Fallback matching by city name
      if (fromLocationId == null) {
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: const Color(0xFF22C55E),
        content: Text(
          "Selected departure: ${station.name}",
          style: AppFonts.dmSans(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
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
                final user =
                    Get.find<AuthViewmodel>().currentUser?.username ?? 'Chan';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header: Welcome, [User] & Avatar
                    _buildHeader(
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
    required String username,
    required bool isDarkMode,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Greeting Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'welcome'.tr.isNotEmpty ? 'welcome'.tr : 'Welcome'}, $username',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
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

        // Right: Circular User Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDarkMode ? const Color(0xFF2C313C) : Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=300&q=80',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDarkMode
                    ? const Color(0xFF2C313C)
                    : Colors.grey.shade300,
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF4FD18B),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: AppFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
