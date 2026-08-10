import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/home/repository/bus_schedule_repository.dart';
import 'package:frontend/features/home/viewmodel/bus_schedule_viewmodel.dart';
import 'package:frontend/features/home/widgets/bus_ticket_card.dart';
import 'package:frontend/shared/services/bus_schedule_serivice.dart';
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
    // final List<BusSchedule> schedules = BusScheduleDataFake.schedules;
    return Scaffold(
      backgroundColor: Color(0xffF7F8FC),
      appBar: AppBar(
        backgroundColor: Color(0xffF7F8FC),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: FaIcon(FontAwesomeIcons.angleLeft, size: 24),
        ),
        title: Column(
          children: [
            Text(
              widget.fromLocationName,
              style: GoogleFonts.dmSans(fontSize: 14, color: Color(0xff64748B)),
            ),
            Text(
              widget.toLocationName,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff1E293B),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != "") {
          return Center(child: Text("Faild to load bus schedules😟❌"));
        }
        if (controller.schedules.isEmpty) {
          return Center(child: Text("No Bus Found!😟🚌"));
        }
        return ListView.builder(
          itemCount: controller.schedules.length,
          itemBuilder: (context, index) {
            final schedule = controller.schedules[index];
            return BusTicketCard(schedule: schedule, onBookNow: () {});
          },
        );
      }),
    );
  }
}
