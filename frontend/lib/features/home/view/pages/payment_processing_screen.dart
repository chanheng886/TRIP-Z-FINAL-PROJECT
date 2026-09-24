import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/view/pages/aba_payway_webview_screen.dart';
import 'package:frontend/features/home/view/pages/booking_confirmation_screen.dart';
import 'package:frontend/features/home/view/widgets/payment/aba_payment_section.dart';
import 'package:frontend/features/home/view/widgets/payment/acleda_payment_section.dart';
import 'package:frontend/features/home/view/widgets/payment/mastercard_payment_section.dart';
import 'package:frontend/features/home/view/widgets/payment/payment_action_button.dart';
import 'package:frontend/features/home/view/widgets/payment/payment_trip_summary_card.dart';
import 'package:frontend/features/home/view/widgets/payment/paypal_payment_section.dart';
import 'package:frontend/features/home/viewmodel/booking_view_model.dart';
import 'package:frontend/shared/model/booking_request.dart';
import 'package:frontend/shared/service/aba_payway_service.dart';
import 'package:frontend/shared/service/payment_launcher_service.dart';
import 'package:get/get.dart';

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

  // ABA Payway state
  bool _isAbaLoading = false;
  bool _isSimulating = false;
  String? _abaTransactionId;
  String? _abaQrString;
  String? _abaQrImage;
  String? _abaDeeplink;
  String? _abaCheckoutUrl;
  Timer? _abaPollTimer;

  // Card form controllers (for Mastercard option)
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.request.paymentMethod.toLowerCase().contains('aba') ||
        (!widget.request.paymentMethod.toLowerCase().contains('acleda') &&
         !widget.request.paymentMethod.toLowerCase().contains('paypal'))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initAbaPayway();
      });
    } else if (widget.request.paymentMethod.toLowerCase().contains('acleda')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchAcledaApp();
      });
    }
  }

  @override
  void dispose() {
    _abaPollTimer?.cancel();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _initAbaPayway() async {
    if (_isAbaLoading) return;

    final bookingRef = 'TRIPZ-${widget.request.busScheduleId}-${widget.request.passengers.map((p) => p.seatNumber).join('')}';

    setState(() {
      _isAbaLoading = true;
      _abaTransactionId = bookingRef;
      _abaDeeplink = 'abamobilebank://';
    });

    try {
      final result = await AbaPaywayService.createCheckoutUrl(
        bookingId: widget.request.busScheduleId,
        amount: widget.totalAmount,
      );

      if (!mounted) return;
      setState(() {
        _isAbaLoading = false;
        if (result.transactionId.isNotEmpty) {
          _abaTransactionId = result.transactionId;
        }
        _abaQrString = result.qrString;
        _abaQrImage = result.qrImage;
        if (result.abapayDeeplink != null && result.abapayDeeplink!.isNotEmpty) {
          _abaDeeplink = result.abapayDeeplink;
        }
        _abaCheckoutUrl = result.checkoutUrl;
      });

      if (result.transactionId.isNotEmpty) {
        _startAbaPolling(result.transactionId);
      }
    } catch (e) {
      debugPrint('[AbaPayway] Gateway checkout notice: $e');
      if (!mounted) return;
      setState(() {
        _isAbaLoading = false;
        _abaDeeplink ??= 'abamobilebank://';
      });
    }
  }

  void _startAbaPolling(String tranId) {
    _abaPollTimer?.cancel();
    _abaPollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        final status = await AbaPaywayService.checkTransaction(tranId);
        if (status.isApproved) {
          timer.cancel();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ABA Payment confirmed! Issuing your ticket...',
                        style: AppFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
            await _handleConfirmPayment();
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _simulateSandboxPayment() async {
    if (_abaTransactionId == null || _isSimulating) return;
    setState(() => _isSimulating = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Simulating payment approval in Sandbox...'),
          ],
        ),
        backgroundColor: const Color(0xFF005A9C),
        duration: const Duration(seconds: 2),
      ),
    );

    final ok = await AbaPaywayService.simulatePaymentApproval(_abaTransactionId!);
    if (!ok && mounted) {
      setState(() => _isSimulating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulation failed. Please check backend connection.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _launchAcledaApp() async {
    setState(() => _hasLaunchedApp = true);
    await PaymentLauncherService.launchAcledaSuperApp(
      amount: widget.totalAmount,
      bookingCode: 'TRIPZ-${widget.request.busScheduleId}',
    );
  }

  Future<void> _launchPayPal() async {
    setState(() => _hasLaunchedApp = true);
    await PaymentLauncherService.launchPayPal();
  }

  /// Opens the ABA Payway hosted checkout in a WebView.
  Future<void> _launchAbaPayway() async {
    final checkoutUrl = _abaCheckoutUrl;
    if (checkoutUrl == null || checkoutUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text('Checkout session not ready. Please try again.', style: AppFonts.dmSans()),
        ),
      );
      return;
    }

    // Open the ABA Payway WebView
    final payResult = await Get.to<AbaPaywayResult>(
      () => AbaPaywayWebviewScreen(
        checkoutUrl: checkoutUrl,
        amount: widget.totalAmount,
      ),
      transition: Transition.downToUp,
    );

    if (payResult == AbaPaywayResult.success && mounted) {
      await _handleConfirmPayment();
    } else if (payResult == AbaPaywayResult.cancelled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF374151),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Payment was cancelled. You can try again.',
            style: AppFonts.dmSans(color: Colors.white, fontSize: 13),
          ),
        ),
      );
    }
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
                    ? widget.controller.submitError.value.replaceFirst('Exception: ', '')
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
          icon: FaIcon(
            FontAwesomeIcons.angleLeft,
            size: 22,
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
              PaymentTripSummaryCard(
                request: widget.request,
                fromLocation: widget.fromLocation,
                toLocation: widget.toLocation,
                totalAmount: widget.totalAmount,
                khrAmount: khrAmount,
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // 2. Specific Payment Gateway Section (ABA Payway First)
              if (paymentMethod.toLowerCase().contains('aba') ||
                  (!paymentMethod.toLowerCase().contains('acleda') &&
                   !paymentMethod.toLowerCase().contains('paypal') &&
                   !paymentMethod.toLowerCase().contains('mastercard')))
                AbaPaymentSection(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                  totalAmount: widget.totalAmount,
                  request: widget.request,
                  isAbaLoading: _isAbaLoading,
                  abaQrString: _abaQrString,
                  abaQrImage: _abaQrImage,
                  abaDeeplink: _abaDeeplink,
                  abaTransactionId: _abaTransactionId,
                  isSimulating: _isSimulating,
                  onSimulateSandboxPayment: _simulateSandboxPayment,
                  onLaunchAbaPayway: _launchAbaPayway,
                )
              else if (paymentMethod.toLowerCase().contains('acleda'))
                AcledaPaymentSection(
                  request: widget.request,
                  totalAmount: widget.totalAmount,
                  hasLaunchedApp: _hasLaunchedApp,
                  onLaunchAcledaApp: _launchAcledaApp,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isDark: isDark,
                )
              else if (paymentMethod.toLowerCase().contains('paypal'))
                PaypalPaymentSection(
                  cardBg: cardBg,
                  onLaunchPayPal: _launchPayPal,
                )
              else
                MastercardPaymentSection(
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  isDark: isDark,
                  cardNumberController: _cardNumberController,
                  cardExpiryController: _cardExpiryController,
                  cardCvvController: _cardCvvController,
                ),

              const SizedBox(height: 28),

              // 3. Confirm & Get Ticket CTA Button
              PaymentActionButton(
                isVerifying: _isVerifying,
                onConfirm: _handleConfirmPayment,
                secondaryText: secondaryText,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
