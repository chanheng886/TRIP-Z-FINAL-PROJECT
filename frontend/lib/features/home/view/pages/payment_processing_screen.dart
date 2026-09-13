import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/view/pages/booking_confirmation_screen.dart';
import 'package:frontend/features/home/viewmodel/booking_view_model.dart';
import 'package:frontend/shared/model/booking_request.dart';
import 'package:frontend/shared/service/payment_launcher_service.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final BookingViewmodel controller;
  final BookingRequest request;
  final String fromLocation;
  final String toLocation;
  final String? busType;
  final String? companyName;
  final double totalAmount;

  const PaymentProcessingScreen({
    super.key,
    required this.controller,
    required this.request,
    required this.fromLocation,
    required this.toLocation,
    this.busType,
    this.companyName,
    required this.totalAmount,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isVerifying = false;
  bool _hasLaunchedApp = false;

  // Card form controllers (for Mastercard option)
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-launch ACLEDA Super App if selected
    if (widget.request.paymentMethod.toLowerCase().contains('acleda')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchAcledaApp();
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _launchAcledaApp() async {
    setState(() => _hasLaunchedApp = true);
    await PaymentLauncherService.launchAcledaSuperApp(
      amount: widget.totalAmount,
      bookingCode: 'TRIPZ-${widget.request.busScheduleId}',
    );
  }

  Future<void> _launchAbaApp() async {
    setState(() => _hasLaunchedApp = true);
    await PaymentLauncherService.launchAbaMobileApp();
  }

  Future<void> _launchPayPal() async {
    setState(() => _hasLaunchedApp = true);
    await PaymentLauncherService.launchPayPal();
  }

  Future<void> _handleConfirmPayment() async {
    if (_isVerifying) return;

    setState(() => _isVerifying = true);

    try {
      // Simulate verification delay for bank network confirmation
      await Future.delayed(const Duration(milliseconds: 1200));

      final success = await widget.controller.submitBooking(widget.request);

      if (success) {
        final booking = widget.controller.bookingResult.value!;
        if (mounted) {
          Get.off(
            () => BookingConfirmationScreen(booking: booking),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isVerifying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Text(
                widget.controller.submitError.value.isNotEmpty
                    ? widget.controller.submitError.value
                    : 'Payment verification failed. Please try again.',
                style: AppFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text('Payment error: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final paymentMethod = widget.request.paymentMethod;

    final primaryText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0);

    final khrAmount = (widget.totalAmount * 4100).round();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'payment_processing'.tr,
          style: AppFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  'Secure',
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Trip & Price Summary Card
              _buildTripSummaryCard(
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
                khrAmount: khrAmount,
              ),

              const SizedBox(height: 18),

              // 2. Specific Payment Gateway Section
              if (paymentMethod.toLowerCase().contains('acleda'))
                _buildAcledaPaymentSection(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                )
              else if (paymentMethod.toLowerCase().contains('aba'))
                _buildAbaPaymentSection(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                )
              else if (paymentMethod.toLowerCase().contains('paypal'))
                _buildPayPalPaymentSection(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                )
              else
                _buildMastercardPaymentSection(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                ),

              const SizedBox(height: 28),

              // 3. Confirm & Get Ticket CTA Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: AppColors.green.withValues(alpha: 0.4),
                  ),
                  onPressed: _isVerifying ? null : _handleConfirmPayment,
                  child: _isVerifying
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'verifying_payment'.tr,
                              style: AppFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.circleCheck,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'pay_and_get_ticket'.tr,
                              style: AppFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: secondaryText.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Your ticket will be issued immediately upon payment.',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          color: secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripSummaryCard({
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
    required int khrAmount,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.fromLocation.trDb,
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: AppColors.green,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.toLocation.trDb,
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.request.passengers.length} ${widget.request.passengers.length == 1 ? 'Seat' : 'Seats'}',
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 12),

          // Selected Seats & Passenger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'passenger'.tr,
                    style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.request.passengers.first.name,
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'selected_seats'.tr,
                    style: AppFonts.dmSans(fontSize: 11, color: secondaryText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.request.passengers.map((p) => p.seatNumber).join(', '),
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 14),

          // Total Price Highlight
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'total_price'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                  Text(
                    '≈ ${khrAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} KHR',
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      color: secondaryText.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Text(
                '\$${widget.totalAmount.toStringAsFixed(2)}',
                style: AppFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // ACLEDA BANK PAYMENT SECTION
  // =========================================================================
  Widget _buildAcledaPaymentSection({
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
    // KHQR payload: real NBC-standard KHQR with amount + booking reference
    final bookingRef = 'TRIPZ-${widget.request.busScheduleId}-${widget.request.passengers.map((p) => p.seatNumber).join('')}';
    final khrAmount = (widget.totalAmount * 4100).round();
    // Generate real KHQR string (amount pre-filled, scannable by ACLEDA/Bakong)
    final qrPayload = PaymentLauncherService.generateKhqrString(
      amount: widget.totalAmount,
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
            color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.2 : 0.1),
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                _buildStepLabel(
                  step: '1',
                  label: 'Scan this QR code in ACLEDA app',
                  secondaryText: secondaryText,
                ),
                const SizedBox(height: 10),

                // KHQR Code Box (amount-embedded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F3B66).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '\$${widget.totalAmount.toStringAsFixed(2)}',
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
                                color: const Color(0xFF0F3B66).withValues(alpha: 0.6),
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
                _buildStepLabel(
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161922) : const Color(0xFFF1F5F9),
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
                              '\$${widget.totalAmount.toStringAsFixed(2)}',
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
                          text: widget.totalAmount.toStringAsFixed(2),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Amount copied: \$${widget.totalAmount.toStringAsFixed(2)}',
                              style: AppFonts.dmSans(color: Colors.white, fontSize: 13),
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
                          color: const Color(0xFF0F3B66).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0F3B66).withValues(alpha: 0.2),
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
                    onPressed: _launchAcledaApp,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            color: isDark ? const Color(0xFFFFDF79) : const Color(0xFF7A6000),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── STEP 3: Return & confirm ──
                _buildStepLabel(
                  step: '3',
                  label: 'Return here & tap \'Pay & Get Ticket\'',
                  secondaryText: secondaryText,
                ),

                if (_hasLaunchedApp) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  /// Numbered step label widget
  Widget _buildStepLabel({
    required String step,
    required String label,
    required Color secondaryText,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF0F3B66),
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

  // =========================================================================
  // ABA BANK PAYMENT SECTION
  // =========================================================================
  Widget _buildAbaPaymentSection({
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF005A9C), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF005A9C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.buildingColumns,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  'ABA Bank (ABA PAY)',
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
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowUpRightFromSquare,
                      size: 15,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005A9C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _launchAbaApp,
                    label: Text(
                      'open_aba_to_pay'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // PAYPAL PAYMENT SECTION
  // =========================================================================
  Widget _buildPayPalPaymentSection({
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
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
                onPressed: _launchPayPal,
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

  // =========================================================================
  // MASTERCARD PAYMENT SECTION
  // =========================================================================
  Widget _buildMastercardPaymentSection({
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
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
            controller: _cardNumberController,
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
                  controller: _cardExpiryController,
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
                  controller: _cardCvvController,
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
