import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';

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
        decoration: BoxDecoration(
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
                colorScheme: ColorScheme.light(
                  primary: Color(0xff4FD18B),
                  onPrimary: Colors.white,
                  onSurface: Color(0xff1E293B),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xff4FD18B),
                  ),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: selected,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
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
                  'Confirm',
                  style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
