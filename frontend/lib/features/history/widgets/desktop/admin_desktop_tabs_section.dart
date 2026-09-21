import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/model/bus.dart';
import 'package:frontend/features/admin/model/bus_route.dart';
import 'package:frontend/features/history/widgets/admin_bus_card.dart';
import 'package:frontend/features/history/widgets/admin_route_card.dart';
import 'package:frontend/features/history/widgets/admin_schedule_card.dart';
import 'package:frontend/features/history/widgets/history_empty_state.dart';
import 'package:frontend/shared/model/bus_schedule.dart';

class AdminDesktopTabsSection extends StatelessWidget {
  final List<Bus> buses;
  final List<BusRoute> routes;
  final List<BusSchedule> schedules;
  final bool isLoading;
  final Color cardBg;
  final Color borderColor;
  final Color textSecondary;
  final bool isDark;

  const AdminDesktopTabsSection({
    super.key,
    required this.buses,
    required this.routes,
    required this.schedules,
    required this.isLoading,
    required this.cardBg,
    required this.borderColor,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Segmented Desktop TabBar
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              dividerHeight: 0,
              splashBorderRadius: BorderRadius.circular(12),
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green, AppColors.greenBright],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: textSecondary,
              labelStyle: AppFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: AppFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: _buildDesktopTabLabel(
                    label: 'Buses',
                    count: buses.length,
                    icon: FontAwesomeIcons.bus,
                  ),
                ),
                Tab(
                  child: _buildDesktopTabLabel(
                    label: 'Routes',
                    count: routes.length,
                    icon: FontAwesomeIcons.route,
                  ),
                ),
                Tab(
                  child: _buildDesktopTabLabel(
                    label: 'Schedules',
                    count: schedules.length,
                    icon: FontAwesomeIcons.calendarCheck,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tab Content Views
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  )
                : TabBarView(
                    children: [
                      _buildDesktopBusesGrid(buses),
                      _buildDesktopRoutesGrid(routes),
                      _buildDesktopSchedulesGrid(schedules),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTabLabel({
    required String label,
    required int count,
    required FaIconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 14),
        const SizedBox(width: 8),
        Text(label),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBusesGrid(List<Bus> buses) {
    if (buses.isEmpty) {
      return const HistoryEmptyState(
        icon: FontAwesomeIcons.bus,
        title: 'No buses registered',
        subtitle: 'Buses added by operators will appear here.',
      );
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 145,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: buses.length,
      itemBuilder: (context, index) => AdminBusCard(bus: buses[index]),
    );
  }

  Widget _buildDesktopRoutesGrid(List<BusRoute> routes) {
    if (routes.isEmpty) {
      return const HistoryEmptyState(
        icon: FontAwesomeIcons.arrowRightArrowLeft,
        title: 'No routes defined',
        subtitle: 'Inter-provincial routes created will appear here.',
      );
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 115,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: routes.length,
      itemBuilder: (context, index) => AdminRouteCard(route: routes[index]),
    );
  }

  Widget _buildDesktopSchedulesGrid(List<BusSchedule> schedules) {
    if (schedules.isEmpty) {
      return const HistoryEmptyState(
        icon: FontAwesomeIcons.calendarDays,
        title: 'No schedules active',
        subtitle: 'Upcoming scheduled trips will appear here.',
      );
    }
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 540,
        mainAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: schedules.length,
      itemBuilder: (context, index) =>
          AdminScheduleCard(schedule: schedules[index]),
    );
  }
}
