import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/view/admin_all_schedules_screen.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_hero_banner.dart';
import 'package:frontend/features/admin/widgets/admin_list_tiles.dart';
import 'package:frontend/features/admin/widgets/admin_quick_actions.dart';
import 'package:frontend/features/admin/widgets/admin_schedule_capacity_card.dart';
import 'package:frontend/features/admin/widgets/admin_section_header.dart';
import 'package:frontend/features/admin/widgets/admin_summary_card.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';

class AdminOverviewTab extends StatelessWidget {
  final AdminDashboardViewmodel viewModel;
  final ValueChanged<int> onNavigateToTab;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;

  const AdminOverviewTab({
    super.key,
    required this.viewModel,
    required this.onNavigateToTab,
    required this.isDark,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final availableSchedules = viewModel.schedules
        .where((s) => !s.isExpired && s.status == BusScheduleStatus.Available)
        .length;
    final bookedSchedules = viewModel.schedules
        .where((s) => s.status == BusScheduleStatus.Booked)
        .length;
    final confirmedBookings = viewModel.bookings
        .where(
          (b) =>
              b.bookingStatus == BookingStatus.Confirmed ||
              b.bookingStatus == BookingStatus.Paid,
        )
        .length;
    final totalRevenue = viewModel.bookings
        .where(
          (b) =>
              b.bookingStatus == BookingStatus.Confirmed ||
              b.bookingStatus == BookingStatus.Paid,
        )
        .fold<double>(0.0, (sum, b) => sum + b.totalAmount);

    final summaryCards = [
      SummaryCardData(
        label: 'fleet_buses',
        count: viewModel.buses.length,
        icon: FontAwesomeIcons.bus,
        color: AppColors.green,
        tabIndex: 2,
      ),
      SummaryCardData(
        label: 'active_routes',
        count: viewModel.routes.length,
        icon: FontAwesomeIcons.road,
        color: AppColors.greenBright,
        tabIndex: 3,
      ),
      SummaryCardData(
        label: 'trips_scheduled',
        count: viewModel.schedules.length,
        icon: FontAwesomeIcons.calendarDays,
        color: AppColors.green,
        tabIndex: 4,
      ),
      SummaryCardData(
        label: 'companies',
        count: viewModel.companies.length,
        icon: FontAwesomeIcons.building,
        color: AppColors.greenBright,
        tabIndex: 2,
      ),
      SummaryCardData(
        label: 'locations',
        count: viewModel.locations.length,
        icon: FontAwesomeIcons.locationDot,
        color: AppColors.green,
        tabIndex: 1,
      ),
      SummaryCardData(
        label: 'bus_types',
        count: viewModel.busTypes.length,
        icon: FontAwesomeIcons.sitemap,
        color: AppColors.greenBright,
        tabIndex: 2,
      ),
    ];

    final quickActions = [
      QuickActionItem(
        label: 'quick_add_location',
        icon: FontAwesomeIcons.locationDot,
        onTap: () => onNavigateToTab(1),
      ),
      QuickActionItem(
        label: 'quick_add_bus',
        icon: FontAwesomeIcons.bus,
        onTap: () => onNavigateToTab(2),
      ),
      QuickActionItem(
        label: 'quick_add_route',
        icon: FontAwesomeIcons.road,
        onTap: () => onNavigateToTab(3),
      ),
      QuickActionItem(
        label: 'quick_add_schedule',
        icon: FontAwesomeIcons.calendarPlus,
        onTap: () => onNavigateToTab(4),
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
            totalBookings: viewModel.bookings.length,
            confirmedBookings: confirmedBookings,
            totalBuses: viewModel.buses.length,
            totalRoutes: viewModel.routes.length,
            isDark: isDark,
            onViewBookings: () => onNavigateToTab(5),
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
                onCardTap: onNavigateToTab,
              );
            },
          ),
          const SizedBox(height: 20),

          // Schedule Capacity Split
          if (viewModel.schedules.isNotEmpty) ...[
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
          if (viewModel.schedules.isNotEmpty) ...[
            AdminSectionHeader(
              title: 'recent_schedules',
              icon: FontAwesomeIcons.calendarDays,
              primaryText: primaryText,
              onViewAll: () =>
                  Get.to(() => AdminAllSchedulesScreen(viewModel: viewModel)),
            ),
            const SizedBox(height: 10),
            ...viewModel.schedules
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
          if (viewModel.buses.isNotEmpty) ...[
            AdminSectionHeader(
              title: 'recent_fleet_buses',
              icon: FontAwesomeIcons.bus,
              primaryText: primaryText,
              onViewAll: () => onNavigateToTab(2),
            ),
            const SizedBox(height: 10),
            ...viewModel.buses
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
          if (viewModel.routes.isNotEmpty) ...[
            AdminSectionHeader(
              title: 'active_routes',
              icon: FontAwesomeIcons.road,
              primaryText: primaryText,
              onViewAll: () => onNavigateToTab(3),
            ),
            const SizedBox(height: 10),
            ...viewModel.routes
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
}
