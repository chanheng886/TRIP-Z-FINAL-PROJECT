import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

Future<DateTime?> datePopUpPicker(
  BuildContext context, {
  DateTime? initaialDate,
}) {
  DateTime selected = initaialDate ?? DateTime.now();
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        width: double.infinity,
        height: 450,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xff4FD18B),
                  onPrimary: Colors.white,
                  onSurface: Color(0xff1E293B),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xff4FD18B),
                  ),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: selected,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) => selected = date,
              ),
            ),

            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Get.back(result: selected);
                },
                child: Text(
                  'confirm'.tr,
                  style: AppFonts.dmSans(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
