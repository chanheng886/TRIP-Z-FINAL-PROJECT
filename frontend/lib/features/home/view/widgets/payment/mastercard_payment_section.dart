import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// Payment section for Mastercard credit/debit card inputs
class MastercardPaymentSection extends StatelessWidget {
  final Color cardBg;
  final Color borderColor;
  final Color primaryText;
  final bool isDark;
  final TextEditingController cardNumberController;
  final TextEditingController cardExpiryController;
  final TextEditingController cardCvvController;

  const MastercardPaymentSection({
    super.key,
    required this.cardBg,
    required this.borderColor,
    required this.primaryText,
    required this.isDark,
    required this.cardNumberController,
    required this.cardExpiryController,
    required this.cardCvvController,
  });

  @override
  Widget build(BuildContext context) {
    final fieldBg = isDark ? const Color(0xFF161922) : const Color(0xFFF8FAFC);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEB001B), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mastercard Credit/Debit',
                style: AppFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.ccMastercard,
                size: 24,
                color: Color(0xFFEB001B),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            style: AppFonts.dmSans(fontSize: 14, color: primaryText),
            decoration: InputDecoration(
              filled: true,
              fillColor: fieldBg,
              hintText: '5xxx xxxx xxxx xxxx',
              labelText: 'Card Number',
              prefixIcon: const Icon(Icons.credit_card_rounded, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cardExpiryController,
                  keyboardType: TextInputType.datetime,
                  style: AppFonts.dmSans(fontSize: 14, color: primaryText),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldBg,
                    hintText: 'MM/YY',
                    labelText: 'Expiry',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: cardCvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  style: AppFonts.dmSans(fontSize: 14, color: primaryText),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldBg,
                    hintText: 'CVC',
                    labelText: 'CVV',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
