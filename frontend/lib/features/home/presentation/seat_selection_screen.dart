import 'package:flutter/material.dart';
import 'package:frontend/features/home/ui/seats/seat_selection_desktop.dart';
import 'package:frontend/features/home/ui/seats/seat_selection_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class SeatSelectionScreen extends StatefulWidget {
  final int busScheduleId;
  final double basePrice;
  final String fromLocation;
  final String toLocation;
  final String? busType;
  final String? companyName;

  const SeatSelectionScreen({
    super.key,
    required this.busScheduleId,
    required this.basePrice,
    required this.fromLocation,
    required this.toLocation,
    this.busType,
    this.companyName,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SeatSelectionMobile(
        busScheduleId: widget.busScheduleId,
        basePrice: widget.basePrice,
        fromLocation: widget.fromLocation,
        toLocation: widget.toLocation,
        busType: widget.busType,
        companyName: widget.companyName,
      ),
      desktop: SeatSelectionDesktop(
        busScheduleId: widget.busScheduleId,
        basePrice: widget.basePrice,
        fromLocation: widget.fromLocation,
        toLocation: widget.toLocation,
        busType: widget.busType,
        companyName: widget.companyName,
      ),
    );
  }
}
