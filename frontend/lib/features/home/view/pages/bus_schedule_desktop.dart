import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/bus_schedule_repository.dart';
import 'package:frontend/features/home/view/pages/seat_selection_screen.dart';
import 'package:frontend/features/home/view/widgets/bus_ticket_card.dart';
import 'package:frontend/features/home/viewmodel/bus_schedule_viewmodel.dart';
import 'package:frontend/shared/service/bus_schedule_serivice.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BusScheduleDesktop extends StatefulWidget {
  final String fromLocationName;
  final String toLocationName;
  final int fromLocationId;
  final int toLocationId;
  final DateTime travelDate;

  const BusScheduleDesktop({
    super.key,
    required this.fromLocationName,
    required this.toLocationName,
    required this.fromLocationId,
    required this.toLocationId,
    required this.travelDate,
  });

  @override
  State<BusScheduleDesktop> createState() => _BusScheduleDesktopState();
}

class _BusScheduleDesktopState extends State<BusScheduleDesktop> {
  late final BusScheduleViewmodel controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BusScheduleViewmodel>()
        ? Get.find<BusScheduleViewmodel>()
        : Get.put(BusScheduleViewmodel(BusScheduleRepository(BusScheduleService())));

    controller.searchBusSchedule(
      fromLocationId: widget.fromLocationId,
      toLocationId: widget.toLocationId,
      travelDate: widget.travelDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDarkMode
        ? const Color(0xFF12161E)
        : const Color(0xFFF7F8FC);
    final cardBg = isDarkMode ? const Color(0xFF1E222B) : Colors.white;

    final dateFormatted = DateFormat('EEE, MMM d, yyyy').format(widget.travelDate);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 18,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.fromLocationName.trDb,
              style: AppFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(
              FontAwesomeIcons.arrowRight,
              size: 14,
              color: AppColors.green,
            ),
            const SizedBox(width: 8),
            Text(
              widget.toLocationName.trDb,
              style: AppFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dateFormatted,
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              );
            }
            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage.value.tr,
                      style: AppFonts.dmSans(
                        fontSize: 15,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                      onPressed: () => controller.searchBusSchedule(
                        fromLocationId: widget.fromLocationId,
                        toLocationId: widget.toLocationId,
                        travelDate: widget.travelDate,
                      ),
                      child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            if (controller.schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.bus,
                      size: 48,
                      color: isDarkMode ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'no_buses_found'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please try selecting a different date or route.',
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        color: isDarkMode ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              itemCount: controller.schedules.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${controller.schedules.length} bus(es) available',
                          style: AppFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Select a bus to pick your seats',
                          style: AppFonts.dmSans(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final schedule = controller.schedules[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: BusTicketCard(
                    schedule: schedule,
                    onBookNow: () {
                      Get.to(
                        () => SeatSelectionScreen(
                          busScheduleId: schedule.id,
                          basePrice: schedule.basePrice,
                          fromLocation: schedule.fromLocation,
                          toLocation: schedule.toLocation,
                          busType: schedule.busType,
                          companyName: schedule.companyName,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
