import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/admin/repository/admin_dashboard_repository.dart';
import 'package:frontend/features/admin/services/admin_dashboard_service.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/features/home/models/bus_schedule.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _vm = Get.put(
      AdminDashboardViewmodel(
        AdminDashboardRepository(AdminDashboardService()),
      ),
      tag: 'adminDashboard',
    );
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  InputDecoration _fieldDecoration({
    required String label,
    required FaIconData icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFieldColor = isDarkMode
        ? AppColors.darkInputField
        : AppColors.lightInputField;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    return InputDecoration(
      filled: true,
      fillColor: inputFieldColor,
      labelText: label,
      labelStyle: GoogleFonts.dmSans(color: secondaryText),
      prefixIcon: FaIcon(icon, color: AppColors.primary, size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _dropdownDecoration({
    required String label,
    required FaIconData icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFieldColor = isDarkMode
        ? AppColors.darkInputField
        : AppColors.lightInputField;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    return InputDecoration(
      filled: true,
      fillColor: inputFieldColor,
      labelText: label,
      labelStyle: GoogleFonts.dmSans(color: secondaryText),
      prefixIcon: FaIcon(icon, color: AppColors.primary, size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  TextStyle _dropdownTextStyle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.dmSans(
      fontSize: 14,
      color: isDarkMode ? Colors.white : const Color(0xff1E293B),
    );
  }

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
      _showSnack('Location added successfully!', isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'Failed to add location!'
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
      _showSnack('Please select or enter a company name!', isError: true);
      return;
    }
    if (busType.isEmpty) {
      _showSnack('Please select or enter a bus type!', isError: true);
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
      _showSnack('Bus added successfully!', isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'Failed to add bus!'
            : _vm.errorMessage.value,
        isError: true,
      );
    }
  }

  Future<void> _submitRoute() async {
    if (!_routeKey.currentState!.validate()) return;
    if (_fromLocationId == null || _toLocationId == null) {
      _showSnack('Please select both locations!', isError: true);
      return;
    }
    if (_fromLocationId == _toLocationId) {
      _showSnack('From and To locations must be different!', isError: true);
      return;
    }
    final from = _vm.locations.firstWhere((l) => l.id == _fromLocationId);
    final to = _vm.locations.firstWhere((l) => l.id == _toLocationId);
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
      _showSnack('Route added successfully!', isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'Failed to add route!'
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
      _showSnack('Please fill all schedule fields!', isError: true);
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
      _showSnack('Bus schedule added successfully!', isError: false);
      _vm.loadOptions();
    } else {
      _showSnack(
        _vm.errorMessage.value.isEmpty
            ? 'Failed to add bus schedule!'
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? (isDarkMode ? AppColors.darkAlertText : AppColors.lightAlertText)
            : AppColors.primary,
        content: Text(message, style: GoogleFonts.dmSans(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final primaryText = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDarkMode
              ? const Color(0xFF94A3B8)
              : const Color(0xff64748B),
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
          isScrollable: true,
          tabs: const [
            Tab(
              icon: FaIcon(FontAwesomeIcons.chartPie, size: 14),
              text: 'Overview',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.locationDot, size: 14),
              text: 'Location',
            ),
            Tab(icon: FaIcon(FontAwesomeIcons.bus, size: 14), text: 'Bus'),
            Tab(
              icon: FaIcon(FontAwesomeIcons.arrowRightArrowLeft, size: 14),
              text: 'Route',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.calendarDays, size: 14),
              text: 'Schedule',
            ),
            Tab(
              icon: FaIcon(FontAwesomeIcons.ticket, size: 14),
              text: 'Bookings',
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (_vm.isLoadingOptions.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  'Loading dashboard data...',
                  style: GoogleFonts.dmSans(color: primaryText),
                ),
              ],
            ),
          );
        }
        if (_vm.errorMessage.value.isNotEmpty &&
            _vm.locations.isEmpty &&
            _vm.buses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _vm.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(color: primaryText),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _vm.loadOptions,
                  icon: const FaIcon(FontAwesomeIcons.rotate, size: 16),
                  label: const Text('Retry'),
                ),
              ],
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
    );
  }

  Widget _buildOverviewTab() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDarkMode
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;
    final primaryText = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final availableSchedules = _vm.schedules
        .where((s) => s.status == BusScheduleStatus.Available)
        .length;
    final bookedSchedules = _vm.schedules
        .where((s) => s.status == BusScheduleStatus.Booked)
        .length;

    final summaryCards = [
      _SummaryCardData(
        label: 'Buses',
        count: _vm.buses.length,
        icon: FontAwesomeIcons.bus,
        color: const Color(0xff3B82F6),
      ),
      _SummaryCardData(
        label: 'Routes',
        count: _vm.routes.length,
        icon: FontAwesomeIcons.arrowRightArrowLeft,
        color: const Color(0xff8B5CF6),
      ),
      _SummaryCardData(
        label: 'Schedules',
        count: _vm.schedules.length,
        icon: FontAwesomeIcons.calendarDays,
        color: const Color(0xffF59E0B),
      ),
      _SummaryCardData(
        label: 'Companies',
        count: _vm.companies.length,
        icon: FontAwesomeIcons.building,
        color: const Color(0xff10B981),
      ),
      _SummaryCardData(
        label: 'Locations',
        count: _vm.locations.length,
        icon: FontAwesomeIcons.locationDot,
        color: const Color(0xffEF4444),
      ),
      _SummaryCardData(
        label: 'Bus Types',
        count: _vm.busTypes.length,
        icon: FontAwesomeIcons.sitemap,
        color: const Color(0xff06B6D4),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dashboard Overview',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Summary of all your fleet data',
            style: GoogleFonts.dmSans(fontSize: 13, color: secondaryText),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: summaryCards.length,
            itemBuilder: (context, index) {
              final card = summaryCards[index];
              return _buildSummaryCard(
                card,
                cardBg,
                primaryText,
                secondaryText,
              );
            },
          ),
          const SizedBox(height: 28),
          if (_vm.buses.isNotEmpty) ...[
            _buildSectionHeader('Recent Buses', primaryText, secondaryText),
            const SizedBox(height: 10),
            ..._vm.buses
                .take(5)
                .map(
                  (bus) => _buildBusListTile(
                    bus,
                    cardBg,
                    primaryText,
                    secondaryText,
                  ),
                ),
            const SizedBox(height: 20),
          ],
          if (_vm.routes.isNotEmpty) ...[
            _buildSectionHeader('Recent Routes', primaryText, secondaryText),
            const SizedBox(height: 10),
            ..._vm.routes
                .take(5)
                .map(
                  (route) => _buildRouteListTile(
                    route,
                    cardBg,
                    primaryText,
                    secondaryText,
                  ),
                ),
            const SizedBox(height: 20),
          ],
          if (_vm.schedules.isNotEmpty) ...[
            _buildSectionHeader('Recent Schedules', primaryText, secondaryText),
            const SizedBox(height: 10),
            ..._vm.schedules
                .take(5)
                .map(
                  (schedule) => _buildScheduleListTile(
                    schedule,
                    cardBg,
                    primaryText,
                    secondaryText,
                  ),
                ),
          ],
          const SizedBox(height: 16),
          if (availableSchedules > 0 || bookedSchedules > 0) ...[
            _buildSectionHeader('Schedule Stats', primaryText, secondaryText),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    'Available',
                    availableSchedules,
                    const Color(0xff10B981),
                    cardBg,
                    primaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatChip(
                    'Booked',
                    bookedSchedules,
                    const Color(0xffF59E0B),
                    cardBg,
                    primaryText,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    _SummaryCardData card,
    Color cardBg,
    Color primaryText,
    Color secondaryText,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(card.icon, color: card.color, size: 18),
          const Spacer(),
          Text(
            '${card.count}',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          Text(
            card.label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      children: [
        FaIcon(FontAwesomeIcons.listUl, size: 13, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildBusListTile(
    dynamic bus,
    Color cardBg,
    Color primaryText,
    Color secondaryText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xff3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.bus,
                size: 14,
                color: Color(0xff3B82F6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.plateNumber,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                Text(
                  '${bus.companyName} - ${bus.busType}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: secondaryText),
                ),
              ],
            ),
          ),
          Text(
            '${bus.seatCapacity} seats',
            style: GoogleFonts.dmSans(fontSize: 11, color: secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteListTile(
    dynamic route,
    Color cardBg,
    Color primaryText,
    Color secondaryText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xff8B5CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.arrowRightArrowLeft,
                size: 14,
                color: Color(0xff8B5CF6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${route.fromLocation} → ${route.toLocation}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleListTile(
    BusSchedule schedule,
    Color cardBg,
    Color primaryText,
    Color secondaryText,
  ) {
    final isAvailable = schedule.status == BusScheduleStatus.Available;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  (isAvailable
                          ? const Color(0xff10B981)
                          : const Color(0xffF59E0B))
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.calendarDays,
                size: 14,
                color: isAvailable
                    ? const Color(0xff10B981)
                    : const Color(0xffF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.fromLocation} → ${schedule.toLocation}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                Text(
                  '${schedule.plateNumber} | ${schedule.formattedDate} | ${schedule.departureTime.substring(0, 5)}',
                  style: GoogleFonts.dmSans(fontSize: 11, color: secondaryText),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:
                  (isAvailable
                          ? const Color(0xff10B981)
                          : const Color(0xffF59E0B))
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              schedule.status.name,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isAvailable
                    ? const Color(0xff10B981)
                    : const Color(0xffF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    String label,
    int count,
    Color color,
    Color cardBg,
    Color primaryText,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            '$count',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: primaryText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDarkMode
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;
    final primaryText = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.ticket, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'All Bookings',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const Spacer(),
              Text(
                '${_vm.bookings.length} total',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'View all customer bookings',
            style: GoogleFonts.dmSans(fontSize: 13, color: secondaryText),
          ),
          const SizedBox(height: 20),
          if (_vm.bookings.isEmpty && _vm.bookingError.value.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      size: 32,
                      color: const Color(0xffEF4444),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load bookings',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xffEF4444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _vm.bookingError.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _vm.loadOptions,
                      icon: const FaIcon(FontAwesomeIcons.rotate, size: 14),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_vm.bookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.ticket,
                      size: 32,
                      color: secondaryText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No bookings yet',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._vm.bookings.map(
              (booking) => _buildBookingCard(
                booking,
                cardBg,
                primaryText,
                secondaryText,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    BookingResponse booking,
    Color cardBg,
    Color primaryText,
    Color secondaryText,
  ) {
    final statusColor = switch (booking.bookingStatus) {
      BookingStatus.Pending => const Color(0xffF59E0B),
      BookingStatus.Confirmed => const Color(0xff10B981),
      BookingStatus.Cancelled => const Color(0xffEF4444),
    };

    final statusLabel = switch (booking.bookingStatus) {
      BookingStatus.Pending => 'Pending',
      BookingStatus.Confirmed => 'Confirmed',
      BookingStatus.Cancelled => 'Cancelled',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xff3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 14,
                    color: Color(0xff3B82F6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.username,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    Text(
                      'ID: #${booking.id}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.route,
                  size: 12,
                  color: Color(0xff3B82F6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${booking.fromLocation} → ${booking.toLocation}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _bookingInfoChip(
                FontAwesomeIcons.calendarDays,
                DateFormat('MMM dd, yyyy').format(booking.travelDate),
                secondaryText,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.clock,
                '${booking.departureTime.substring(0, 5)} - ${booking.arrivalTime.substring(0, 5)}',
                secondaryText,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.ticket,
                booking.seatNumbers.join(', '),
                secondaryText,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.moneyBill1,
                '\$${booking.totalAmount.toStringAsFixed(2)}',
                secondaryText,
              ),
              _bookingInfoChip(
                FontAwesomeIcons.creditCard,
                booking.paymentMethod,
                secondaryText,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Booked on ${DateFormat('MMM dd, yyyy').format(booking.bookingDate)}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingInfoChip(FaIconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.dmSans(fontSize: 11, color: color),
        ),
      ],
    );
  }

  Widget _buildLocationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _locationKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _locationNameController,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                label: 'Location name',
                icon: FontAwesomeIcons.mapLocationDot,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Location name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationImageUrlController,
              textInputAction: TextInputAction.done,
              decoration: _fieldDecoration(
                label: 'Image URL',
                icon: FontAwesomeIcons.image,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Image URL is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _submitButton(
              _vm.isSubmitting.value,
              _submitLocation,
              'Add Location',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _busKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_vm.companies.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No companies available. Companies will be auto-created if needed.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ),
            DropdownButtonFormField<int>(
              initialValue: _selectedCompanyId,
              decoration: _dropdownDecoration(
                label: 'Company',
                icon: FontAwesomeIcons.building,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: _vm.companies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.companyName,
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
                    final company = _vm.companies.firstWhere((c) => c.id == v);
                    _busCompanyNameController.text = company.companyName;
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _busCompanyNameController,
              decoration: _fieldDecoration(
                label: 'Or type new company name',
                icon: FontAwesomeIcons.pen,
              ),
              onChanged: (v) {
                if (v.trim().isNotEmpty) {
                  setState(() => _selectedCompanyId = null);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_vm.busTypes.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No bus types available. Bus types will be auto-created if needed.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ),
            DropdownButtonFormField<int>(
              initialValue: _selectedBusTypeId,
              decoration: _dropdownDecoration(
                label: 'Bus Type',
                icon: FontAwesomeIcons.sitemap,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: _vm.busTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.busType, style: _dropdownTextStyle()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedBusTypeId = v;
                  if (v != null) {
                    final busType = _vm.busTypes.firstWhere((t) => t.id == v);
                    _busTypeNameController.text = busType.busType;
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _busTypeNameController,
              decoration: _fieldDecoration(
                label: 'Or type new bus type',
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
                label: 'Plate number',
                icon: FontAwesomeIcons.idCard,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Plate number is required';
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
                label: 'Seat capacity',
                icon: FontAwesomeIcons.users,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Seat capacity is required';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _busImageUrlController,
              textInputAction: TextInputAction.done,
              decoration: _fieldDecoration(
                label: 'Image URL (optional)',
                icon: FontAwesomeIcons.image,
              ),
            ),
            const SizedBox(height: 24),
            _submitButton(_vm.isSubmitting.value, _submitBus, 'Add Bus'),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _routeKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_vm.locations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'No locations available yet. Add a location first.',
                  style: GoogleFonts.dmSans(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ),
            DropdownButtonFormField<int>(
              initialValue: _fromLocationId,
              decoration: _dropdownDecoration(
                label: 'From Location',
                icon: FontAwesomeIcons.locationDot,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: _vm.locations
                  .map(
                    (l) => DropdownMenuItem(
                      value: l.id,
                      child: Text(
                        l.locationName,
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
              initialValue: _toLocationId,
              decoration: _dropdownDecoration(
                label: 'To Location',
                icon: FontAwesomeIcons.flag,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: _vm.locations
                  .map(
                    (l) => DropdownMenuItem(
                      value: l.id,
                      child: Text(
                        l.locationName,
                        style: _dropdownTextStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _toLocationId = v),
            ),
            const SizedBox(height: 24),
            _submitButton(_vm.isSubmitting.value, _submitRoute, 'Add Route'),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _scheduleKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _selectedBusId,
              decoration: _dropdownDecoration(
                label: 'Bus',
                icon: FontAwesomeIcons.bus,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: _vm.buses
                  .map(
                    (b) => DropdownMenuItem(
                      value: b.id,
                      child: Text(
                        '${b.plateNumber} - ${b.companyName}',
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
              initialValue: _selectedRouteId,
              decoration: _dropdownDecoration(
                label: 'Route',
                icon: FontAwesomeIcons.arrowRightArrowLeft,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: _vm.routes
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        '${r.fromLocation} → ${r.toLocation}',
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
              initialValue: _selectedScheduleBusTypeId,
              decoration: _dropdownDecoration(
                label: 'Bus Type',
                icon: FontAwesomeIcons.sitemap,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: _vm.busTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.busType, style: _dropdownTextStyle()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedScheduleBusTypeId = v),
            ),
            const SizedBox(height: 16),
            _pickerField(
              label: 'Travel Date',
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
                    label: 'Departure',
                    icon: FontAwesomeIcons.clock,
                    value: _departureTime == null
                        ? null
                        : _formatTime(_departureTime!).substring(0, 5),
                    onTap: _pickDepartureTime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _pickerField(
                    label: 'Arrival',
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
            TextFormField(
              controller: _scheduleSeatController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                label: 'Available seats',
                icon: FontAwesomeIcons.users,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Available seats is required';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                label: 'Base price',
                icon: FontAwesomeIcons.moneyBill1,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Base price is required';
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: _dropdownDecoration(
                label: 'Status',
                icon: FontAwesomeIcons.circleInfo,
              ),
              dropdownColor: isDark
                  ? AppColors.darkInputField
                  : AppColors.lightInputField,
              items: const ['Available', 'Booked']
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: _dropdownTextStyle()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 24),
            _submitButton(
              _vm.isSubmitting.value,
              _submitSchedule,
              'Add Schedule',
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required FaIconData icon,
    required String? value,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _fieldDecoration(label: label, icon: icon),
        child: Text(
          value ?? 'Select',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: value == null
                ? secondaryText
                : isDarkMode
                ? Colors.white
                : const Color(0xff1E293B),
          ),
        ),
      ),
    );
  }

  Widget _submitButton(bool isLoading, VoidCallback? onPressed, String label) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              )
            : Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
} 

class _SummaryCardData {
  final String label;
  final int count;
  final FaIconData icon;
  final Color color;

  const _SummaryCardData({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });
}
