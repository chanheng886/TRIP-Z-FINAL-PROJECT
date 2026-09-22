import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/repository/admin_dashboard_repository.dart';
import 'package:frontend/features/admin/service/admin_dashboard_service.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_bookings_tab.dart';
import 'package:frontend/features/admin/widgets/admin_bus_form_tab.dart';
import 'package:frontend/features/admin/widgets/admin_header.dart';
import 'package:frontend/features/admin/widgets/admin_location_form_tab.dart';
import 'package:frontend/features/admin/widgets/admin_overview_tab.dart';
import 'package:frontend/features/admin/widgets/admin_route_form_tab.dart';
import 'package:frontend/features/admin/widgets/admin_schedule_form_tab.dart';
import 'package:frontend/features/admin/widgets/admin_tab_bar.dart';
import 'package:get/get.dart';

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
                    AdminOverviewTab(
                      viewModel: _vm,
                      onNavigateToTab: _navigateToTab,
                      isDark: isDark,
                      cardBackground: cardBackground,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                    ),
                    AdminLocationFormTab(
                      viewModel: _vm,
                      isDark: isDark,
                      cardBackground: cardBackground,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                      onShowSnack: _showSnack,
                    ),
                    AdminBusFormTab(
                      viewModel: _vm,
                      isDark: isDark,
                      cardBackground: cardBackground,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                      onShowSnack: _showSnack,
                    ),
                    AdminRouteFormTab(
                      viewModel: _vm,
                      isDark: isDark,
                      cardBackground: cardBackground,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                      onShowSnack: _showSnack,
                    ),
                    AdminScheduleFormTab(
                      viewModel: _vm,
                      isDark: isDark,
                      cardBackground: cardBackground,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                      onShowSnack: _showSnack,
                    ),
                    AdminBookingsTab(
                      viewModel: _vm,
                      isDark: isDark,
                      cardBackground: cardBackground,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      borderColor: borderColor,
                      onShowSnack: _showSnack,
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
