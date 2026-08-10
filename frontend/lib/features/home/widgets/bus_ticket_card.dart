import 'package:flutter/material.dart';
import 'package:frontend/features/home/models/bus_schedule.dart';
import 'package:google_fonts/google_fonts.dart';

class BusTicketCard extends StatelessWidget {
  final BusSchedule schedule;
  final VoidCallback onBookNow;
  const BusTicketCard({
    super.key,
    required this.schedule,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Route & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${schedule.fromLocation} → ${schedule.toLocation}",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xff1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.status == BusScheduleStatus.Available
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule.status.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: schedule.status == BusScheduleStatus.Available
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Route ID: ${schedule.routeId} • Bus ID: ${schedule.busId}",
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xff64748B),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(
                color: isDarkMode
                    ? const Color(0xFF2C313C)
                    : const Color(0xffE2E8F0),
                height: 1,
              ),
            ),

            // Middle Section: Details Grid (Bus Type, Date, Plate, Time)
            Row(
              children: [
                // Left Column: Bus Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        "Bus Type",
                        schedule.busType,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        "Plate Number",
                        schedule.plateNumber,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        "Operator",
                        schedule.companyName,
                        isDarkMode,
                      ),
                    ],
                  ),
                ),
                // Right Column: Date & Times
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        "Date",
                        schedule.formattedDate,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        "Departure",
                        schedule.departureTime,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        "Arrival",
                        schedule.arrivalTime,
                        isDarkMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(
                color: isDarkMode
                    ? const Color(0xFF2C313C)
                    : const Color(0xffE2E8F0),
                height: 1,
              ),
            ),

            // Bottom Section: Price & Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${schedule.basePrice.toStringAsFixed(2)}",
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff4FD18B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "/person",
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: isDarkMode
                                ? const Color(0xFF94A3B8)
                                : const Color(0xff64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${schedule.availableSeat} seats available",
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: schedule.availableSeat > 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: schedule.availableSeat > 0 ? onBookNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4FD18B),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDarkMode
                        ? const Color(0xFF2C313C)
                        : Colors.grey.shade300,
                    disabledForegroundColor: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Book Now",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailItem(String label, String value, bool isDarkMode) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          color: const Color(0xff94A3B8),
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : const Color(0xff1E293B),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
