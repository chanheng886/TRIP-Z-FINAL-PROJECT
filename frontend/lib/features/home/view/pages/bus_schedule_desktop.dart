import 'package:flutter/material.dart';

class BusScheduleDesktop extends StatefulWidget {
  const BusScheduleDesktop({super.key});

  @override
  State<BusScheduleDesktop> createState() => _BusScheduleDesktopState();
}

class _BusScheduleDesktopState extends State<BusScheduleDesktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Bus Scheudle For desktop Screen')),
    );
  }
}
