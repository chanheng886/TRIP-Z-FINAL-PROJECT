import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SeatStatus {
  available,
  selected,
  booked,
  unavailable,
}

class VehicleSeatWidget extends StatelessWidget {
  final String seatLabel;
  final SeatStatus status;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showArmrests;

  const VehicleSeatWidget({
    super.key,
    required this.seatLabel,
    required this.status,
    this.onTap,
    this.width = 48,
    this.height = 54,
    this.showArmrests = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final isSelected = status == SeatStatus.selected;
    final isBooked = status == SeatStatus.booked;
    final isAvailable = status == SeatStatus.available;

    // Color definitions based on state
    Color cushionBg;
    Color headrestBg;
    Color borderColor;
    Color textColor;
    List<BoxShadow> shadows;

    if (isSelected) {
      cushionBg = primaryColor;
      headrestBg = isDark
          ? primaryColor.withValues(alpha: 0.85)
          : const Color(0xFF16A34A);
      borderColor = const Color(0xFF15803D);
      textColor = Colors.white;
      shadows = [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.35),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    } else if (isBooked) {
      cushionBg = isDark ? const Color(0xFF2A2E39) : const Color(0xFFE2E8F0);
      headrestBg = isDark ? const Color(0xFF1E222B) : const Color(0xFFCBD5E1);
      borderColor = isDark ? const Color(0xFF3B4252) : const Color(0xFFCBD5E1);
      textColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      shadows = [];
    } else {
      // Available
      cushionBg = isDark ? const Color(0xFF1E2430) : Colors.white;
      headrestBg = isDark ? const Color(0xFF2B3342) : const Color(0xFFF1F5F9);
      borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      textColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return GestureDetector(
      onTap: isAvailable || isSelected ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Armrests (Left & Right)
              if (showArmrests) ...[
                Positioned(
                  left: 0,
                  top: 10,
                  bottom: 6,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.7)
                          : isBooked
                              ? (isDark
                                  ? const Color(0xFF1E222B)
                                  : const Color(0xFFCBD5E1))
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF94A3B8)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 10,
                  bottom: 6,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.7)
                          : isBooked
                              ? (isDark
                                  ? const Color(0xFF1E222B)
                                  : const Color(0xFFCBD5E1))
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF94A3B8)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],

              // Main Seat Body (Backrest + Cushion)
              Positioned.fill(
                left: showArmrests ? 4 : 0,
                right: showArmrests ? 4 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: cushionBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: shadows,
                  ),
                  child: Column(
                    children: [
                      // Top Headrest Cushion
                      Container(
                        height: 12,
                        margin: const EdgeInsets.fromLTRB(4, 2, 4, 0),
                        decoration: BoxDecoration(
                          color: headrestBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.3)
                                : isDark
                                    ? Colors.black26
                                    : Colors.black.withValues(alpha: 0.05),
                            width: 0.5,
                          ),
                        ),
                      ),

                      // Seat Cushion with Seat Number
                      Expanded(
                        child: Center(
                          child: isBooked
                              ? Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: textColor,
                                )
                              : Text(
                                  seatLabel,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      ),

                      // Bottom cushion stitch seam line
                      Container(
                        height: 3,
                        margin: const EdgeInsets.fromLTRB(6, 0, 6, 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : isDark
                                  ? const Color(0xFF2B3342)
                                  : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
