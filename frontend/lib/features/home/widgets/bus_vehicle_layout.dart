import 'package:flutter/material.dart';
import 'package:frontend/features/home/models/seat_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BusVehicleLayout extends StatelessWidget {
  final SeatMap seatMap;
  final RxList<String> selectedSeats;
  final ValueChanged<String> onSeatSelected;

  const BusVehicleLayout({
    super.key,
    required this.seatMap,
    required this.selectedSeats,
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Bus body colors
    final busChassisBg = isDark
        ? const Color(0xFF161922)
        : const Color(0xFFF8FAFC);
    final busBorderColor = isDark
        ? const Color(0xFF2C3242)
        : const Color(0xFFE2E8F0);
    final windshieldBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFE2E8F0);

    final allSeats = seatMap.allSeats;
    final layoutRows = _buildBusLayoutGrid(allSeats);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double busWidth = constraints.maxWidth > 400 ? 360 : constraints.maxWidth - 32;

        return Center(
          child: Container(
            width: busWidth,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: busChassisBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(38),
                topRight: Radius.circular(38),
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              border: Border.all(color: busBorderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Exterior Side Mirrors
                Positioned(
                  top: 36,
                  left: -8,
                  child: _buildSideMirror(isDark, isLeft: true),
                ),
                Positioned(
                  top: 36,
                  right: -8,
                  child: _buildSideMirror(isDark, isLeft: false),
                ),

                // Bus Interior Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Windshield
                      _buildFrontWindshield(isDark, windshieldBg),

                      const SizedBox(height: 14),

                      // 2. Front Directional Indicator
                      _buildFrontIndicator(isDark),

                      const SizedBox(height: 20),

                      // 3. Grid of Seating Rows
                      ...layoutRows.map((rowSlots) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: rowSlots.map((slot) {
                              if (slot == 'DRIVER') {
                                return SizedBox(
                                  width: 44,
                                  child: Center(
                                    child: _SteeringWheelIcon(
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                );
                              } else if (slot != null && slot.isNotEmpty) {
                                return _buildBusSeat(slot, isDark);
                              } else {
                                // Empty space slot
                                return const SizedBox(width: 44, height: 60);
                              }
                            }).toList(),
                          ),
                        );
                      }),

                      const SizedBox(height: 6),

                      // 4. Rear Bumper & Emergency Area
                      _buildRearSection(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the exact bus seating pattern:
  /// Row 1: [Driver,  null,   Seat1,  Seat2]
  /// Row 2: [Seat3,   Seat4,  Seat5,  null]
  /// Row 3..N-1: [SeatA, SeatB, null, SeatC]
  /// Last Row: [SeatW, SeatX, SeatY, SeatZ]
  List<List<String?>> _buildBusLayoutGrid(List<String> seats) {
    if (seats.isEmpty) return [];

    final List<List<String?>> grid = [];
    int seatIndex = 0;

    // Row 1: Driver at Col 1, Empty at Col 2, Seat 1 at Col 3, Seat 2 at Col 4
    final String? r1c3 = seatIndex < seats.length ? seats[seatIndex++] : null;
    final String? r1c4 = seatIndex < seats.length ? seats[seatIndex++] : null;
    grid.add(['DRIVER', null, r1c3, r1c4]);

    // Row 2: Seat 3 at Col 1, Seat 4 at Col 2, Seat 5 at Col 3, Empty at Col 4
    if (seatIndex < seats.length) {
      final String? r2c1 = seatIndex < seats.length ? seats[seatIndex++] : null;
      final String? r2c2 = seatIndex < seats.length ? seats[seatIndex++] : null;
      final String? r2c3 = seatIndex < seats.length ? seats[seatIndex++] : null;
      grid.add([r2c1, r2c2, r2c3, null]);
    }

    // Remaining seats: determine if we need intermediate 2+1 rows + last row
    while (seatIndex < seats.length) {
      final int remaining = seats.length - seatIndex;

      // If 4 or fewer seats remain, place them in the final rear bench row
      if (remaining <= 4) {
        final List<String?> lastRow = [];
        for (int i = 0; i < 4; i++) {
          if (seatIndex < seats.length) {
            lastRow.add(seats[seatIndex++]);
          } else {
            lastRow.add(null);
          }
        }
        grid.add(lastRow);
        break;
      }

      // Middle Rows (2 on Left + Aisle + 1 on Right): [Col 1, Col 2, null, Col 4]
      final String? col1 = seatIndex < seats.length ? seats[seatIndex++] : null;
      final String? col2 = seatIndex < seats.length ? seats[seatIndex++] : null;
      final String? col4 = seatIndex < seats.length ? seats[seatIndex++] : null;
      grid.add([col1, col2, null, col4]);
    }

    return grid;
  }

  Widget _buildSideMirror(bool isDark, {required bool isLeft}) {
    return Container(
      width: 7,
      height: 22,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3B4252) : const Color(0xFF94A3B8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 4 : 0),
          bottomLeft: Radius.circular(isLeft ? 4 : 0),
          topRight: Radius.circular(isLeft ? 0 : 4),
          bottomRight: Radius.circular(isLeft ? 0 : 4),
        ),
      ),
    );
  }

  Widget _buildFrontWindshield(bool isDark, Color windshieldBg) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: windshieldBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          "BUS CABIN",
          style: GoogleFonts.dmSans(
            fontSize: 9,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontIndicator(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 13,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                "FRONT",
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBusSeat(String seat, bool isDark) {
    final isBooked = seatMap.isBooked(seat);

    return Obx(() {
      final isSelected = selectedSeats.contains(seat);

      return BusSeatWidget(
        seatLabel: seat,
        isSelected: isSelected,
        isBooked: isBooked,
        onTap: isBooked
            ? () {
                Get.closeAllSnackbars();
                Get.snackbar(
                  'Seat Unavailable',
                  'Seat $seat has already been reserved.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.92),
                  colorText: Colors.white,
                  icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B)),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2),
                );
              }
            : () => onSeatSelected(seat),
      );
    });
  }

  Widget _buildRearSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emergency_outlined,
            size: 14,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Text(
            "REAR / EMERGENCY EXIT",
            style: GoogleFonts.dmSans(
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class BusSeatWidget extends StatelessWidget {
  final String seatLabel;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback? onTap;

  const BusSeatWidget({
    super.key,
    required this.seatLabel,
    required this.isSelected,
    required this.isBooked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cushion color (top body)
    Color cushionColor;
    Color cradleColor;
    Color labelColor;

    if (isSelected) {
      cushionColor = const Color(0xFF22C55E);
      cradleColor = const Color(0xFF22C55E);
      labelColor = const Color(0xFF22C55E);
    } else if (isBooked) {
      // Soft, subtle muted disabled tone
      cushionColor = isDark
          ? const Color(0xFF1E2430).withValues(alpha: 0.5)
          : const Color(0xFFF1F5F9);
      cradleColor = isDark
          ? const Color(0xFF2C3242).withValues(alpha: 0.6)
          : const Color(0xFFE2E8F0);
      labelColor = isDark
          ? const Color(0xFF64748B).withValues(alpha: 0.5)
          : const Color(0xFF94A3B8);
    } else {
      // Available (silver/grey top cushion + dark navy/slate cradle)
      cushionColor = isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
      cradleColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B);
      labelColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: 44,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exact Chair Silhouette
              SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Top Cushion / Backrest
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 32,
                        height: 30,
                        decoration: BoxDecoration(
                          color: cushionColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: const Color(0xFF22C55E).withValues(alpha: 0.45),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Lower U-Shaped Cradle Bolster & Armrests
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 38,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            left: BorderSide(color: cradleColor, width: 4.5),
                            right: BorderSide(color: cradleColor, width: 4.5),
                            bottom: BorderSide(color: cradleColor, width: 5.5),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // Center notch tab on the bottom cradle
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cradleColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Seat Label Text directly below the chair
              Text(
                seatLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                  color: labelColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SteeringWheelIcon extends StatelessWidget {
  final Color color;
  const _SteeringWheelIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _SteeringWheelPainter(color: color),
      ),
    );
  }
}

class _SteeringWheelPainter extends CustomPainter {
  final Color color;
  _SteeringWheelPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Outer wheel ring
    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, outerPaint);

    // Center hub
    final hubPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, hubPaint);

    // 3 Spokes (left, right, bottom)
    final spokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Left spoke
    canvas.drawLine(center, Offset(center.dx - radius + 1, center.dy), spokePaint);
    // Right spoke
    canvas.drawLine(center, Offset(center.dx + radius - 1, center.dy), spokePaint);
    // Bottom spoke
    canvas.drawLine(center, Offset(center.dx, center.dy + radius - 1), spokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
