import 'package:flutter/material.dart';
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
import 'package:google_fonts/google_fonts.dart';

class SeatSelectionDesktop extends StatefulWidget {
  final int busScheduleId;
  final double basePrice;
  final String fromLocation;
  final String toLocation;
  final String? busType;
  final String? companyName;

  const SeatSelectionDesktop({
    super.key,
    required this.busScheduleId,
    required this.basePrice,
    required this.fromLocation,
    required this.toLocation,
    this.busType,
    this.companyName,
  });

  @override
  State<SeatSelectionDesktop> createState() => _SeatSelectionDesktopState();
}

class _SeatSelectionDesktopState extends State<SeatSelectionDesktop> {
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Vehicle Seat Selection',
          style: AppFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
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
                  style: AppFonts.dmSans(fontSize: 14),
                ),
              ],
            ),
          );
        }

        if (controller.seatMapError.value.isNotEmpty) {
          return Center(
            child: Text(
              'Failed to load vehicle seat map',
              style: AppFonts.dmSans(fontSize: 16),
            ),
          );
        }

        final seatMap = controller.seatMap.value;
        if (seatMap == null) return const SizedBox.shrink();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Vehicle Interior View
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161922) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2C3242)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status Legend Bar
                          _buildLegendBar(isDark, colorScheme),
                          const SizedBox(height: 16),

                          // Scrollable Vehicle Interior
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _isMinivan
                                  ? MinivanVehicleLayout(
                                      seatMap: seatMap,
                                      selectedSeats: controller.selectedSeats,
                                      onSeatSelected: (seat) =>
                                          controller.toggleSeat(seat),
                                    )
                                  : BusVehicleLayout(
                                      seatMap: seatMap,
                                      selectedSeats: controller.selectedSeats,
                                      onSeatSelected: (seat) =>
                                          controller.toggleSeat(seat),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right Side: Booking Summary & Details
                  Expanded(
                    flex: 2,
                    child: _buildSummaryPanel(context, isDark, colorScheme),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLegendBar(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(const Color(0xFF22C55E), 'Selected', isDark: isDark),
          _legendItem(
            isDark ? const Color(0xFF1E2430) : const Color(0xFFF1F5F9),
            'Booked',
            border: true,
            isDark: isDark,
          ),
          _legendItem(
            isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            'Available',
            border: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
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
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  )
                : null,
          ),
          child: icon != null
              ? Icon(icon, size: 11, color: Colors.white)
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

  Widget _buildSummaryPanel(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161922) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final selectedList = controller.selectedSeats;
        final count = selectedList.length;
        final total = count * widget.basePrice;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trip Summary',
              style: AppFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Route
            _buildDetailRow(
              'Route',
              '${widget.fromLocation} ➔ ${widget.toLocation}',
              isDark,
            ),
            const SizedBox(height: 12),

            // Vehicle
            _buildDetailRow(
              'Vehicle',
              widget.busType ?? (_isMinivan ? 'VIP Minivan' : 'Coach Bus'),
              isDark,
            ),
            const SizedBox(height: 12),

            // Operator
            if (widget.companyName != null) ...[
              _buildDetailRow('Operator', widget.companyName!, isDark),
              const SizedBox(height: 12),
            ],

            // Price per Seat
            _buildDetailRow(
              'Price per Seat',
              '\$${widget.basePrice.toStringAsFixed(2)}',
              isDark,
            ),

            const Divider(height: 32),

            // Selected Seats
            Text(
              'Selected Seats ($count)',
              style: AppFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),

            if (count == 0)
              Text(
                'Please click on available seats in the vehicle diagram.',
                style: AppFonts.dmSans(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedList.map((seat) {
                  return Chip(
                    label: Text(
                      seat,
                      style: AppFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => controller.toggleSeat(seat),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const Divider(height: 32),

            // Total Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: AppFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                child: Text(
                  'Continue to Passenger Details',
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.dmSans(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: AppFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
