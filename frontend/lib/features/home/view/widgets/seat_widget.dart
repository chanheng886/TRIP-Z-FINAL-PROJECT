import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SeatWidget extends StatelessWidget {
  final int seatNumber;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seatNumber,
    required this.isSelected,
    required this.isBooked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;

    if (isBooked) {
      seatColor = Colors.grey.shade400;
    } else if (isSelected) {
      seatColor = const Color(0xFF22C55E);
    } else {
      seatColor = const Color(0xFF4FD18B);
    }

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.chair, size: 34, color: seatColor),

            const SizedBox(height: 3),

            Text(
              '$seatNumber',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF22C55E)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
