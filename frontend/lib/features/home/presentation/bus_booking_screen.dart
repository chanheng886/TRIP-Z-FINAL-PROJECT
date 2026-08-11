import 'package:flutter/material.dart';
import 'package:frontend/features/home/ui/bus_booking/bus_booking_desktop.dart';
import 'package:frontend/features/home/ui/bus_booking/bus_booking_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class BusBookingScreen extends StatelessWidget {
  const BusBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: BusBookingMobile(),
      desktop: BusBookingDesktop(),
    );
  }
}
