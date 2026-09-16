import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/view/pages/payment_processing_screen.dart';
import 'package:frontend/features/home/viewmodel/booking_view_model.dart';
import 'package:frontend/shared/model/booking_request.dart';
import 'package:frontend/shared/model/passenger.dart';
import 'package:get/get.dart';

void showBookingFormSheet(
  BuildContext context, {
  required BookingViewmodel controller,
  required int busScheduleId,
  required double basePrice,
  String fromLocation = 'Origin',
  String toLocation = 'Destination',
  String? busType,
  String? companyName,
}) {
  final authVM = Get.find<AuthViewmodel>();
  final user = authVM.currentUser;

  final nameController = TextEditingController(text: user?.username ?? '');
  final phoneController = TextEditingController(text: user?.phone ?? '');
  final emailController = TextEditingController(text: user?.email ?? '');
  String selectedGender = (user?.gender.isNotEmpty == true) ? user!.gender : 'Male';
  String selectedPayment = 'ACLEDA Bank';

  final totalAmount = controller.selectedSeats.length * basePrice;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDarkMode = Theme.of(ctx).brightness == Brightness.dark;
      final sheetBg = isDarkMode ? const Color(0xFF16181F) : Colors.white;
      final cardBg = isDarkMode ? const Color(0xFF1E222B) : const Color(0xFFF8FAFC);
      final primaryText = isDarkMode ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
      final secondaryText = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
      final borderColor = isDarkMode ? const Color(0xFF2A2E39) : const Color(0xFFE2E8F0);
      final fieldBg = isDarkMode ? const Color(0xFF1A1C24) : const Color(0xFFF1F5F9);

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.5 : 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Drag Handle
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF3B4252) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Sheet Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: isDarkMode ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.ticket,
                            size: 16,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'passenger_information'.tr,
                              style: AppFonts.dmSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'passenger_info_subtitle'.tr,
                              style: AppFonts.dmSans(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Divider(height: 1, thickness: 1, color: borderColor),

                // 3. Scrollable Form Content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 14,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seat Summary Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'selected_seats'.tr,
                                    style: AppFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    children: controller.selectedSeats.map((seat) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.green.withValues(
                                            alpha: isDarkMode ? 0.22 : 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.green.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          seat,
                                          style: AppFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.green,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'total_price'.tr,
                                    style: AppFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${totalAmount.toStringAsFixed(2)}',
                                    style: AppFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (user != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 13,
                                color: AppColors.green,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'autofilled_profile'.tr,
                                style: AppFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Full Name Field
                        _buildFieldHeader('full_name'.tr, primaryText, isRequired: true),
                        const SizedBox(height: 6),
                        TextField(
                          controller: nameController,
                          style: AppFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                          decoration: _buildInputDecoration(
                            hintText: 'enter_full_name'.tr,
                            icon: FontAwesomeIcons.solidUser,
                            iconColor: AppColors.green,
                            fieldBg: fieldBg,
                            borderColor: borderColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Phone Field
                        _buildFieldHeader('phone'.tr, primaryText, isRequired: true),
                        const SizedBox(height: 6),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: AppFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                          decoration: _buildInputDecoration(
                            hintText: 'enter_phone_number'.tr,
                            icon: FontAwesomeIcons.phone,
                            iconColor: const Color(0xFF10B981),
                            fieldBg: fieldBg,
                            borderColor: borderColor,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Email Field
                        _buildFieldHeader('email'.tr, primaryText),
                        const SizedBox(height: 6),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                          decoration: _buildInputDecoration(
                            hintText: 'enter_email'.tr,
                            icon: FontAwesomeIcons.solidEnvelope,
                            iconColor: const Color(0xFF3B82F6),
                            fieldBg: fieldBg,
                            borderColor: borderColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Gender Segmented Chips
                        _buildFieldHeader('gender'.tr, primaryText),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildGenderChip(
                              label: 'gender_male'.tr,
                              icon: FontAwesomeIcons.mars,
                              value: 'Male',
                              selectedValue: selectedGender,
                              isDark: isDarkMode,
                              onTap: () => setModalState(() => selectedGender = 'Male'),
                            ),
                            const SizedBox(width: 8),
                            _buildGenderChip(
                              label: 'gender_female'.tr,
                              icon: FontAwesomeIcons.venus,
                              value: 'Female',
                              selectedValue: selectedGender,
                              isDark: isDarkMode,
                              onTap: () => setModalState(() => selectedGender = 'Female'),
                            ),
                            const SizedBox(width: 8),
                            _buildGenderChip(
                              label: 'gender_other'.tr,
                              icon: FontAwesomeIcons.genderless,
                              value: 'Other',
                              selectedValue: selectedGender,
                              isDark: isDarkMode,
                              onTap: () => setModalState(() => selectedGender = 'Other'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Payment Method Section Header
                        _buildFieldHeader('payment_method'.tr, primaryText),
                        const SizedBox(height: 10),

                        // 1. ACLEDA Bank (Top / Recommended)
                        _buildPaymentTile(
                          title: 'ACLEDA Bank',
                          subtitle: 'acleda_desc'.tr,
                          icon: FontAwesomeIcons.buildingColumns,
                          accentColor: const Color(0xFF0F3B66),
                          value: 'ACLEDA Bank',
                          selectedValue: selectedPayment,
                          isDark: isDarkMode,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          isFeatured: true,
                          badgeText: 'recommended'.tr,
                          badgeBgColor: const Color(0xFFD4AF37),
                          badgeTextColor: const Color(0xFF1E293B),
                          onTap: () => setModalState(() => selectedPayment = 'ACLEDA Bank'),
                        ),
                        const SizedBox(height: 8),

                        // 2. ABA Payway
                        _buildPaymentTile(
                          title: 'ABA Payway',
                          subtitle: 'aba_desc'.tr,
                          icon: FontAwesomeIcons.buildingColumns,
                          accentColor: const Color(0xFF005A9C),
                          value: 'ABA Bank',
                          selectedValue: selectedPayment,
                          isDark: isDarkMode,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          badgeText: 'Cards • ABA Mobile • KHQR',
                          badgeBgColor: const Color(0xFF005A9C),
                          badgeTextColor: Colors.white,
                          onTap: () => setModalState(() => selectedPayment = 'ABA Bank'),
                        ),
                        const SizedBox(height: 8),

                        // 3. PayPal
                        _buildPaymentTile(
                          title: 'PayPal',
                          subtitle: 'paypal_desc'.tr,
                          icon: FontAwesomeIcons.paypal,
                          accentColor: const Color(0xFF0079C1),
                          value: 'PayPal',
                          selectedValue: selectedPayment,
                          isDark: isDarkMode,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          onTap: () => setModalState(() => selectedPayment = 'PayPal'),
                        ),
                        const SizedBox(height: 8),

                        // 4. Mastercard
                        _buildPaymentTile(
                          title: 'Mastercard',
                          subtitle: 'mastercard_desc'.tr,
                          icon: FontAwesomeIcons.ccMastercard,
                          accentColor: const Color(0xFFEB001B),
                          value: 'Mastercard',
                          selectedValue: selectedPayment,
                          isDark: isDarkMode,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          onTap: () => setModalState(() => selectedPayment = 'Mastercard'),
                        ),

                        const SizedBox(height: 10),

                        // Selected Payment Info Pill
                        _buildPaymentInfoPill(selectedPayment, isDarkMode),

                        const SizedBox(height: 24),

                        // 4. Confirm Booking Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Obx(() {
                            final isSubmitting = controller.isSubmitting.value;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: AppColors.green.withValues(alpha: 0.4),
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (nameController.text.trim().isEmpty ||
                                          phoneController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            content: Text(
                                              'please_fill_required_fields'.tr,
                                              style: AppFonts.dmSans(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final userId = authVM.currentUser?.id;
                                      if (userId == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            content: Text(
                                              'please_login_first'.tr,
                                              style: AppFonts.dmSans(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final passengers = controller.selectedSeats
                                          .map(
                                            (seat) => Passenger(
                                              name: nameController.text.trim(),
                                              seatNumber: seat,
                                            ),
                                          )
                                          .toList();

                                      final request = BookingRequest(
                                        customerId: userId,
                                        busScheduleId: busScheduleId,
                                        paymentMethod: selectedPayment,
                                        passengers: passengers,
                                      );

                                      // Close bottom sheet and navigate to Payment Processing Screen
                                      Navigator.of(context).pop();

                                      Get.to(
                                        () => PaymentProcessingScreen(
                                          controller: controller,
                                          request: request,
                                          fromLocation: fromLocation,
                                          toLocation: toLocation,
                                          busType: busType,
                                          companyName: companyName,
                                          totalAmount: totalAmount,
                                        ),
                                      );
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    selectedPayment.toLowerCase().contains('acleda')
                                        ? FontAwesomeIcons.buildingColumns
                                        : (selectedPayment.toLowerCase().contains('aba')
                                            ? FontAwesomeIcons.buildingColumns
                                            : (selectedPayment.toLowerCase().contains('paypal')
                                                ? FontAwesomeIcons.paypal
                                                : FontAwesomeIcons.ccMastercard)),
                                    size: 15,
                                    color: selectedPayment.toLowerCase().contains('acleda')
                                        ? const Color(0xFFFFDF79)
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedPayment.toLowerCase().contains('acleda')
                                        ? 'Pay with ACLEDA • \$${totalAmount.toStringAsFixed(2)}'
                                        : (selectedPayment.toLowerCase().contains('aba')
                                            ? 'Pay with ABA Payway • \$${totalAmount.toStringAsFixed(2)}'
                                            : '${'proceed_to_payment'.tr} • \$${totalAmount.toStringAsFixed(2)}'),
                                    style: AppFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildFieldHeader(String label, Color textColor, {bool isRequired = false}) {
  return Row(
    children: [
      Text(
        label,
        style: AppFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor.withValues(alpha: 0.9),
        ),
      ),
      if (isRequired) ...[
        const SizedBox(width: 3),
        const Text(
          '*',
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ],
  );
}

InputDecoration _buildInputDecoration({
  required String hintText,
  required FaIconData icon,
  required Color iconColor,
  required Color fieldBg,
  required Color borderColor,
}) {
  return InputDecoration(
    filled: true,
    fillColor: fieldBg,
    hintText: hintText,
    hintStyle: AppFonts.dmSans(
      fontSize: 13,
      color: const Color(0xFF94A3B8),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 12, right: 10),
      child: FaIcon(icon, size: 14, color: iconColor),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 38),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.green, width: 1.5),
    ),
  );
}

Widget _buildGenderChip({
  required String label,
  required FaIconData icon,
  required String value,
  required String selectedValue,
  required bool isDark,
  required VoidCallback onTap,
}) {
  final isSelected = selectedValue == value;
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.green.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark ? const Color(0xFF1A1C24) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.green
                : (isDark ? const Color(0xFF2A2E39) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 13,
              color: isSelected ? AppColors.green : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.dmSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.green : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildPaymentTile({
  required String title,
  required String subtitle,
  required FaIconData icon,
  required Color accentColor,
  required String value,
  required String selectedValue,
  required bool isDark,
  required Color cardBg,
  required Color borderColor,
  required Color primaryText,
  required Color secondaryText,
  required VoidCallback onTap,
  bool isFeatured = false,
  String? badgeText,
  Color? badgeBgColor,
  Color? badgeTextColor,
}) {
  final isSelected = selectedValue == value;
  final activeAccent = isFeatured ? const Color(0xFFD4AF37) : accentColor;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor.withValues(alpha: isDark ? 0.22 : 0.08)
            : cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? activeAccent : borderColor,
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: activeAccent.withValues(alpha: isDark ? 0.3 : 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Icon Container with Brand Theme
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.28 : 0.12),
              borderRadius: BorderRadius.circular(12),
              border: isFeatured
                  ? Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                      width: 1.2,
                    )
                  : null,
            ),
            child: Center(
              child: FaIcon(
                icon,
                size: 17,
                color: isFeatured && isDark
                    ? const Color(0xFFFFDF79)
                    : (isSelected
                        ? (isFeatured ? const Color(0xFFD4AF37) : accentColor)
                        : (isDark ? Colors.white70 : accentColor)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle & Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBgColor ?? const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: AppFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor ?? Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    color: secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Radio Selection Indicator
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? activeAccent
                    : (isDark
                        ? const Color(0xFF4A5568)
                        : const Color(0xFFCBD5E1)),
                width: isSelected ? 6 : 1.5,
              ),
              color: isSelected ? Colors.white : Colors.transparent,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPaymentInfoPill(String selectedPayment, bool isDark) {
  String infoText;
  IconData infoIcon = Icons.shield_outlined;
  Color iconColor = AppColors.green;

  switch (selectedPayment) {
    case 'ACLEDA Bank':
      infoText = 'Scan KHQR or pay directly with ACLEDA Mobile app upon confirmation.';
      iconColor = const Color(0xFFD4AF37);
      break;
    case 'ABA Bank':
      infoText = 'Scan KHQR or pay directly with ABA Mobile (ABA PAY).';
      iconColor = const Color(0xFF005A9C);
      break;
    case 'PayPal':
      infoText = 'Pay securely with your PayPal account or linked cards.';
      iconColor = const Color(0xFF0079C1);
      break;
    case 'Mastercard':
      infoText = 'Pay securely with Mastercard 128-bit encrypted checkout.';
      iconColor = const Color(0xFFEB001B);
      break;
    default:
      infoText = 'Select your payment method to proceed.';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: iconColor.withValues(alpha: isDark ? 0.12 : 0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: iconColor.withValues(alpha: 0.25),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(infoIcon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            infoText,
            style: AppFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ),
      ],
    ),
  );
}
