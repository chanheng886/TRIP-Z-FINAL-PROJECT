import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/shared/model/booking_request.dart';
import 'package:frontend/shared/model/passenger.dart';
import 'package:frontend/features/home/view/pages/booking_confirmation_screen.dart';
import 'package:frontend/features/home/viewmodel/booking_view_model.dart';
import 'package:get/get.dart';

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
                    'passenger_information'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'full_name'.tr),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'phone'.tr),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'email'.tr,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xff4FD18B),
                    ),
                    initialValue: selectedGender,
                    decoration: InputDecoration(
                      labelText: 'gender'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Male', child: Text('male'.tr)),
                      DropdownMenuItem(value: 'Female', child: Text('female'.tr)),
                      DropdownMenuItem(value: 'Other', child: Text('other'.tr)),
                    ],
                    onChanged: (value) {
                      setModalState(() => selectedGender = value!);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xff4FD18B),
                    ),
                    initialValue: selectedPayment,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'Card', child: Text('Card')),
                      DropdownMenuItem(value: 'QR Pay', child: Text('QR Pay')),
                    ],
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
                                'confirm_booking'.tr,
                                style: AppFonts.dmSans(
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
