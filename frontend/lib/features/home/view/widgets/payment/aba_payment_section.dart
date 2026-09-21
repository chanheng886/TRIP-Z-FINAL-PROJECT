import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/view/widgets/payment/payment_step_label.dart';
import 'package:frontend/shared/model/booking_request.dart';
import 'package:frontend/shared/service/payment_launcher_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Payment section for ABA Payway (Real Hosted Checkout + KHQR)
class AbaPaymentSection extends StatelessWidget {
  final Color cardBg;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;
  final double totalAmount;
  final BookingRequest request;
  final bool isAbaLoading;
  final String? abaQrString;
  final String? abaQrImage;
  final String? abaDeeplink;
  final String? abaTransactionId;
  final bool isSimulating;
  final VoidCallback onSimulateSandboxPayment;
  final VoidCallback onLaunchAbaPayway;

  const AbaPaymentSection({
    super.key,
    required this.cardBg,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
    required this.totalAmount,
    required this.request,
    required this.isAbaLoading,
    required this.abaQrString,
    required this.abaQrImage,
    required this.abaDeeplink,
    required this.abaTransactionId,
    required this.isSimulating,
    required this.onSimulateSandboxPayment,
    required this.onLaunchAbaPayway,
  });

  @override
  Widget build(BuildContext context) {
    final khrAmount = (totalAmount * 4100).round();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF005A9C), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005A9C).withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ABA Branded Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF005A9C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.buildingColumns,
                      size: 18,
                      color: Colors.white,
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
                            'ABA Payway',
                            style: AppFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ABA PAYWAY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ABA Mobile • Cards • Official PayWay',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white70,
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
                // Payment methods accepted badge row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildPaymentMethodBadge('ABA Payway', const Color(0xFF005A9C)),
                    _buildPaymentMethodBadge('ABA Mobile App', const Color(0xFF005A9C)),
                    _buildPaymentMethodBadge('Cards (Visa / Mastercard)', const Color(0xFF374151)),
                  ],
                ),

                const SizedBox(height: 16),

                if (isAbaLoading && (abaQrString == null || abaQrString!.isEmpty))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF005A9C),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Connecting to ABA Payway...',
                          style: AppFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // ── Live Account or Sandbox Guidance Alert Banner ──
                  if (PaymentLauncherService.bakongAccountId.endsWith('@aba'))
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF16A34A)),
                              const SizedBox(width: 8),
                              Text(
                                'Live ABA Account Connected',
                                style: AppFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Account: ${PaymentLauncherService.bakongAccountId} (${PaymentLauncherService.merchantName})\nThis QR code is live and can be scanned directly with your official ABA Mobile app!',
                            style: AppFonts.dmSans(
                              fontSize: 11,
                              color: const Color(0xFF15803D),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // ── Sandbox Guidance Alert Banner ──
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_rounded, size: 18, color: Color(0xFF1D4ED8)),
                              const SizedBox(width: 8),
                              Text(
                                'ABA Sandbox Mode',
                                style: AppFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E40AF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Note: The real ABA Mobile app cannot scan sandbox test QR codes (returns [ Q0625 ]). Use the Instant Simulation button or Hosted Checkout below to test.',
                            style: AppFonts.dmSans(
                              fontSize: 11,
                              color: const Color(0xFF1E3A8A),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── STEP 1: Scan ABA QR Code ──
                  PaymentStepLabel(
                    step: '1',
                    label: 'Scan QR with ABA Mobile',
                    secondaryText: secondaryText,
                    circleColor: const Color(0xFF005A9C),
                  ),
                  const SizedBox(height: 12),

                  // QR Code Box
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF005A9C).withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF005A9C).withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildAbaQrDisplay(),

                          const SizedBox(height: 10),

                          // Price inside QR card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005A9C).withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '\$${totalAmount.toStringAsFixed(2)} USD',
                                  style: AppFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF005A9C),
                                  ),
                                ),
                                Text(
                                  '≈ ${khrAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} KHR',
                                  style: AppFonts.dmSans(
                                    fontSize: 11,
                                    color: const Color(0xFF005A9C).withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (abaTransactionId != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Ref: $abaTransactionId',
                              style: AppFonts.dmSans(
                                fontSize: 10,
                                color: const Color(0xFF6B7280),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Live Polling status badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005A9C).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF005A9C).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF005A9C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Live detection: auto-confirms when scanned',
                            style: AppFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF005A9C),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Quick Sandbox Payment Simulation ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Text(
                              'Instant Sandbox Simulation',
                              style: AppFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Test the complete booking & ticket generation flow with 1 tap:',
                          style: AppFonts.dmSans(
                            fontSize: 11,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            icon: isSimulating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const FaIcon(FontAwesomeIcons.circleCheck, size: 14, color: Colors.white),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isSimulating ? null : onSimulateSandboxPayment,
                            label: Text(
                              isSimulating ? 'Verifying payment...' : 'Simulate Successful Payment',
                              style: AppFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── STEP 2: Optional Open in ABA Mobile app ──
                  PaymentStepLabel(
                    step: '2',
                    label: 'Or pay directly in ABA Mobile app',
                    secondaryText: secondaryText,
                    circleColor: const Color(0xFF005A9C),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.buildingColumns, size: 15, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005A9C),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final opened = await PaymentLauncherService.launchAbaMobileApp(
                          deeplink: abaDeeplink,
                          openStoreIfNotFound: false,
                        );
                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF1E293B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: Text(
                                'ABA Mobile app not detected. Please scan the QR code above using any banking app!',
                                style: AppFonts.dmSans(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          );
                        }
                      },
                      label: Text(
                        'Open in ABA Mobile',
                        style: AppFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Secondary action: Hosted checkout modal for card payments
                  Center(
                    child: TextButton.icon(
                      onPressed: onLaunchAbaPayway,
                      icon: const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFF005A9C)),
                      label: Text(
                        'Pay via Card (Open Hosted Checkout)',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF005A9C),
                        ),
                      ),
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

  Widget _buildAbaQrDisplay() {
    // Priority 0: If real live ABA account is configured (e.g. 092590867@aba), render official live KHQR!
    if (PaymentLauncherService.bakongAccountId.endsWith('@aba')) {
      final bookingRef = 'TRIPZ-${request.busScheduleId}-${request.passengers.map((p) => p.seatNumber).join('')}';
      final liveKhqr = PaymentLauncherService.generateKhqrString(
        amount: totalAmount,
        bookingCode: bookingRef,
      );
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: QrImageView(
          data: liveKhqr,
          version: QrVersions.auto,
          size: 230.0,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        ),
      );
    }

    // Priority 1: Render vector QR from official raw KHQR string with pure black on white
    if (abaQrString != null && abaQrString!.isNotEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: QrImageView(
          data: abaQrString!,
          version: QrVersions.auto,
          size: 230.0,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Colors.black,
          ),
        ),
      );
    }

    // Priority 2: Render base64 image without corner clipping
    if (abaQrImage != null && abaQrImage!.isNotEmpty) {
      try {
        final cleanB64 = abaQrImage!.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '');
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Image.memory(
            base64Decode(cleanB64),
            width: 230,
            height: 230,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        );
      } catch (_) {}
    }

    return _buildQrFallback();
  }

  Widget _buildQrFallback() {
    final bookingRef = 'TRIPZ-${request.busScheduleId}-${request.passengers.map((p) => p.seatNumber).join('')}';
    final qrData = (abaQrString != null && abaQrString!.isNotEmpty)
        ? abaQrString!
        : bookingRef;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: 230.0,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  }

  /// Small pill widget showing an accepted payment method.
  Widget _buildPaymentMethodBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
