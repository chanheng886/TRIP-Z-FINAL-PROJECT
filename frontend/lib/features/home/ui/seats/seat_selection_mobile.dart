import 'package:flutter/material.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:frontend/features/home/repository/bus_schedule_repository.dart';
import 'package:frontend/features/home/viewmodel/booking_view_model.dart';
import 'package:frontend/features/home/widgets/booking_form_widget.dart';
import 'package:frontend/shared/services/booking_service.dart';
import 'package:frontend/shared/services/bus_schedule_serivice.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SeatSelectionMobile extends StatefulWidget {
  final int busScheduleId;
  final double basePrice;
  final String fromLocation;
  final String toLocation;

  const SeatSelectionMobile({
    super.key,
    required this.busScheduleId,
    required this.basePrice,
    required this.fromLocation,
    required this.toLocation,
  });

  @override
  State<SeatSelectionMobile> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionMobile> {
  final controller = Get.put(
    BookingViewmodel(
      BusScheduleRepository(BusScheduleService()),
      BookingRepository(BookingService()),
    ),
  );

  @override
  void initState() {
    super.initState();
    controller.loadSeatMap(widget.busScheduleId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Select Seats',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingSeats.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.seatMapError.value != "") {
          return Center(
            child: Text(
              'Failed to load seat map 😟',
              style: GoogleFonts.dmSans(fontSize: 16),
            ),
          );
        }
        final seatMap = controller.seatMap.value;
        if (seatMap == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _legendDot(colorScheme.primary, 'Selected'),
                  const SizedBox(width: 16),
                  _legendDot(Colors.grey.shade400, 'Booked'),
                  const SizedBox(width: 16),
                  _legendDot(theme.cardColor, 'Available', border: true),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: seatMap.allSeats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final seat = seatMap.allSeats[index];
                  final isBooked = seatMap.isBooked(seat);

                  return Obx(() {
                    final isSelected = controller.selectedSeats.contains(seat);

                    Color bgColor;
                    Color textColor;
                    if (isBooked) {
                      bgColor = Colors.grey.shade400;
                      textColor = Colors.white;
                    } else if (isSelected) {
                      bgColor = colorScheme.primary;
                      textColor = Colors.white;
                    } else {
                      bgColor = theme.cardColor;
                      textColor = colorScheme.onSurface;
                    }

                    return InkWell(
                      onTap: isBooked
                          ? null
                          : () => controller.toggleSeat(seat),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: (!isBooked && !isSelected)
                              ? Border.all(color: Colors.grey.shade300)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          seat,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            _buildSummaryBar(context, colorScheme),
          ],
        );
      }),
    );
  }

  Widget _legendDot(Color color, String label, {bool border = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: Colors.grey.shade300) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.dmSans(fontSize: 12)),
      ],
    );
  }

  Widget _buildSummaryBar(BuildContext context, ColorScheme colorScheme) {
    return Obx(() {
      final count = controller.selectedSeats.length;
      final total = count * widget.basePrice;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count seat${count == 1 ? '' : 's'} selected',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
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
                  'Continue',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
