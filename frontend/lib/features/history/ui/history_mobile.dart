import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/admin/models/bus.dart';
import 'package:frontend/features/admin/models/bus_route.dart';
import 'package:frontend/features/history/viewmodel/booking_history_viewmodel.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/features/home/models/bus_schedule.dart';
import 'package:frontend/features/home/presentation/ticket_screen.dart';
import 'package:frontend/shared/services/booking_service.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
          centerTitle: true,
          title: Text(
            'Activity History',
            style: GoogleFonts.dmSans(
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
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
            indicatorColor: colorScheme.primary,
            labelStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
            tabs: const [
              Tab(text: 'Buses'),
              Tab(text: 'Routes'),
              Tab(text: 'Schedules'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty) {
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
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.loadData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            children: [
              _buildBusList(controller.buses, isDark, colorScheme),
              _buildRouteList(controller.routes, isDark, colorScheme),
              _buildScheduleList(controller.schedules, isDark, colorScheme),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBusList(
    List<Bus> buses,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (buses.isEmpty) {
      return _buildEmptyState(
        FontAwesomeIcons.bus,
        'No buses yet',
        'Buses you add will appear here',
        colorScheme,
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: buses.length,
        itemBuilder: (context, index) {
          final bus = buses[index];
          return _buildBusCard(bus, isDark, colorScheme);
        },
      ),
    );
  }

  Widget _buildBusCard(Bus bus, bool isDark, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2126) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              color: const Color(0xff3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.bus,
                size: 18,
                color: Color(0xff3B82F6),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.plateNumber,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bus.companyName} • ${bus.busType}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${bus.seatCapacity} seats',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList(
    List<BusRoute> routes,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (routes.isEmpty) {
      return _buildEmptyState(
        FontAwesomeIcons.arrowRightArrowLeft,
        'No routes yet',
        'Routes you add will appear here',
        colorScheme,
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return _buildRouteCard(route, isDark, colorScheme);
        },
      ),
    );
  }

  Widget _buildRouteCard(
    BusRoute route,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2126) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              color: const Color(0xff8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.arrowRightArrowLeft,
                size: 18,
                color: Color(0xff8B5CF6),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${route.fromLocation} → ${route.toLocation}',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Route #${route.id}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          FaIcon(
            FontAwesomeIcons.chevronRight,
            size: 14,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(
    List<BusSchedule> schedules,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (schedules.isEmpty) {
      return _buildEmptyState(
        FontAwesomeIcons.calendarDays,
        'No schedules yet',
        'Schedules you add will appear here',
        colorScheme,
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return _buildScheduleCard(schedule, isDark, colorScheme);
        },
      ),
    );
  }

  Widget _buildScheduleCard(
    BusSchedule schedule,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final isAvailable = schedule.status == BusScheduleStatus.Available;
    final statusColor = isAvailable
        ? const Color(0xff22C55E)
        : const Color(0xffF59E0B);
    final dateStr =
        '${schedule.travelDate.day.toString().padLeft(2, '0')}/${schedule.travelDate.month.toString().padLeft(2, '0')}/${schedule.travelDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2126) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${schedule.fromLocation} → ${schedule.toLocation}',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule.status.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _infoChip(
                      FontAwesomeIcons.calendarDay,
                      dateStr,
                      colorScheme,
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      FontAwesomeIcons.clock,
                      '${schedule.departureTime.substring(0, 5)} - ${schedule.arrivalTime.substring(0, 5)}',
                      colorScheme,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoChip(
                      FontAwesomeIcons.bus,
                      schedule.plateNumber,
                      colorScheme,
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      FontAwesomeIcons.moneyBill1,
                      '\$${schedule.basePrice.toStringAsFixed(2)}',
                      colorScheme,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _infoChip(
                      FontAwesomeIcons.couch,
                      '${schedule.availableSeat} seats left',
                      colorScheme,
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      FontAwesomeIcons.building,
                      schedule.companyName,
                      colorScheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          'My Bookings',
          style: GoogleFonts.dmSans(
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

        if (controller.error.value.isNotEmpty) {
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
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.ticket,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No bookings yet',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your booked tickets will appear here',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.bookings.length,
            itemBuilder: (context, index) {
              final booking = controller.bookings[index];
              return _buildBookingCard(context, booking, colorScheme, theme);
            },
          ),
        );
      }),
    );
  }

  // ─────────────────────── SHARED WIDGETS ───────────────────────

  Widget _buildBookingCard(
    BuildContext context,
    BookingResponse booking,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final dateStr =
        '${booking.travelDate.day.toString().padLeft(2, '0')}/${booking.travelDate.month.toString().padLeft(2, '0')}/${booking.travelDate.year}';

    return GestureDetector(
      onTap: () {
        Get.to(() => TicketScreen(booking: booking));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2126) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: _statusColor(booking.bookingStatus).withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${booking.fromLocation} → ${booking.toLocation}',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(booking.bookingStatus).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.bookingStatus.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(booking.bookingStatus),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _infoChip(
                        FontAwesomeIcons.calendarDay,
                        dateStr,
                        colorScheme,
                      ),
                      const SizedBox(width: 10),
                      _infoChip(
                        FontAwesomeIcons.clock,
                        booking.departureTime,
                        colorScheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoChip(
                        FontAwesomeIcons.couch,
                        booking.seatNumbers.join(', '),
                        colorScheme,
                      ),
                      const SizedBox(width: 10),
                      _infoChip(
                        FontAwesomeIcons.dollarSign,
                        '\$${booking.totalAmount.toStringAsFixed(2)}',
                        colorScheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Tap to view ticket',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 12,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(FaIconData icon, String text, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FaIcon(icon, size: 12, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    FaIconData icon,
    String title,
    String subtitle,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.Confirmed:
        return const Color(0xff22C55E);
      case BookingStatus.Pending:
        return const Color(0xffF59E0B);
      case BookingStatus.Cancelled:
        return const Color(0xffEF4444);
    }
  }
}
