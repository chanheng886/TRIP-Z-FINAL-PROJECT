import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/repository/admin_dashboard_repository.dart';
import 'package:frontend/features/admin/service/admin_dashboard_service.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_form_hero_header.dart';
import 'package:frontend/features/admin/widgets/admin_header.dart';
import 'package:frontend/features/admin/widgets/admin_hero_banner.dart';
import 'package:frontend/features/admin/widgets/admin_list_tiles.dart';
import 'package:frontend/features/admin/widgets/admin_quick_actions.dart';
import 'package:frontend/features/admin/widgets/admin_schedule_capacity_card.dart';
import 'package:frontend/features/admin/widgets/admin_section_header.dart';
import 'package:frontend/features/admin/widgets/admin_summary_card.dart';
import 'package:frontend/features/admin/widgets/admin_tab_bar.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AdminDashboardViewmodel _vm;
  late final TabController _tabController;
  final ScrollController _tabScrollController = ScrollController();

  int _currentTabIndex = 0;

  final _locationKey = GlobalKey<FormState>();
  final _busKey = GlobalKey<FormState>();
  final _routeKey = GlobalKey<FormState>();
  final _scheduleKey = GlobalKey<FormState>();

  final _locationNameController = TextEditingController();
  final _locationImageUrlController = TextEditingController();
  final _busCompanyNameController = TextEditingController();
  final _busTypeNameController = TextEditingController();
  final _plateController = TextEditingController();
  final _busSeatController = TextEditingController();
  final _busImageUrlController = TextEditingController();
  final _scheduleSeatController = TextEditingController();
  final _priceController = TextEditingController();

  int? _selectedCompanyId;
  int? _selectedBusTypeId;
  int? _fromLocationId;
  int? _toLocationId;
  int? _selectedBusId;
  int? _selectedRouteId;
  int? _selectedScheduleBusTypeId;
  DateTime? _travelDate;
  TimeOfDay? _departureTime;
  TimeOfDay? _arrivalTime;
  String _status = 'Available';

  final List<AdminTabItem> _tabs = const [
    AdminTabItem(title: 'overview', icon: FontAwesomeIcons.chartPie),
    AdminTabItem(title: 'locations', icon: FontAwesomeIcons.locationDot),
    AdminTabItem(title: 'buses', icon: FontAwesomeIcons.bus),
    AdminTabItem(title: 'routes', icon: FontAwesomeIcons.road),
    AdminTabItem(title: 'schedules', icon: FontAwesomeIcons.calendarDays),
    AdminTabItem(title: 'bookings', icon: FontAwesomeIcons.ticket),
  ];

  @override
  void initState() {
    super.initState();
    _vm = Get.put(
      AdminDashboardViewmodel(
        AdminDashboardRepository(AdminDashboardService()),
      ),
      tag: 'adminDashboard',
    );
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging ||
        _tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _scrollToActiveTab(_currentTabIndex);
    }
  }

  void _scrollToActiveTab(int index) {
    if (!_tabScrollController.hasClients) return;
    const itemWidth = 125.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    _tabScrollController.animateTo(
      targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _navigateToTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _tabController.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _tabScrollController.dispose();
    _locationNameController.dispose();
    _locationImageUrlController.dispose();
    _busCompanyNameController.dispose();
    _busTypeNameController.dispose();
    _plateController.dispose();
    _busSeatController.dispose();
    _busImageUrlController.dispose();
    _scheduleSeatController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get cardBackground =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get pageBackground => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get primaryText =>
      isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
  Color get secondaryText =>
      isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
  Color get borderColor =>
      isDark ? const Color(0xFF2A2A2E) : const Color(0xFFD4D4D8);

  InputDecoration _fieldDecoration({
    required String label,
    required FaIconData icon,
  }) {
    final inputFieldColor = isDark ? AppColors.darkSurface : Colors.white;

    return InputDecoration(
      filled: true,
      fillColor: inputFieldColor,
      labelText: label,
      labelStyle: AppFonts.dmSans(color: secondaryText, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(child: FaIcon(icon, color: AppColors.green, size: 14)),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.green, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }

  InputDecoration _dropdownDecoration({
    required String label,
    required FaIconData icon,
  }) {
    return _fieldDecoration(label: label, icon: icon);
  }

  TextStyle _dropdownTextStyle() {
    return AppFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: primaryText,
    );
  }

  // --- SUBMISSIONS ---
  Future<void> _submitLocation() async {
    if (!_locationKey.currentState!.validate()) return;
    final ok = await _vm.createLocation(
      locationName: _locationNameController.text.trim(),
      imageUrl: _locationImageUrlController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _locationNameController.clear();
      _locationImageUrlController.clear();
      _showSnack('location_added_success'.tr, isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'failed_add_location'.tr
            : _vm.errorMessage.value,
        isError: true,
      );
    }
  }

  Future<void> _submitBus() async {
    if (!_busKey.currentState!.validate()) return;

    final companyName = _busCompanyNameController.text.trim().isNotEmpty
        ? _busCompanyNameController.text.trim()
        : _selectedCompanyId != null && _vm.companies.isNotEmpty
        ? _vm.companies
              .firstWhere((c) => c.id == _selectedCompanyId)
              .companyName
        : '';
    final busType = _busTypeNameController.text.trim().isNotEmpty
        ? _busTypeNameController.text.trim()
        : _selectedBusTypeId != null && _vm.busTypes.isNotEmpty
        ? _vm.busTypes.firstWhere((t) => t.id == _selectedBusTypeId).busType
        : '';

    if (companyName.isEmpty) {
      _showSnack('fill_bus_fields'.tr, isError: true);
      return;
    }
    if (busType.isEmpty) {
      _showSnack('fill_bus_fields'.tr, isError: true);
      return;
    }

    final ok = await _vm.createBus(
      companyName: companyName,
      busType: busType,
      seatCapacity: int.parse(_busSeatController.text.trim()),
      plateNumber: _plateController.text.trim(),
      imageUrl: _busImageUrlController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _selectedCompanyId = null;
        _selectedBusTypeId = null;
        _busCompanyNameController.clear();
        _busTypeNameController.clear();
        _plateController.clear();
        _busSeatController.clear();
        _busImageUrlController.clear();
      });
      _showSnack('bus_added_success'.tr, isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'failed_add_bus'.tr
            : _vm.errorMessage.value,
        isError: true,
      );
    }
  }

  Future<void> _submitRoute() async {
    if (!_routeKey.currentState!.validate()) return;
    if (_fromLocationId == null || _toLocationId == null) {
      _showSnack('select_both_locations'.tr, isError: true);
      return;
    }
    if (_fromLocationId == _toLocationId) {
      _showSnack('different_locations_error'.tr, isError: true);
      return;
    }
    final from = _vm.locations.firstWhere((l) => l.id == _fromLocationId);
    final to = _vm.locations.firstWhere((l) => l.id == _toLocationId);

    final exists = _vm.routes.any((r) =>
        r.fromLocation.trim().toLowerCase() ==
            from.locationName.trim().toLowerCase() &&
        r.toLocation.trim().toLowerCase() ==
            to.locationName.trim().toLowerCase());
    if (exists) {
      _showSnack(
        'route_already_exists'.tr,
        isError: true,
      );
      return;
    }

    final ok = await _vm.createRoute(
      fromLocation: from.locationName,
      toLocation: to.locationName,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _fromLocationId = null;
        _toLocationId = null;
      });
      _showSnack('route_added_success'.tr, isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'failed_add_route'.tr
            : _vm.errorMessage.value,
        isError: true,
      );
    }
  }

  Future<void> _submitSchedule() async {
    if (!_scheduleKey.currentState!.validate()) return;
    if (_selectedBusId == null ||
        _selectedRouteId == null ||
        _selectedScheduleBusTypeId == null ||
        _travelDate == null ||
        _departureTime == null ||
        _arrivalTime == null) {
      _showSnack('fill_all_schedule_fields'.tr, isError: true);
      return;
    }

    final depMinutes = _departureTime!.hour * 60 + _departureTime!.minute;
    final arrMinutes = _arrivalTime!.hour * 60 + _arrivalTime!.minute;
    if (arrMinutes <= depMinutes) {
      _showSnack('arrival_after_departure_error'.tr, isError: true);
      return;
    }

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_travelDate!);
    final hasOverlap = _vm.schedules.any((s) {
      if (s.busId != _selectedBusId) return false;
      if (s.status == BusScheduleStatus.Cancelled) return false;
      final sDateStr = DateFormat('yyyy-MM-dd').format(s.travelDate);
      if (sDateStr != selectedDateStr) return false;

      final sDepParts = s.departureTime.split(':');
      final sArrParts = s.arrivalTime.split(':');
      if (sDepParts.length < 2 || sArrParts.length < 2) return false;
      final sDep = int.parse(sDepParts[0]) * 60 + int.parse(sDepParts[1]);
      final sArr = int.parse(sArrParts[0]) * 60 + int.parse(sArrParts[1]);

      return depMinutes < sArr && arrMinutes > sDep;
    });

    if (hasOverlap) {
      _showSnack(
        'bus_overlap_error'.tr,
        isError: true,
      );
      return;
    }

    final ok = await _vm.createBusSchedule(
      busId: _selectedBusId!,
      routeId: _selectedRouteId!,
      travelDate: DateFormat('yyyy-MM-dd').format(_travelDate!),
      departureTime: _formatTime(_departureTime!),
      arrivalTime: _formatTime(_arrivalTime!),
      availableSeat: int.parse(_scheduleSeatController.text.trim()),
      status: _status,
      basePrice: double.parse(_priceController.text.trim()),
      busTypeId: _selectedScheduleBusTypeId!,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _selectedBusId = null;
        _selectedRouteId = null;
        _selectedScheduleBusTypeId = null;
        _travelDate = null;
        _departureTime = null;
        _arrivalTime = null;
        _scheduleSeatController.clear();
        _priceController.clear();
        _status = 'Available';
      });
      _showSnack('schedule_added_success'.tr, isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'failed_add_schedule'.tr
            : _vm.errorMessage.value,
        isError: true,
      );
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickTravelDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _departureTime = picked);
    }
  }

  Future<void> _pickArrivalTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _arrivalTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _arrivalTime = picked);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? (isDark ? AppColors.darkAlertText : AppColors.lightAlertText)
            : AppColors.green,
        content: Text(message, style: AppFonts.dmSans(color: Colors.white)),
      ),
    );
  }

  int? _getTabCount(int index) {
    switch (index) {
      case 1:
        return _vm.locations.length;
      case 2:
        return _vm.buses.length;
      case 3:
        return _vm.routes.length;
      case 4:
        return _vm.schedules.length;
      case 5:
        return _vm.bookings.length;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            AdminHeader(
              pageBackground: pageBackground,
              cardBackground: cardBackground,
              primaryText: primaryText,
              secondaryText: secondaryText,
              borderColor: borderColor,
              onRefresh: _vm.loadOptions,
              onBack: () => Navigator.maybePop(context),
            ),
            AdminTabBar(
              scrollController: _tabScrollController,
              tabs: _tabs,
              currentTabIndex: _currentTabIndex,
              onTabSelected: _navigateToTab,
              getTabCount: _getTabCount,
              isDark: isDark,
              cardBackground: cardBackground,
              primaryText: primaryText,
              secondaryText: secondaryText,
              borderColor: borderColor,
            ),
            Expanded(
              child: Obx(() {
                if (_vm.isLoadingOptions.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            color: AppColors.green,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'syncing_fleet_data'.tr,
                          style: AppFonts.dmSans(
                            color: primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (_vm.errorMessage.value.isNotEmpty &&
                    _vm.locations.isEmpty &&
                    _vm.buses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.circleExclamation,
                                color: Color(0xFFEF4444),
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _vm.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: AppFonts.dmSans(
                              color: primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: _vm.loadOptions,
                            icon: const FaIcon(
                              FontAwesomeIcons.rotate,
                              size: 14,
                              color: Colors.white,
                            ),
                            label: Text(
                              'retry_connection'.tr,
                              style: AppFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildLocationForm(),
                    _buildBusForm(),
                    _buildRouteForm(),
                    _buildScheduleForm(),
                    _buildBookingsTab(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- OVERVIEW TAB ---
  Widget _buildOverviewTab() {
    final availableSchedules = _vm.schedules
        .where((s) => s.status == BusScheduleStatus.Available)
        .length;
    final bookedSchedules = _vm.schedules
        .where((s) => s.status == BusScheduleStatus.Booked)
        .length;
    final confirmedBookings = _vm.bookings
        .where((b) => b.bookingStatus == BookingStatus.Confirmed)
        .length;
    final totalRevenue = _vm.bookings
        .where((b) => b.bookingStatus == BookingStatus.Confirmed)
        .fold<double>(0.0, (sum, b) => sum + b.totalAmount);

    final summaryCards = [
      SummaryCardData(
        label: 'fleet_buses',
        count: _vm.buses.length,
        icon: FontAwesomeIcons.bus,
        color: AppColors.green,
        tabIndex: 2,
      ),
      SummaryCardData(
        label: 'active_routes',
        count: _vm.routes.length,
        icon: FontAwesomeIcons.road,
        color: AppColors.greenBright,
        tabIndex: 3,
      ),
      SummaryCardData(
        label: 'trips_scheduled',
        count: _vm.schedules.length,
        icon: FontAwesomeIcons.calendarDays,
        color: AppColors.green,
        tabIndex: 4,
      ),
      SummaryCardData(
        label: 'companies',
        count: _vm.companies.length,
        icon: FontAwesomeIcons.building,
        color: AppColors.greenBright,
        tabIndex: 2,
      ),
      SummaryCardData(
        label: 'locations',
        count: _vm.locations.length,
        icon: FontAwesomeIcons.locationDot,
        color: AppColors.green,
        tabIndex: 1,
      ),
      SummaryCardData(
        label: 'bus_types',
        count: _vm.busTypes.length,
        icon: FontAwesomeIcons.sitemap,
        color: AppColors.greenBright,
        tabIndex: 2,
      ),
    ];

    final quickActions = [
      QuickActionItem(
        label: 'quick_add_location',
        icon: FontAwesomeIcons.locationDot,
        onTap: () => _navigateToTab(1),
      ),
      QuickActionItem(
        label: 'quick_add_bus',
        icon: FontAwesomeIcons.bus,
        onTap: () => _navigateToTab(2),
      ),
      QuickActionItem(
        label: 'quick_add_route',
        icon: FontAwesomeIcons.road,
        onTap: () => _navigateToTab(3),
      ),
      QuickActionItem(
        label: 'quick_add_schedule',
        icon: FontAwesomeIcons.calendarPlus,
        onTap: () => _navigateToTab(4),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Executive Hero Card
          AdminHeroBanner(
            totalRevenue: totalRevenue,
            totalBookings: _vm.bookings.length,
            confirmedBookings: confirmedBookings,
            totalBuses: _vm.buses.length,
            totalRoutes: _vm.routes.length,
            isDark: isDark,
            onViewBookings: () => _navigateToTab(5),
          ),
          const SizedBox(height: 16),

          // Quick Action Launchpad
          AdminQuickActions(actions: quickActions, isDark: isDark),
          const SizedBox(height: 20),

          // Key Stats Header & Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'fleet_metric_breakdown'.tr,
                style: AppFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              Text(
                'tap_to_manage'.tr,
                style: AppFonts.dmSans(fontSize: 12, color: secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.92,
            ),
            itemCount: summaryCards.length,
            itemBuilder: (context, index) {
              final card = summaryCards[index];
              return AdminSummaryCard(
                card: card,
                cardBg: cardBackground,
                primaryText: primaryText,
                secondaryText: secondaryText,
                borderColor: borderColor,
                onCardTap: _navigateToTab,
              );
            },
          ),
          const SizedBox(height: 20),

          // Schedule Capacity Split
          if (_vm.schedules.isNotEmpty) ...[
            AdminScheduleCapacityCard(
              available: availableSchedules,
              booked: bookedSchedules,
              isDark: isDark,
              cardBackground: cardBackground,
              primaryText: primaryText,
              secondaryText: secondaryText,
              borderColor: borderColor,
            ),
            const SizedBox(height: 22),
          ],

          // Recent Schedules Feed
          if (_vm.schedules.isNotEmpty) ...[
            AdminSectionHeader(
              title: 'recent_schedules',
              icon: FontAwesomeIcons.calendarDays,
              primaryText: primaryText,
              onViewAll: () => _navigateToTab(4),
            ),
            const SizedBox(height: 10),
            ..._vm.schedules
                .take(4)
                .map(
                  (schedule) => AdminScheduleListTile(
                    schedule: schedule,
                    isDark: isDark,
                    cardBg: cardBackground,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    borderColor: borderColor,
                  ),
                ),
            const SizedBox(height: 18),
          ],

          // Recent Buses Feed
          if (_vm.buses.isNotEmpty) ...[
            AdminSectionHeader(
              title: 'recent_fleet_buses',
              icon: FontAwesomeIcons.bus,
              primaryText: primaryText,
              onViewAll: () => _navigateToTab(2),
            ),
            const SizedBox(height: 10),
            ..._vm.buses
                .take(4)
                .map(
                  (bus) => AdminBusListTile(
                    bus: bus,
                    cardBg: cardBackground,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    borderColor: borderColor,
                  ),
                ),
            const SizedBox(height: 18),
          ],

          // Recent Routes Feed
          if (_vm.routes.isNotEmpty) ...[
            AdminSectionHeader(
              title: 'active_routes',
              icon: FontAwesomeIcons.road,
              primaryText: primaryText,
              onViewAll: () => _navigateToTab(3),
            ),
            const SizedBox(height: 10),
            ..._vm.routes
                .take(4)
                .map(
                  (route) => AdminRouteListTile(
                    route: route,
                    cardBg: cardBackground,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    borderColor: borderColor,
                  ),
                ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- LOCATION FORM TAB ---
  Widget _buildLocationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFormHeroHeader(
            title: 'location_registry'.tr,
            subtitle: 'register_terminal_cities'.tr,
            icon: FontAwesomeIcons.locationDot,
            count: _vm.locations.length,
            isDark: isDark,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Form(
              key: _locationKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'add_new_destination'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationNameController,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      label: 'location_name_label'.tr,
                      icon: FontAwesomeIcons.mapLocationDot,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'location_name_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationImageUrlController,
                    textInputAction: TextInputAction.done,
                    decoration: _fieldDecoration(
                      label: 'image_url_label'.tr,
                      icon: FontAwesomeIcons.image,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'image_url_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  _submitButton(
                    _vm.isSubmitting.value,
                    _submitLocation,
                    'add_location_destination'.tr,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (_vm.locations.isNotEmpty) ...[
            Text(
              '${'existing_destinations'.tr} (${_vm.locations.length})',
              style: AppFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 10),
            ..._vm.locations.map(
              (loc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.locationPin,
                          size: 13,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.locationName.trDb,
                        style: AppFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'ID: #${loc.id}',
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- BUS FORM TAB ---
  Widget _buildBusForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFormHeroHeader(
            title: 'bus_fleet_registry'.tr,
            subtitle: 'register_new_vehicles'.tr,
            icon: FontAwesomeIcons.bus,
            count: _vm.buses.length,
            isDark: isDark,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Form(
              key: _busKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'register_new_bus'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_vm.companies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'no_existing_companies'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _selectedCompanyId,
                    decoration: _dropdownDecoration(
                      label: 'select_company'.tr,
                      icon: FontAwesomeIcons.building,
                    ),
                    dropdownColor: cardBackground,
                    items: _vm.companies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.companyName.trDb,
                              style: _dropdownTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCompanyId = v;
                        if (v != null) {
                          final company = _vm.companies.firstWhere(
                            (c) => c.id == v,
                          );
                          _busCompanyNameController.text = company.companyName;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _busCompanyNameController,
                    decoration: _fieldDecoration(
                      label: 'or_type_company'.tr,
                      icon: FontAwesomeIcons.pen,
                    ),
                    onChanged: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() => _selectedCompanyId = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _selectedBusTypeId,
                    decoration: _dropdownDecoration(
                      label: 'select_bus_type'.tr,
                      icon: FontAwesomeIcons.sitemap,
                    ),
                    dropdownColor: cardBackground,
                    items: _vm.busTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(
                              t.busType.trDb,
                              style: _dropdownTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedBusTypeId = v;
                        if (v != null) {
                          final busType = _vm.busTypes.firstWhere(
                            (t) => t.id == v,
                          );
                          _busTypeNameController.text = busType.busType;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _busTypeNameController,
                    decoration: _fieldDecoration(
                      label: 'or_type_bus_type'.tr,
                      icon: FontAwesomeIcons.pen,
                    ),
                    onChanged: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() => _selectedBusTypeId = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _plateController,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      label: 'license_plate_label'.tr,
                      icon: FontAwesomeIcons.idCard,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'plate_number_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _busSeatController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      label: 'seat_capacity_label'.tr,
                      icon: FontAwesomeIcons.users,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'seat_capacity_required'.tr;
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'enter_valid_number'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _busImageUrlController,
                    textInputAction: TextInputAction.done,
                    decoration: _fieldDecoration(
                      label: 'bus_photo_url_label'.tr,
                      icon: FontAwesomeIcons.image,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _submitButton(
                    _vm.isSubmitting.value,
                    _submitBus,
                    'register_bus_to_fleet'.tr,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (_vm.buses.isNotEmpty) ...[
            Text(
              '${'fleet_vehicles'.tr} (${_vm.buses.length})',
              style: AppFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 10),
            ..._vm.buses.map(
              (bus) => AdminBusListTile(
                bus: bus,
                cardBg: cardBackground,
                primaryText: primaryText,
                secondaryText: secondaryText,
                borderColor: borderColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- ROUTE FORM TAB ---
  Widget _buildRouteForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFormHeroHeader(
            title: 'route_network'.tr,
            subtitle: 'create_origin_dest_routes'.tr,
            icon: FontAwesomeIcons.road,
            count: _vm.routes.length,
            isDark: isDark,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Form(
              key: _routeKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'connect_new_route'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_vm.locations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'no_destinations_available'.tr,
                        style: AppFonts.dmSans(color: secondaryText),
                      ),
                    ),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _fromLocationId,
                    decoration: _dropdownDecoration(
                      label: 'from_origin'.tr,
                      icon: FontAwesomeIcons.locationDot,
                    ),
                    dropdownColor: cardBackground,
                    items: _vm.locations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(
                              l.locationName.trDb,
                              style: _dropdownTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _fromLocationId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _toLocationId,
                    decoration: _dropdownDecoration(
                      label: 'to_destination'.tr,
                      icon: FontAwesomeIcons.flag,
                    ),
                    dropdownColor: cardBackground,
                    items: _vm.locations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(
                              l.locationName.trDb,
                              style: _dropdownTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _toLocationId = v),
                  ),
                  const SizedBox(height: 22),
                  _submitButton(
                    _vm.isSubmitting.value,
                    _submitRoute,
                    'create_route_line'.tr,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (_vm.routes.isNotEmpty) ...[
            Text(
              '${'active_route_lines'.tr} (${_vm.routes.length})',
              style: AppFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 10),
            ..._vm.routes.map(
              (route) => AdminRouteListTile(
                route: route,
                cardBg: cardBackground,
                primaryText: primaryText,
                secondaryText: secondaryText,
                borderColor: borderColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- SCHEDULE FORM TAB ---
  Widget _buildScheduleForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFormHeroHeader(
            title: 'trip_scheduler'.tr,
            subtitle: 'schedule_times_routes_fares'.tr,
            icon: FontAwesomeIcons.calendarDays,
            count: _vm.schedules.length,
            isDark: isDark,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Form(
              key: _scheduleKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'schedule_new_trip'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _selectedBusId,
                    decoration: _dropdownDecoration(
                      label: 'select_bus_vehicle'.tr,
                      icon: FontAwesomeIcons.bus,
                    ),
                    dropdownColor: cardBackground,
                    items: _vm.buses
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(
                              '${b.plateNumber} • ${b.companyName.trDb}',
                              style: _dropdownTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedBusId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _selectedRouteId,
                    decoration: _dropdownDecoration(
                      label: 'select_travel_route'.tr,
                      icon: FontAwesomeIcons.road,
                    ),
                    dropdownColor: cardBackground,
                    items: _vm.routes
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(
                              '${r.fromLocation.trDb} → ${r.toLocation.trDb}',
                              style: _dropdownTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRouteId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _selectedScheduleBusTypeId,
                    decoration: _dropdownDecoration(
                      label: 'select_bus_type'.tr,
                      icon: FontAwesomeIcons.sitemap,
                    ),
                    dropdownColor: cardBackground,
                    items: _vm.busTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(
                              t.busType.trDb,
                              style: _dropdownTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedScheduleBusTypeId = v),
                  ),
                  const SizedBox(height: 16),
                  _pickerField(
                    label: 'travel_date_label'.tr,
                    icon: FontAwesomeIcons.calendarDays,
                    value: _travelDate == null
                        ? null
                        : DateFormat('MMM dd, yyyy').format(_travelDate!),
                    onTap: _pickTravelDate,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _pickerField(
                          label: 'departure_label'.tr,
                          icon: FontAwesomeIcons.clock,
                          value: _departureTime == null
                              ? null
                              : _formatTime(_departureTime!).substring(0, 5),
                          onTap: _pickDepartureTime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _pickerField(
                          label: 'arrival_label'.tr,
                          icon: FontAwesomeIcons.clock,
                          value: _arrivalTime == null
                              ? null
                              : _formatTime(_arrivalTime!).substring(0, 5),
                          onTap: _pickArrivalTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _scheduleSeatController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: 'available_seats_label'.tr,
                            icon: FontAwesomeIcons.users,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'required'.tr;
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return 'invalid'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            label: 'base_price_label'.tr,
                            icon: FontAwesomeIcons.moneyBill1,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'required'.tr;
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'invalid'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'schedule_status'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: secondaryText,
                          ),
                        ),
                      ),
                      Row(
                        children: ['Available', 'Booked'].map((s) {
                          final isSelected = _status == s;
                          final isAvailable = s == 'Available';
                          final activeColor = isAvailable
                              ? AppColors.green
                              : (isDark
                                    ? const Color(0xFF8A8A8E)
                                    : const Color(0xFF64748B));

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _status = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                  right: s == 'Available' ? 10 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeColor.withValues(
                                          alpha: isDark ? 0.2 : 0.12,
                                        )
                                      : cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? activeColor
                                        : borderColor,
                                    width: isSelected ? 1.8 : 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isSelected
                                          ? (isAvailable
                                                ? Icons.check_circle_rounded
                                                : Icons.cancel_rounded)
                                          : Icons.radio_button_unchecked,
                                      size: 16,
                                      color: isSelected
                                          ? activeColor
                                          : (isDark
                                                ? Colors.white38
                                                : Colors.black38),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      s.trDb,
                                      style: AppFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? activeColor
                                            : secondaryText,
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
                  ),
                  const SizedBox(height: 24),
                  _submitButton(
                    _vm.isSubmitting.value,
                    _submitSchedule,
                    'publish_trip_schedule'.tr,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (_vm.schedules.isNotEmpty) ...[
            Text(
              '${'scheduled_departures'.tr} (${_vm.schedules.length})',
              style: AppFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 10),
            ..._vm.schedules.map(
              (s) => AdminScheduleListTile(
                schedule: s,
                isDark: isDark,
                cardBg: cardBackground,
                primaryText: primaryText,
                secondaryText: secondaryText,
                borderColor: borderColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- BOOKINGS TAB ---
  Widget _buildBookingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFormHeroHeader(
            title: 'customer_bookings'.tr,
            subtitle: 'realtime_reservation_log'.tr,
            icon: FontAwesomeIcons.ticket,
            count: _vm.bookings.length,
            isDark: isDark,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 16),
          Obx(() {
            final selDate = _vm.selectedDate.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selDate != null
                      ? AppColors.green.withValues(alpha: 0.4)
                      : borderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.calendarDay,
                        size: 12,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selDate != null
                          ? DateFormat('EEE, MMM dd, yyyy').format(selDate)
                          : 'filter_bookings_date'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: selDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selDate != null ? primaryText : secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selDate != null)
                    GestureDetector(
                      onTap: () => _vm.clearDateFilter(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'clear'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selDate ?? now,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(now.year + 1),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: isDark
                                  ? const ColorScheme.dark(
                                      primary: AppColors.green,
                                    )
                                  : const ColorScheme.light(
                                      primary: AppColors.green,
                                    ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && mounted) {
                        await _vm.loadBookingsByDate(picked);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      'pick_date'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          if (_vm.bookings.isEmpty && _vm.bookingError.value.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      size: 30,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'failed_load_bookings'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _vm.bookingError.value,
                      textAlign: TextAlign.center,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _vm.loadOptions,
                      icon: const FaIcon(
                        FontAwesomeIcons.rotate,
                        size: 13,
                        color: Colors.white,
                      ),
                      label: Text('retry_bookings'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_vm.bookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Center(
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.ticket,
                      size: 34,
                      color: secondaryText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'no_bookings_recorded'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'passenger_reservations_appear'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._vm.bookings.map(
              (booking) => AdminBookingCard(
                booking: booking,
                cardBg: cardBackground,
                primaryText: primaryText,
                secondaryText: secondaryText,
                borderColor: borderColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required FaIconData icon,
    required String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: _fieldDecoration(label: label, icon: icon),
        child: Text(
          value ?? 'select'.tr,
          style: AppFonts.dmSans(
            fontSize: 14,
            fontWeight: value == null ? FontWeight.normal : FontWeight.w600,
            color: value == null ? secondaryText : primaryText,
          ),
        ),
      ),
    );
  }

  Widget _submitButton(bool isLoading, VoidCallback? onPressed, String label) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppColors.green.withValues(alpha: 0.4),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: AppFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}
