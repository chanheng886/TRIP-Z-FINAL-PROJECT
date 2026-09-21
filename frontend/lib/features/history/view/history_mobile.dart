import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/model/bus.dart';
import 'package:frontend/features/admin/model/bus_route.dart';
import 'package:frontend/features/history/viewmodel/booking_history_viewmodel.dart';
import 'package:frontend/features/history/widgets/admin_bus_card.dart';
import 'package:frontend/features/history/widgets/admin_route_card.dart';
import 'package:frontend/features/history/widgets/admin_schedule_card.dart';
import 'package:frontend/features/history/widgets/customer_booking_card.dart';
import 'package:frontend/features/history/widgets/history_empty_state.dart';
import 'package:frontend/features/history/widgets/history_guest_view.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:frontend/shared/service/booking_service.dart';
import 'package:get/get.dart';

class HistoryMobile extends StatefulWidget {
  const HistoryMobile({super.key});

  @override
  State<HistoryMobile> createState() => _HistoryMobileState();
}

class _HistoryMobileState extends State<HistoryMobile> {
  final controller = Get.put(
    BookingHistoryViewmodel(BookingRepository(BookingService())),
  );

  @override
  void initState() {
    super.initState();
    controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (controller.isAdmin) {
      return _buildAdminHistory(context, theme, colorScheme);
    }
    return _buildCustomerHistory(context, theme, colorScheme);
  }

  // ─────────────────────── ADMIN HISTORY ───────────────────────

  Widget _buildAdminHistory(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'Activity History',
            style: AppFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                splashRadius: 22,
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222B) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C3240)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.arrowsRotate,
                      size: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                onPressed: () => controller.loadData(),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222B) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C3240)
                        : const Color(0xFFE2E8F0),
                    width: 1,
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
                child: TabBar(
                  dividerHeight: 0,
                  splashBorderRadius: BorderRadius.circular(26),
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.green, AppColors.greenBright],
                    ),
                    borderRadius: BorderRadius.circular(26),
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
                  unselectedLabelColor: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  labelStyle: AppFonts.dmSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: AppFonts.dmSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      child: Obx(
                        () => _buildAdminTabItem(
                          icon: FontAwesomeIcons.bus,
                          label: 'Buses',
                          count: controller.buses.length,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    Tab(
                      child: Obx(
                        () => _buildAdminTabItem(
                          icon: FontAwesomeIcons.route,
                          label: 'Routes',
                          count: controller.routes.length,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    Tab(
                      child: Obx(
                        () => _buildAdminTabItem(
                          icon: FontAwesomeIcons.calendarDays,
                          label: 'Schedules',
                          count: controller.schedules.length,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
            return _buildErrorState(colorScheme);
          }

          return TabBarView(
            children: [
              _buildBusList(controller.buses, colorScheme),
              _buildRouteList(controller.routes, colorScheme),
              _buildScheduleList(controller.schedules, colorScheme),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAdminTabItem({
    required dynamic icon,
    required String label,
    required int count,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 12),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: AppFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusList(List<Bus> buses, ColorScheme colorScheme) {
    if (buses.isEmpty) {
      return const HistoryEmptyState(
        icon: FontAwesomeIcons.bus,
        title: 'No buses yet',
        subtitle: 'Buses you add will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: buses.length,
        itemBuilder: (context, index) {
          return AdminBusCard(bus: buses[index]);
        },
      ),
    );
  }

  Widget _buildRouteList(List<BusRoute> routes, ColorScheme colorScheme) {
    if (routes.isEmpty) {
      return const HistoryEmptyState(
        icon: FontAwesomeIcons.arrowRightArrowLeft,
        title: 'No routes yet',
        subtitle: 'Routes you add will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          return AdminRouteCard(route: routes[index]);
        },
      ),
    );
  }

  Widget _buildScheduleList(
    List<BusSchedule> schedules,
    ColorScheme colorScheme,
  ) {
    if (schedules.isEmpty) {
      return const HistoryEmptyState(
        icon: FontAwesomeIcons.calendarDays,
        title: 'No schedules yet',
        subtitle: 'Schedules you add will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return AdminScheduleCard(schedule: schedules[index]);
        },
      ),
    );
  }

  // ─────────────────────── CUSTOMER HISTORY ───────────────────────

  Widget _buildCustomerHistory(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'my_tickets'.tr,
          style: AppFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.arrowsRotate,
              size: 16,
              color: colorScheme.onSurface,
            ),
            onPressed: () => controller.loadData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isGuest) {
          return HistoryGuestView(
            onLoginSuccess: () => controller.loadData(),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState(colorScheme);
        }

        if (controller.bookings.isEmpty) {
          return HistoryEmptyState(
            icon: FontAwesomeIcons.ticket,
            title: 'no_history_title'.tr,
            subtitle: 'no_history_subtitle'.tr,
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: controller.bookings.length,
            itemBuilder: (context, index) {
              return CustomerBookingCard(
                booking: controller.bookings[index],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 40,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              controller.error.value,
              textAlign: TextAlign.center,
              style: AppFonts.dmSans(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadData(),
              child: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}