import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/view/widgets/payment/payment_step_label.dart';
import 'package:frontend/shared/model/booking_request.dart';
import 'package:frontend/shared/service/payment_launcher_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Payment section for ACLEDA Bank with NBC-standard KHQR and app launcher
class AcledaPaymentSection extends StatelessWidget {
  final BookingRequest request;
  final double totalAmount;
  final bool hasLaunchedApp;
  final VoidCallback onLaunchAcledaApp;
  final Color cardBg;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;

  const AcledaPaymentSection({
    super.key,
    required this.request,
    required this.totalAmount,
    required this.hasLaunchedApp,
    required this.onLaunchAcledaApp,
    required this.cardBg,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // KHQR payload: real NBC-standard KHQR with amount + booking reference
    final bookingRef =
        'TRIPZ-${request.busScheduleId}-${request.passengers.map((p) => p.seatNumber).join('')}';
    final khrAmount = (totalAmount * 4100).round();
    // Generate real KHQR string (amount pre-filled, scannable by ACLEDA/Bakong)
    final qrPayload = PaymentLauncherService.generateKhqrString(
      amount: totalAmount,
      bookingCode: bookingRef,
    );

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── ACLEDA Branded Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF0F3B66),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.buildingColumns,
                      size: 18,
                      color: Color(0xFF0F3B66),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'ACLEDA Bank',
                            style: AppFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Super App',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F3B66),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scan KHQR or open app to pay',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFFFFDF79),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── STEP 1: KHQR code ──
                PaymentStepLabel(
                  step: '1',
                  label: 'Scan this QR code in ACLEDA app',
                  secondaryText: secondaryText,
                ),
                const SizedBox(height: 10),

                // KHQR Code Box (amount-embedded)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // KHQR badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'KHQR  •  BAKONG',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // QR Code
                      QrImageView(
                        data: qrPayload,
                        version: QrVersions.auto,
                        size: 180.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0F3B66),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0F3B66),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Amount display
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0F3B66).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: AppFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F3B66),
                              ),
                            ),
                            Text(
                              '≈ ${khrAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} KHR',
                              style: AppFonts.dmSans(
                                fontSize: 11,
                                color: const Color(0xFF0F3B66)
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Booking ref
                      Text(
                        'Ref: $bookingRef',
                        style: AppFonts.dmSans(
                          fontSize: 10,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── STEP 2: Open ACLEDA app ──
                PaymentStepLabel(
                  step: '2',
                  label: 'Open ACLEDA Super App',
                  secondaryText: secondaryText,
                ),
                const SizedBox(height: 10),

                // Amount row + copy button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF161922)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount to Pay',
                              style: AppFonts.dmSans(
                                fontSize: 10,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: AppFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F3B66),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Copy amount button
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                          text: totalAmount.toStringAsFixed(2),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Amount copied: \$${totalAmount.toStringAsFixed(2)}',
                              style: AppFonts.dmSans(
                                  color: Colors.white, fontSize: 13),
                            ),
                            backgroundColor: const Color(0xFF0F3B66),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF0F3B66).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFF0F3B66).withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: Color(0xFF0F3B66),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F3B66),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Open ACLEDA button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowUpRightFromSquare,
                      size: 15,
                      color: Color(0xFFFFDF79),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3B66),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 1.2,
                        ),
                      ),
                    ),
                    onPressed: onLaunchAcledaApp,
                    label: Text(
                      'Open ACLEDA Super App',
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Hint: what to do inside ACLEDA
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: Color(0xFFB8960C),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Inside ACLEDA: tap Scan QR → scan the KHQR above → enter the amount and confirm.',
                          style: AppFonts.dmSans(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFFFFDF79)
                                : const Color(0xFF7A6000),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── STEP 3: Return & confirm ──
                PaymentStepLabel(
                  step: '3',
                  label: 'Return here & tap \'Pay & Get Ticket\'',
                  secondaryText: secondaryText,
                ),

                if (hasLaunchedApp) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ACLEDA app opened! After paying, press the green button below.',
                            style: AppFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
