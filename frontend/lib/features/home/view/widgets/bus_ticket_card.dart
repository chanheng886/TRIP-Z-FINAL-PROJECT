import 'package:flutter/material.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';

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
    final isAvailable = schedule.status == BusScheduleStatus.Available;

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "${schedule.fromLocation.trDb} → ${schedule.toLocation.trDb}",
                    style: AppFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
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
                    color: isAvailable
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule.status.name.trDb,
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Route #${schedule.routeId} • Bus #${schedule.busId}",
              style: AppFonts.dmSans(
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
                        'bus_type'.tr,
                        schedule.busType.trDb,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        'Plate Number',
                        schedule.plateNumber,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        'operator'.tr,
                        schedule.companyName.trDb,
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
                        'date'.tr,
                        schedule.formattedDate,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        'departure'.tr,
                        schedule.departureTime,
                        isDarkMode,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        'arrival'.tr,
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
                          style: AppFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff4FD18B),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "/person",
                          style: AppFonts.dmSans(
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
                      "${schedule.availableSeat} ${'seats_left'.tr}",
                      style: AppFonts.dmSans(
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
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'view_seats'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
        style: AppFonts.dmSans(
          fontSize: 11,
          color: const Color(0xff94A3B8),
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: AppFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : const Color(0xff1E293B),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
