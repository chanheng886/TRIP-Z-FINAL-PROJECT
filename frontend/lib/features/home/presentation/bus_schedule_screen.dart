import 'package:flutter/material.dart';
import 'package:frontend/features/home/ui/bus_schedule/bus_schedule_desktop.dart';
import 'package:frontend/features/home/ui/bus_schedule/bus_schedule_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class BusScheduleScreen extends StatelessWidget {
  final String fromLocationName;
  final String toLocatioName;
  final int fromLocationId;
  final int toLcoationId;
  final DateTime travelDate;
  const BusScheduleScreen({
    super.key,
    required this.fromLocationName,
    required this.toLocatioName,
    required this.fromLocationId,
    required this.toLcoationId,
    required this.travelDate,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: BusScheduleMobile(
        fromLocationName: fromLocationName,
        toLocationName: toLocatioName,
        fromLocationId: fromLocationId,
        toLocationId: toLcoationId,
        travelDate: travelDate,
      ),
      desktop: BusScheduleDesktop(),
    );
  }
}
