import 'package:flutter/material.dart';

class BusScheduleMobile extends StatefulWidget {
  const BusScheduleMobile({super.key});

  @override
  State<BusScheduleMobile> createState() => _BusScheduleMobileState();
}

class _BusScheduleMobileState extends State<BusScheduleMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Bus scheudle for mobile screen')),
    );
  }
}
