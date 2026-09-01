import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/seat_map.dart';
import 'package:get/get.dart';

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

    // Chassis styling
    final busChassisBg = isDark ? const Color(0xFF141720) : Colors.white;
    final busBorderColor = isDark ? const Color(0xFF2C3242) : const Color(0xFFCBD5E1);
    final windshieldBg = isDark ? const Color(0xFF0B0F19) : const Color(0xFFE2E8F0);

    final allSeats = seatMap.allSeats;
    final rowGroups = _groupSeatsIntoRows(allSeats);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double busWidth = constraints.maxWidth > 420
            ? 390
            : (constraints.maxWidth - 12).clamp(320.0, 420.0);

        return Center(
          child: Container(
            width: busWidth,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: busChassisBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(44),
                topRight: Radius.circular(44),
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
              border: Border.all(color: busBorderColor, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Side Mirrors
                Positioned(
                  top: 40,
                  left: -9,
                  child: _buildSideMirror(isDark, isLeft: true),
                ),
                Positioned(
                  top: 40,
                  right: -9,
                  child: _buildSideMirror(isDark, isLeft: false),
                ),

                // Interior Layout
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Windshield & Destination Header
                      _buildFrontWindshield(isDark, windshieldBg),

                      const SizedBox(height: 14),

                      // 2. Driver & Entrance Cabin
                      _buildDriverAndEntrance(isDark),

                      const SizedBox(height: 14),

                      // 3. Directional Aisle Indicator
                      _buildAisleIndicator(isDark),

                      const SizedBox(height: 18),

                      // 4. Passenger Seating Rows (2 + Aisle + 2, or Rear Bench)
                      ...rowGroups.map((row) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildSeatingRow(row, isDark),
                        );
                      }),

                      const SizedBox(height: 8),

                      // 5. Rear Luggage & Emergency Exit
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

  /// Groups seat strings into structured row objects.
  /// For 25-seat buses: 7 rows of 2 on Left + 1 on Right (21 seats) + 1 Rear Bench of 4 chairs (4 seats) = 25 seats.
  List<_BusRowData> _groupSeatsIntoRows(List<String> seats) {
    if (seats.isEmpty) return [];

    final List<_BusRowData> rows = [];

    // Special exact formatting for 25-seat bus (Toyota Coaster / Hyundai County)
    if (seats.length == 25) {
      // 7 rows of 3 seats (2 Left + 1 Right)
      for (int r = 0; r < 7; r++) {
        final int startIndex = r * 3;
        rows.add(_BusRowData(
          leftSeats: [seats[startIndex], seats[startIndex + 1]],
          rightSeats: [seats[startIndex + 2]],
        ));
      }
      // 1 Rear bench of 4 seats across the back near the luggage
      rows.add(_BusRowData(
        leftSeats: [seats[21], seats[22]],
        rightSeats: [seats[23], seats[24]],
        isRearBench: true,
      ));
      return rows;
    }

    final Map<String, List<String>> rowMap = {};
    bool isLetterBased = seats.every((s) => s.isNotEmpty && RegExp(r'^[A-Za-z]').hasMatch(s));

    if (isLetterBased) {
      for (final seat in seats) {
        final rowLetter = seat.substring(0, 1).toUpperCase();
        rowMap.putIfAbsent(rowLetter, () => []).add(seat);
      }

      final entries = rowMap.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final rowSeats = entries[i].value;
        final bool isLastRow = i == entries.length - 1;

        if (rowSeats.length == 4) {
          if (isLastRow) {
            // Rear bench of 4
            rows.add(_BusRowData(
              leftSeats: [rowSeats[0], rowSeats[1]],
              rightSeats: [rowSeats[2], rowSeats[3]],
              isRearBench: true,
            ));
          } else {
            // Standard 2 + 2 row
            rows.add(_BusRowData(
              leftSeats: [rowSeats[0], rowSeats[1]],
              rightSeats: [rowSeats[2], rowSeats[3]],
            ));
          }
        } else if (rowSeats.length == 5) {
          // 5-seat rear bench
          rows.add(_BusRowData(
            leftSeats: [rowSeats[0], rowSeats[1]],
            centerSeat: rowSeats[2],
            rightSeats: [rowSeats[3], rowSeats[4]],
            isRearBench: true,
          ));
        } else if (rowSeats.length == 3) {
          // 2 + 1 row (Right side has only 1 chair)
          rows.add(_BusRowData(
            leftSeats: [rowSeats[0], rowSeats[1]],
            rightSeats: [rowSeats[2]],
          ));
        } else if (rowSeats.length == 2) {
          // 1 + 1 row
          rows.add(_BusRowData(
            leftSeats: [rowSeats[0]],
            rightSeats: [rowSeats[1]],
          ));
        } else if (rowSeats.length == 1) {
          // Single seat (e.g. at center back)
          rows.add(_BusRowData(
            centerSeat: rowSeats[0],
            isRearBench: true,
          ));
        }
      }
    } else {
      // Numerical fallback
      for (int i = 0; i < seats.length; i += 3) {
        final remaining = seats.length - i;
        if (remaining == 4) {
          // Last 4 seats as rear bench
          rows.add(_BusRowData(
            leftSeats: [seats[i], seats[i + 1]],
            rightSeats: [seats[i + 2], seats[i + 3]],
            isRearBench: true,
          ));
          break;
        }

        final chunk = seats.sublist(i, (i + 3 < seats.length) ? i + 3 : seats.length);
        if (chunk.length == 3) {
          rows.add(_BusRowData(
            leftSeats: [chunk[0], chunk[1]],
            rightSeats: [chunk[2]],
          ));
        } else if (chunk.length == 2) {
          rows.add(_BusRowData(
            leftSeats: [chunk[0]],
            rightSeats: [chunk[1]],
          ));
        } else if (chunk.length == 1) {
          rows.add(_BusRowData(
            centerSeat: chunk[0],
          ));
        }
      }
    }

    return rows;
  }

  Widget _buildSeatingRow(_BusRowData row, bool isDark) {
    if (row.isRearBenchSingle) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBusSeat(row.centerSeat!, isDark),
        ],
      );
    }

    if (row.isFullFiveBench) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBusSeat(row.leftSeats[0], isDark),
          _buildBusSeat(row.leftSeats[1], isDark),
          _buildBusSeat(row.centerSeat!, isDark),
          _buildBusSeat(row.rightSeats[0], isDark),
          _buildBusSeat(row.rightSeats[1], isDark),
        ],
      );
    }

    // Rear bench of 4 seats across the back
    if (row.isRearFourBench) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBusSeat(row.leftSeats[0], isDark),
          _buildBusSeat(row.leftSeats[1], isDark),
          _buildBusSeat(row.rightSeats[0], isDark),
          _buildBusSeat(row.rightSeats[1], isDark),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Pair (2 Seats on Left)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (row.leftSeats.isNotEmpty) _buildBusSeat(row.leftSeats[0], isDark),
            if (row.leftSeats.length > 1) ...[
              const SizedBox(width: 8),
              _buildBusSeat(row.leftSeats[1], isDark),
            ],
          ],
        ),

        // Center Walking Aisle Corridor
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Container(
                width: 24,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2433).withValues(alpha: 0.5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right Side (1 Seat on Right)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (row.rightSeats.isNotEmpty) _buildBusSeat(row.rightSeats[0], isDark),
            if (row.rightSeats.length > 1) ...[
              const SizedBox(width: 8),
              _buildBusSeat(row.rightSeats[1], isDark),
            ],
          ],
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
                  backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.95),
                  colorText: Colors.white,
                  icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B)),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 14,
                  duration: const Duration(seconds: 2),
                );
              }
            : () => onSeatSelected(seat),
      );
    });
  }

  Widget _buildSideMirror(bool isDark, {required bool isLeft}) {
    return Container(
      width: 9,
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 6 : 0),
          bottomLeft: Radius.circular(isLeft ? 6 : 0),
          topRight: Radius.circular(isLeft ? 0 : 6),
          bottomRight: Radius.circular(isLeft ? 0 : 6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: Offset(isLeft ? -1 : 1, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontWindshield(bool isDark, Color windshieldBg) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: windshieldBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus_rounded,
              size: 16,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              "EXPRESS CABIN",
              style: AppFonts.dmSans(
                fontSize: 10,
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverAndEntrance(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B202C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Driver Cockpit (Left)
          Row(
            children: [
              _SteeringWheelIcon(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                "Driver",
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          // Boarding Entrance (Right)
          Row(
            children: [
              Text(
                "Entrance Door",
                style: AppFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.door_front_door_outlined,
                size: 18,
                color: Color(0xFF10B981),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAisleIndicator(bool isDark) {
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
                size: 14,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                "FRONT",
                style: AppFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
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

  Widget _buildRearSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.luggage_rounded,
            size: 16,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Text(
            "REAR LUGGAGE / EMERGENCY EXIT",
            style: AppFonts.dmSans(
              fontSize: 10,
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

class _BusRowData {
  final List<String> leftSeats;
  final String? centerSeat;
  final List<String> rightSeats;
  final bool isRearBench;

  _BusRowData({
    this.leftSeats = const [],
    this.centerSeat,
    this.rightSeats = const [],
    this.isRearBench = false,
  });

  bool get isRearBenchSingle => leftSeats.isEmpty && rightSeats.isEmpty && centerSeat != null;
  bool get isFullFiveBench => leftSeats.length == 2 && rightSeats.length == 2 && centerSeat != null;
  bool get isRearFourBench => isRearBench && leftSeats.length == 2 && rightSeats.length == 2 && centerSeat == null;
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

    // Colors for the comfortable armchair silhouette
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
      // Available
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
              // High-Definition Passenger Bus Chair
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Armrests & Bottom Support Bolster
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

                    // Center Backrest Cushion
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

                    // Ergonomic Headrest Pillow
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

              // Clear Seat Label
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
