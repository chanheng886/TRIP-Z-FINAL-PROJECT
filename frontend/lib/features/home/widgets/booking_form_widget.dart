import 'package:flutter/material.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/models/booking_request.dart';
import 'package:frontend/features/home/models/passenger.dart';
import 'package:frontend/features/home/presentation/booking_confirmation_screen.dart';
import 'package:frontend/features/home/viewmodel/booking_view_model.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void showBookingFormSheet(
  BuildContext context, {
  required BookingViewmodel controller,
  required int busScheduleId,
  required double basePrice,
}) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  String selectedGender = 'Male';
  String selectedPayment = 'Cash';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Passenger Details',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedGender = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPayment,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                    ),
                    items: ['Cash', 'Card', 'QR Pay']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedPayment = value!);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(() {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4FD18B),
                        ),
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                if (nameController.text.isEmpty ||
                                    phoneController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill in name and phone',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final authVM = Get.find<AuthViewmodel>();
                                final userId = authVM.currentUser?.id;
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please login first'),
                                    ),
                                  );
                                  return;
                                }

                                final passengers = controller.selectedSeats
                                    .map(
                                      (seat) => Passenger(
                                        name: nameController.text,
                                        seatNumber: seat,
                                      ),
                                    )
                                    .toList();

                                final request = BookingRequest(
                                  customerId: userId,
                                  busScheduleId: busScheduleId,
                                  paymentMethod: selectedPayment,
                                  passengers: passengers,
                                );

                                final success = await controller.submitBooking(
                                  request,
                                );
                                if (success) {
                                  Get.back(); // close sheet
                                  Get.off(
                                    () => BookingConfirmationScreen(
                                      booking: controller.bookingResult.value!,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        controller.submitError.value,
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: controller.isSubmitting.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Confirm Booking',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
