import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/seat_map.dart';
import 'package:get/get.dart';

class MinivanVehicleLayout extends StatelessWidget {
  final SeatMap seatMap;
  final RxList<String> selectedSeats;
  final ValueChanged<String> onSeatSelected;

  const MinivanVehicleLayout({
    super.key,
    required this.seatMap,
    required this.selectedSeats,
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Minivan chassis styling
    final vanChassisBg = isDark
        ? const Color(0xFF161922)
        : const Color(0xFFF8FAFC);
    final vanBorderColor = isDark
        ? const Color(0xFF2C3242)
        : const Color(0xFFE2E8F0);
    final windshieldBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFE2E8F0);

    final allSeats = seatMap.allSeats;

    // Group seats into 2 + 1 rows (3 seats per row: [Col1, Col2, Col3])
    final List<List<String>> rows = [];
    const int seatsPerRow = 3;
    for (int i = 0; i < allSeats.length; i += seatsPerRow) {
      final end = (i + seatsPerRow < allSeats.length)
          ? i + seatsPerRow
          : allSeats.length;
      rows.add(allSeats.sublist(i, end));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double vanWidth = constraints.maxWidth > 380
            ? 350
            : constraints.maxWidth - 32;

        return Center(
          child: Container(
            width: vanWidth,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: vanChassisBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(38),
                topRight: Radius.circular(38),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: vanBorderColor, width: 2),
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
                // Aerodynamic Side Mirrors
                Positioned(
                  top: 36,
                  left: -7,
                  child: _buildSideMirror(isDark, isLeft: true),
                ),
                Positioned(
                  top: 36,
                  right: -7,
                  child: _buildSideMirror(isDark, isLeft: false),
                ),

                // Minivan Interior Wrapped Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Front Tapered Windshield
                      _buildWindshield(isDark, windshieldBg),

                      const SizedBox(height: 14),

                      // 2. Driver Cockpit & Side Door Header
                      _buildFrontCabinHeader(isDark),

                      const SizedBox(height: 14),

                      // 3. Front Orientation Indicator
                      _buildFrontIndicator(isDark),

                      const SizedBox(height: 20),

                      // 4. Seating Rows (2 on Left + Aisle + 1 on Right)
                      ...rows.map((rowSeats) {
                        final seat1 = rowSeats.isNotEmpty ? rowSeats[0] : null;
                        final seat2 = rowSeats.length > 1 ? rowSeats[1] : null;
                        final seat3 = rowSeats.length > 2 ? rowSeats[2] : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Pair (Column 1 & Column 2)
                              Row(
                                children: [
                                  if (seat1 != null)
                                    _buildMinivanSeat(seat1, isDark)
                                  else
                                    const SizedBox(width: 44, height: 60),
                                  const SizedBox(width: 20),
                                  if (seat2 != null)
                                    _buildMinivanSeat(seat2, isDark)
                                  else
                                    const SizedBox(width: 44, height: 60),
                                ],
                              ),

                              // Right Single Seat (Column 3)
                              if (seat3 != null)
                                _buildMinivanSeat(seat3, isDark)
                              else
                                const SizedBox(width: 44, height: 60),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 6),

                      // 5. Rear Luggage Boot & Tailgate
                      _buildRearLuggage(isDark),
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

  Widget _buildSideMirror(bool isDark, {required bool isLeft}) {
    return Container(
      width: 7,
      height: 20,
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

  Widget _buildWindshield(bool isDark, Color windshieldBg) {
    return Container(
      height: 32,
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
          "MINIVAN CABIN",
          style: AppFonts.dmSans(
            fontSize: 9,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCabinHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Driver Side with Vector Steering Wheel
          Row(
            children: [
              _SteeringWheelIcon(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                "Driver",
                style: AppFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          // Passenger Sliding Door Entrance
          Row(
            children: [
              Text(
                "Entrance Door",
                style: AppFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.sensor_door_outlined,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 12,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                "FRONT",
                style: AppFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
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

  Widget _buildRearLuggage(bool isDark) {
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
            Icons.luggage_outlined,
            size: 14,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Text(
            "REAR LUGGAGE BOOT",
            style: AppFonts.dmSans(
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

  Widget _buildMinivanSeat(String seat, bool isDark) {
    final isBooked = seatMap.isBooked(seat);

    return Obx(() {
      final isSelected = selectedSeats.contains(seat);

      return MinivanSeatWidget(
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
                  backgroundColor: const Color(
                    0xFF1E293B,
                  ).withValues(alpha: 0.92),
                  colorText: Colors.white,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF59E0B),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  borderRadius: 12,
                  duration: const Duration(seconds: 2),
                );
              }
            : () => onSeatSelected(seat),
      );
    });
  }
}

class MinivanSeatWidget extends StatelessWidget {
  final String seatLabel;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback? onTap;

  const MinivanSeatWidget({
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

    Color cushionColor;
    Color cradleColor;
    Color headrestColor;
    Color labelColor;

    if (isSelected) {
      cushionColor = const Color(0xFF10B981);
      cradleColor = const Color(0xFF059669);
      headrestColor = const Color(0xFF34D399);
      labelColor = const Color(0xFF10B981);
    } else if (isBooked) {
      cushionColor = isDark
          ? const Color(0xFF262C3A).withValues(alpha: 0.6)
          : const Color(0xFFE2E8F0);
      cradleColor = isDark
          ? const Color(0xFF1E2330).withValues(alpha: 0.6)
          : const Color(0xFFCBD5E1);
      headrestColor = isDark
          ? const Color(0xFF333D50).withValues(alpha: 0.5)
          : const Color(0xFF94A3B8).withValues(alpha: 0.4);
      labelColor = isDark
          ? const Color(0xFF64748B).withValues(alpha: 0.6)
          : const Color(0xFF94A3B8);
    } else {
      cushionColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      cradleColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF64748B);
      headrestColor = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);
      labelColor = isDark ? Colors.white : const Color(0xFF1E293B);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: 52,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 48,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            left: BorderSide(color: cradleColor, width: 5.0),
                            right: BorderSide(color: cradleColor, width: 5.0),
                            bottom: BorderSide(color: cradleColor, width: 6.0),
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      child: Container(
                        width: 38,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cushionColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Center(
                          child: isBooked
                              ? Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: labelColor,
                                )
                              : (isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 26,
                        height: 9,
                        decoration: BoxDecoration(
                          color: headrestColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                seatLabel,
                style: AppFonts.dmSans(
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
      child: CustomPaint(painter: _SteeringWheelPainter(color: color)),
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
    canvas.drawLine(
      center,
      Offset(center.dx - radius + 1, center.dy),
      spokePaint,
    );
    // Right spoke
    canvas.drawLine(
      center,
      Offset(center.dx + radius - 1, center.dy),
      spokePaint,
    );
    // Bottom spoke
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + radius - 1),
      spokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
