import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_form_hero_header.dart';
import 'package:frontend/features/admin/widgets/admin_list_tiles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminBookingsTab extends StatelessWidget {
  final AdminDashboardViewmodel viewModel;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final void Function(String message, {required bool isError}) onShowSnack;

  const AdminBookingsTab({
    super.key,
    required this.viewModel,
    required this.isDark,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    required this.onShowSnack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFormHeroHeader(
            title: 'customer_bookings'.tr,
            subtitle: 'realtime_reservation_log'.tr,
            icon: FontAwesomeIcons.ticket,
            count: viewModel.bookings.length,
            isDark: isDark,
            primaryText: primaryText,
            secondaryText: secondaryText,
          ),
          const SizedBox(height: 16),
          Obx(() {
            final selDate = viewModel.selectedDate.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selDate != null
                      ? AppColors.green.withValues(alpha: 0.4)
                      : borderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.calendarDay,
                        size: 12,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selDate != null
                          ? DateFormat('EEE, MMM dd, yyyy').format(selDate)
                          : 'filter_bookings_date'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: selDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selDate != null ? primaryText : secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selDate != null)
                    GestureDetector(
                      onTap: () => viewModel.clearDateFilter(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'clear'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selDate ?? now,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(now.year + 1),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: isDark
                                  ? const ColorScheme.dark(
                                      primary: AppColors.green,
                                    )
                                  : const ColorScheme.light(
                                      primary: AppColors.green,
                                    ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && context.mounted) {
                        await viewModel.loadBookingsByDate(picked);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      'pick_date'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          if (viewModel.bookings.isEmpty && viewModel.bookingError.value.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      size: 30,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'failed_load_bookings'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      viewModel.bookingError.value,
                      textAlign: TextAlign.center,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: viewModel.loadOptions,
                      icon: const FaIcon(
                        FontAwesomeIcons.rotate,
                        size: 13,
                        color: Colors.white,
                      ),
                      label: Text('retry_bookings'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (viewModel.bookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Center(
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.ticket,
                      size: 34,
                      color: secondaryText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'no_bookings_recorded'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'passenger_reservations_appear'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...viewModel.bookings.map(
              (booking) => AdminBookingCard(
                booking: booking,
                cardBg: cardBackground,
                primaryText: primaryText,
                secondaryText: secondaryText,
                borderColor: borderColor,
                onMarkPaid: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      title: Text(
                        '${'confirm_booking'.tr}?',
                        style: AppFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      content: Text(
                        'Confirm that passenger "${booking.username}" has paid \$${booking.totalAmount.toStringAsFixed(2)} at the station counter.',
                        style: AppFonts.dmSans(
                          color: secondaryText,
                          fontSize: 13,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            'cancel'.tr,
                            style: AppFonts.dmSans(color: secondaryText),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'confirm'.tr,
                            style: AppFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final ok = await viewModel.updateBookingStatus(
                      bookingId: booking.id,
                      status: 'Paid',
                    );
                    if (ok) {
                      onShowSnack(
                        'Booking #${booking.id} confirmed and marked as Paid!',
                        isError: false,
                      );
                    } else {
                      onShowSnack(
                        viewModel.errorMessage.value.isNotEmpty
                            ? viewModel.errorMessage.value
                            : 'Failed to update booking status',
                        isError: true,
                      );
                    }
                  }
                },
                onCancel: () async {
                  final ok = await viewModel.updateBookingStatus(
                    bookingId: booking.id,
                    status: 'Cancelled',
                  );
                  if (ok) {
                    onShowSnack(
                      'Booking #${booking.id} marked as Cancelled',
                      isError: false,
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
