import 'package:flutter/material.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/features/home/view/pages/booking_confirmation_desktop.dart';
import 'package:frontend/features/home/view/pages/booking_confirmation_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingResponse booking;
  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: BookingConfirmationMobile(booking: booking),
      desktop: BookingConfirmationDesktop(),
    );
  }
}
