import 'package:flutter/material.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/booking_request.dart';
import 'package:get/get.dart';

/// Card showing the trip route, passenger names, seats, and price breakdown
class PaymentTripSummaryCard extends StatelessWidget {
  final String fromLocation;
  final String toLocation;
  final BookingRequest request;
  final double totalAmount;
  final int khrAmount;
  final Color cardBg;
  final Color borderColor;
  final Color primaryText;
  final Color secondaryText;
  final bool isDark;

  const PaymentTripSummaryCard({
    super.key,
    required this.fromLocation,
    required this.toLocation,
    required this.request,
    required this.totalAmount,
    required this.khrAmount,
    required this.cardBg,
    required this.borderColor,
    required this.primaryText,
    required this.secondaryText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                        fromLocation.trDb,
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
                        toLocation.trDb,
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
                  '${request.passengers.length} ${request.passengers.length == 1 ? 'Seat' : 'Seats'}',
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
                    request.passengers.isNotEmpty
                        ? request.passengers.first.name
                        : '',
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
                    request.passengers.map((p) => p.seatNumber).join(', '),
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
                '\$${totalAmount.toStringAsFixed(2)}',
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
}
