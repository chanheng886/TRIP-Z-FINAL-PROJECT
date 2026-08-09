import 'package:flutter/material.dart';
import 'package:frontend/features/home/ui/bus_schedule/bus_schedule_desktop.dart';
import 'package:frontend/features/home/ui/bus_schedule/bus_schedule_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class BusScheduleScreen extends StatelessWidget {
  const BusScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: BusScheduleMobile(),
      desktop: BusScheduleDesktop(),
    );
  }
}
