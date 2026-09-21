import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Payment section for PayPal Express Checkout
class PaypalPaymentSection extends StatelessWidget {
  final Color cardBg;
  final VoidCallback onLaunchPayPal;

  const PaypalPaymentSection({
    super.key,
    required this.cardBg,
    required this.onLaunchPayPal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0079C1), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF00457C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.paypal,
                  size: 20,
                  color: Color(0xFF0079C1),
                ),
                const SizedBox(width: 12),
                Text(
                  'PayPal Express Checkout',
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const FaIcon(
                  FontAwesomeIcons.paypal,
                  size: 16,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0079C1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onLaunchPayPal,
                label: Text(
                  'checkout_with_paypal'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
