import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/bus_schedule_repository.dart';
import 'package:frontend/features/home/view/pages/seat_selection_screen.dart';
import 'package:frontend/features/home/viewmodel/bus_schedule_viewmodel.dart';
import 'package:frontend/features/home/view/widgets/bus_ticket_card.dart';
import 'package:frontend/shared/service/bus_schedule_serivice.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BusScheduleMobile extends StatefulWidget {
  final String fromLocationName;
  final String toLocationName;
  final int fromLocationId;
  final int toLocationId;
  final DateTime travelDate;
  const BusScheduleMobile({
    super.key,
    required this.fromLocationName,
    required this.toLocationName,
    required this.fromLocationId,
    required this.toLocationId,
    required this.travelDate,
  });

  @override
  State<BusScheduleMobile> createState() => _BusScheduleMobileState();
}

class _BusScheduleMobileState extends State<BusScheduleMobile> {
  final controller = Get.put(
    BusScheduleViewmodel(BusScheduleRepository(BusScheduleService())),
  );

  @override
  void initState() {
    super.initState();
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
        : const Color(0xffF7F8FC);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: FaIcon(
            FontAwesomeIcons.angleLeft,
            size: 24,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        title: Column(
          children: [
            Text(
              widget.fromLocationName.trDb,
              style: AppFonts.dmSans(
                fontSize: 14,
                color: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xff64748B),
              ),
            ),
            Text(
              widget.toLocationName.trDb,
              style: AppFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xff1E293B),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff4FD18B)),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              'error'.tr,
              style: AppFonts.dmSans(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
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
                  size: 40,
                  color: isDarkMode ? Colors.white24 : Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  'no_buses_found'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'no_buses_found_subtitle'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 13,
                    color: isDarkMode
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.schedules.length,
          itemBuilder: (context, index) {
            final schedule = controller.schedules[index];
            return BusTicketCard(
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
            );
          },
        );
      }),
    );
  }
}
