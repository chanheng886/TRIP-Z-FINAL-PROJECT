import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/model/user.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/view/pages/bus_schedule_mobile.dart';
import 'package:frontend/features/home/view/pages/search_screen_mobile.dart';
import 'package:frontend/features/home/view/widgets/date_picker_widget.dart';
import 'package:frontend/features/home/view/widgets/home_map_background_painter.dart';
import 'package:frontend/features/home/view/widgets/home_search_card.dart';
import 'package:frontend/features/home/view/widgets/pickup_location_card.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/features/profile/view/profile_screen.dart';
import 'package:frontend/shared/model/bus_location.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:frontend/shared/widgets/imminent_departure_banner.dart';
import 'package:frontend/shared/widgets/user_avatar.dart';
import 'package:get/get.dart';

class HomeScreenDesktop extends StatefulWidget {
  const HomeScreenDesktop({super.key});

  @override
  State<HomeScreenDesktop> createState() => _HomeScreenDesktopState();
}

class _HomeScreenDesktopState extends State<HomeScreenDesktop> {
  final TextEditingController fromLocation = TextEditingController();
  final TextEditingController toLocation = TextEditingController();
  final TextEditingController leavingDate = TextEditingController();
  final TextEditingController returnDate = TextEditingController();
  int? fromLocationId;
  int? toLocationId;

  late final BusLocationViewmodel _locVM;
  late final UserLocationService _userLocService;
  Worker? _nearestStationWorker;

  final List<Map<String, dynamic>> _popularDestinations = [
    {'name': 'Phnom Penh', 'id': 1, 'time': 'Capital Hub', 'price': '\$10'},
    {'name': 'Siem Reap', 'id': 2, 'time': '5h 30m', 'price': '\$13'},
    {'name': 'Sihanoukville', 'id': 3, 'time': '2h 30m (Expressway)', 'price': '\$11'},
    {'name': 'Battambang', 'id': 4, 'time': '4h 45m', 'price': '\$12'},
    {'name': 'Kampot', 'id': 5, 'time': '3h 00m', 'price': '\$9'},
    {'name': 'Kep', 'id': 6, 'time': '3h 30m', 'price': '\$10'},
  ];

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

    _nearestStationWorker = ever(_userLocService.nearestStation, (BusStation? station) {
      if (station != null && fromLocation.text.isEmpty && mounted) {
        _handleStationSelected(station, showNotification: false);
      }
    });
  }

  void _initDefaultLocations() {
    if (leavingDate.text.isEmpty) {
      final now = DateTime.now();
      leavingDate.text =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }

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

  void _setDateShortcut(int daysFromToday) {
    final target = DateTime.now().add(Duration(days: daysFromToday));
    setState(() {
      leavingDate.text =
          "${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}";
    });
  }

  void _handleStationSelected(
    BusStation station, {
    bool showNotification = true,
  }) {
    setState(() {
      BusLocation? match;
      if (_locVM.locations.isNotEmpty) {
        match = _locVM.locations.firstWhereOrNull(
          (l) =>
              station.city.toLowerCase() == l.locationName.toLowerCase() ||
              station.city.toLowerCase().contains(l.locationName.toLowerCase()) ||
              l.locationName.toLowerCase().contains(station.city.toLowerCase()) ||
              station.name.toLowerCase().contains(l.locationName.toLowerCase()),
        );
      }

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

      if (toLocationId != null && toLocationId == fromLocationId) {
        toLocation.clear();
        toLocationId = null;
      }
    });

    if (showNotification && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    if (fromLocationId == null || toLocationId == null || leavingDate.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final cardBg = isDarkMode ? const Color(0xFF1C202A) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF2C3240) : const Color(0xFFE2E8F0);
    final textPrimary = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSecondary = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Background top subtle gradient texture
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: CustomPaint(
              painter: HomeMapBackgroundPainter(isDarkMode: isDarkMode),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Obx(() {
                      final _ = languageController.locale.value;
                      final currentUser = Get.find<AuthViewmodel>().currentUser;
                      final username = currentUser?.username ?? 'Traveler';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Desktop Navigation Header
                          _buildDesktopHeader(
                            currentUser: currentUser,
                            username: username,
                            isDarkMode: isDarkMode,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),

                          const SizedBox(height: 20),

                          // Urgent Imminent Departure Alert Banner (15-30 mins remaining)
                          const ImminentDepartureBanner(),

                          // 2. Desktop Hero Banner with Benefits
                          _buildHeroBanner(
                            isDarkMode: isDarkMode,
                            textPrimary: textPrimary,
                          ),

                          const SizedBox(height: 32),

                          // 3. Widescreen Dual Column Workstation
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column: Search & Quick Pick Shortcuts (540px)
                              SizedBox(
                                width: 520,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Search Card
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

                                    const SizedBox(height: 16),

                                    // Quick Date Shortcuts
                                    _buildDateShortcuts(
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    ),

                                    const SizedBox(height: 24),

                                    // Popular Destinations Quick Selector
                                    _buildPopularDestinationsSection(
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 32),

                              // Right Column: Interactive Map & Station Terminal Hub
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pickup / Station locator card
                                    PickupLocationCard(
                                      onStationSelected: _handleStationSelected,
                                    ),

                                    const SizedBox(height: 24),

                                    // Featured Express Routes in Cambodia
                                    _buildExpresswayRoutesCard(
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 48),

                          // 4. Desktop Trust & Security Footer
                          _buildDesktopFooter(
                            borderColor: borderColor,
                            textSecondary: textSecondary,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader({
    required User? currentUser,
    required String username,
    required bool isDarkMode,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/tripz_icon.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.busSimple, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                      children: [
                        TextSpan(
                          text: 'Trip ',
                          style: TextStyle(color: textPrimary),
                        ),
                        const TextSpan(
                          text: 'Z',
                          style: TextStyle(color: AppColors.green),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Cambodia Express Bus Booking',
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // User Greeting & Profile
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'welcome'.tr + (username.isNotEmpty ? ', $username' : '!'),
                    style: AppFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FlutterRemix.map_pin_2_fill, size: 12, color: Color(0xFF22C55E)),
                      const SizedBox(width: 4),
                      Text(
                        fromLocation.text.isNotEmpty
                            ? 'Departing from: ${fromLocation.text.trDb}'
                            : 'where do you want to go?'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              UserAvatar(
                profileImage: currentUser?.profileImage,
                username: username,
                size: 46,
                isDark: isDarkMode,
                showBorder: true,
                borderColor: AppColors.green,
                borderWidth: 2,
                onTap: () => Get.to(() => const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner({
    required bool isDarkMode,
    required Color textPrimary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1B2E24), const Color(0xFF18222E)]
              : [const Color(0xFFE8F5E9), const Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'EXPRESS NETWORK',
                  style: AppFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Instant Confirmation • 25 Provinces Covered',
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Explore Cambodia with Confidence & Comfort',
            style: AppFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Book VIP luxury coaches, sleeper buses, and express vans across Cambodia. Live GPS tracking & official Bakong KHQR checkout.',
            style: AppFonts.dmSans(
              fontSize: 13.5,
              color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildBenefitPill('Expressway Transits (2.5h)', FontAwesomeIcons.bolt, isDarkMode),
              _buildBenefitPill('Live Terminal Tracking', FontAwesomeIcons.mapLocationDot, isDarkMode),
              _buildBenefitPill('ABA & ACLEDA PayWay', FontAwesomeIcons.buildingColumns, isDarkMode),
              _buildBenefitPill('Instant E-Tickets', FontAwesomeIcons.qrcode, isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitPill(String label, FaIconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: AppColors.green),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateShortcuts({
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        _buildShortcutChip('Today', () => _setDateShortcut(0), cardBg, borderColor, textPrimary),
        const SizedBox(width: 8),
        _buildShortcutChip('Tomorrow', () => _setDateShortcut(1), cardBg, borderColor, textPrimary),
        const SizedBox(width: 8),
        _buildShortcutChip('+3 Days (Weekend)', () => _setDateShortcut(3), cardBg, borderColor, textPrimary),
      ],
    );
  }

  Widget _buildShortcutChip(
    String label,
    VoidCallback onTap,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(
              label,
              style: AppFonts.dmSans(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularDestinationsSection({
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.fire, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Destination Pick',
                    style: AppFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'One-tap selection',
                style: AppFonts.dmSans(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularDestinations.map((dest) {
              final isSelected = toLocation.text.toLowerCase() == dest['name'].toString().toLowerCase();

              return InkWell(
                onTap: () {
                  setState(() {
                    toLocation.text = dest['name'] as String;
                    toLocationId = dest['id'] as int;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.green.withValues(alpha: 0.15)
                        : (isDarkMode ? const Color(0xFF222630) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.green : borderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: isSelected ? AppColors.green : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (dest['name'] as String).trDb,
                        style: AppFonts.dmSans(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.green : textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpresswayRoutesCard({
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
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
              const FaIcon(FontAwesomeIcons.route, size: 14, color: AppColors.green),
              const SizedBox(width: 8),
              Text(
                'Top Cambodian Express Routes',
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildRouteHighlight(
                  from: 'Phnom Penh',
                  to: 'Sihanoukville',
                  duration: '2h 30m',
                  tag: 'Expressway Route',
                  price: 'from \$11',
                  isDarkMode: isDarkMode,
                  borderColor: borderColor,
                  onSelect: () {
                    setState(() {
                      fromLocation.text = 'Phnom Penh';
                      fromLocationId = 1;
                      toLocation.text = 'Sihanoukville';
                      toLocationId = 3;
                    });
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildRouteHighlight(
                  from: 'Phnom Penh',
                  to: 'Siem Reap',
                  duration: '5h 30m',
                  tag: 'Angkor Direct',
                  price: 'from \$13',
                  isDarkMode: isDarkMode,
                  borderColor: borderColor,
                  onSelect: () {
                    setState(() {
                      fromLocation.text = 'Phnom Penh';
                      fromLocationId = 1;
                      toLocation.text = 'Siem Reap';
                      toLocationId = 2;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteHighlight({
    required String from,
    required String to,
    required String duration,
    required String tag,
    required String price,
    required bool isDarkMode,
    required Color borderColor,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF222630) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: AppFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.green),
                  ),
                ),
                Text(
                  price,
                  style: AppFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.green),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(from.trDb, style: AppFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.green),
                ),
                Text(to.trDb, style: AppFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Estimated trip time: $duration',
              style: AppFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFooter({
    required Color borderColor,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© 2026 TRIP-Z Cambodia. Licensed by Ministry of Public Works and Transport.',
            style: AppFonts.dmSans(fontSize: 12, color: textSecondary),
          ),
          Row(
            children: [
              const Icon(Icons.shield_rounded, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 6),
              Text(
                'SSL 256-bit Encrypted Payments • Bakong KHQR Verified',
                style: AppFonts.dmSans(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
