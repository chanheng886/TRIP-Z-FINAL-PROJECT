import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

Future<DateTime?> datePopUpPicker(
  BuildContext context, {
  DateTime? initaialDate,
}) {
  DateTime selected = initaialDate ?? DateTime.now();
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDarkMode ? AppColors.darkCardBackground : Colors.white;

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDarkMode
                    ? const ColorScheme.dark(
                        primary: Color(0xFF22C55E),
                        onPrimary: Colors.white,
                        surface: Color(0xFF1C1C1F),
                        onSurface: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: Color(0xFF22C55E),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Color(0xff1E293B),
                      ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF22C55E),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Get.back(result: selected);
                },
                child: Text(
                  'confirm'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
