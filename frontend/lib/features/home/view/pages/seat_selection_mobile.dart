import 'package:flutter/material.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:frontend/features/home/repository/bus_schedule_repository.dart';
import 'package:frontend/features/home/viewmodel/booking_view_model.dart';
import 'package:frontend/features/home/view/widgets/booking_form_widget.dart';
import 'package:frontend/features/home/view/widgets/bus_vehicle_layout.dart';
import 'package:frontend/features/home/view/widgets/minivan_vehicle_layout.dart';
import 'package:frontend/shared/service/booking_service.dart';
import 'package:frontend/shared/service/bus_schedule_serivice.dart';
import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

class SeatSelectionMobile extends StatefulWidget {
  final int busScheduleId;
  final double basePrice;
  final String fromLocation;
  final String toLocation;
  final String? busType;
  final String? companyName;

  const SeatSelectionMobile({
    super.key,
    required this.busScheduleId,
    required this.basePrice,
    required this.fromLocation,
    required this.toLocation,
    this.busType,
    this.companyName,
  });

  @override
  State<SeatSelectionMobile> createState() => _SeatSelectionMobileState();
}

class _SeatSelectionMobileState extends State<SeatSelectionMobile> {
  final controller = Get.put(
    BookingViewmodel(
      BusScheduleRepository(BusScheduleService()),
      BookingRepository(BookingService()),
    ),
  );

  @override
  void initState() {
    super.initState();
    controller.loadSeatMap(widget.busScheduleId, busType: widget.busType);
  }

  bool get _isMinivan {
    final type = widget.busType?.toLowerCase() ?? '';
    return type.contains('van') || type.contains('minivan');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'seat_selection'.tr,
              style: AppFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.fromLocation.trDb,
                  style: AppFonts.dmSans(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: colorScheme.primary,
                ),
                Text(
                  widget.toLocation.trDb,
                  style: AppFonts.dmSans(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingSeats.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading vehicle layout...',
                  style: AppFonts.dmSans(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.seatMapError.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  'Failed to load vehicle seat map',
                  style: AppFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => controller.loadSeatMap(
                    widget.busScheduleId,
                    busType: widget.busType,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final seatMap = controller.seatMap.value;
        if (seatMap == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // Vehicle Info & Legend Header
            _buildVehicleBanner(context, isDark, colorScheme),

            // Scrollable Vehicle Cabin Interior
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _isMinivan
                    ? MinivanVehicleLayout(
                        seatMap: seatMap,
                        selectedSeats: controller.selectedSeats,
                        onSeatSelected: (seat) => controller.toggleSeat(seat),
                      )
                    : BusVehicleLayout(
                        seatMap: seatMap,
                        selectedSeats: controller.selectedSeats,
                        onSeatSelected: (seat) => controller.toggleSeat(seat),
                      ),
              ),
            ),

            // Bottom Checkout / Summary Bar
            _buildSummaryBar(context, colorScheme, isDark),
          ],
        );
      }),
    );
  }

  Widget _buildVehicleBanner(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final vehicleTitle =
        widget.busType ?? (_isMinivan ? 'VIP Minivan' : 'Express Coach Bus');
    final company = widget.companyName ?? 'Standard Operator';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          // Vehicle Type Badge & Operator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isMinivan
                          ? Icons.airport_shuttle_rounded
                          : Icons.directions_bus_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleTitle,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        company,
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Available seats counter badge
              Obx(() {
                final seatMap = controller.seatMap.value;
                final availableCount = seatMap?.availableSeats.length ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '$availableCount Seats Left',
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 10),

          // Interactive Status Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendItem(
                context,
                const Color(0xFF10B981),
                'selected'.tr,
                icon: Icons.check_rounded,
                isDark: isDark,
              ),
              _legendItem(
                context,
                isDark ? const Color(0xFF262C3A) : const Color(0xFFE2E8F0),
                'booked'.tr,
                icon: Icons.close_rounded,
                border: true,
                isDark: isDark,
              ),
              _legendItem(
                context,
                isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                'available'.tr,
                border: true,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    BuildContext context,
    Color color,
    String label, {
    bool border = false,
    IconData? icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border
                ? Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                  )
                : null,
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: 11,
                  color: label == 'Selected'
                      ? Colors.white
                      : (isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8)),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Obx(() {
      final selectedList = controller.selectedSeats;
      final count = selectedList.length;
      final total = count * widget.basePrice;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161922) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected Seat Chips Preview
              if (count > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        'Seats: ',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: selectedList.map((seat) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  seat,
                                  style: AppFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Price Calculation & Continue CTA Button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count seat${count == 1 ? '' : 's'} selected',
                          style: AppFonts.dmSans(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: AppFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: count > 0 ? 3 : 0,
                    ),
                    onPressed: count == 0
                        ? null
                        : () {
                            showBookingFormSheet(
                              context,
                              controller: controller,
                              busScheduleId: widget.busScheduleId,
                              basePrice: widget.basePrice,
                            );
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: AppFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
