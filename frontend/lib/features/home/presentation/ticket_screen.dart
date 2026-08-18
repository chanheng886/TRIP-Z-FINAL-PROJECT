import 'package:flutter/material.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/features/home/ui/ticket/ticket_desktop.dart';
import 'package:frontend/features/home/ui/ticket/ticket_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class TicketScreen extends StatelessWidget {
  final BookingResponse booking;
  const TicketScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: TicketMobile(booking: booking),
      desktop: TicketDesktop(booking: booking),
    );
  }
}
