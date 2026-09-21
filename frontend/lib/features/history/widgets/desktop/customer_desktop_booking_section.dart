import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/history/widgets/customer_booking_card.dart';
import 'package:frontend/features/history/widgets/history_empty_state.dart';
import 'package:frontend/shared/model/booking_response.dart';

class CustomerDesktopBookingSection extends StatelessWidget {
  final List<BookingResponse> allBookings;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Color cardBg;
  final Color borderColor;

  const CustomerDesktopBookingSection({
    super.key,
    required this.allBookings,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.cardBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final filteredBookings = allBookings.where((b) {
      if (selectedFilter == 'confirmed') {
        return b.bookingStatus == BookingStatus.Paid ||
            b.bookingStatus == BookingStatus.Confirmed;
      }
      if (selectedFilter == 'pending') {
        return b.bookingStatus == BookingStatus.Pending;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Pills Bar
        Row(
          children: [
            _buildFilterChip(
              'All Tickets (${allBookings.length})',
              'all',
            ),
            const SizedBox(width: 10),
            _buildFilterChip(
              'Confirmed / Paid',
              'confirmed',
            ),
            const SizedBox(width: 10),
            _buildFilterChip(
              'Pending Payment',
              'pending',
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Multi-column Grid of Customer Booking Cards
        Expanded(
          child: filteredBookings.isEmpty
              ? const Center(
                  child: HistoryEmptyState(
                    icon: FontAwesomeIcons.ticket,
                    title: 'No matching tickets',
                    subtitle: 'Try switching the filter to view all bookings.',
                  ),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 580,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                  ),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    return CustomerBookingCard(booking: filteredBookings[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;

    return InkWell(
      onTap: () => onFilterChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.green : borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
