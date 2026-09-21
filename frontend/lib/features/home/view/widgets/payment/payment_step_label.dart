import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// Numbered step indicator label for payment workflow steps
class PaymentStepLabel extends StatelessWidget {
  final String step;
  final String label;
  final Color secondaryText;
  final Color circleColor;

  const PaymentStepLabel({
    super.key,
    required this.step,
    required this.label,
    required this.secondaryText,
    this.circleColor = const Color(0xFF0F3B66),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}
