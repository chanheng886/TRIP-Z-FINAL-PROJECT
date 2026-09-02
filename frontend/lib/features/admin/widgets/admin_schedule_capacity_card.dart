import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminScheduleCapacityCard extends StatelessWidget {
  final int available;
  final int booked;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;

  const AdminScheduleCapacityCard({
    super.key,
    required this.available,
    required this.booked,
    required this.isDark,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = available + booked;
    final availPercent = total > 0 ? (available / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.chartSimple,
                      size: 13,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trip Availability',
                        style: AppFonts.dmSans(
                          fontSize: 14,
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
              Text(
                '${(availPercent * 100).toStringAsFixed(0)}% Open',
                style: AppFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (availPercent * 100).toInt(),
                    child: Container(color: AppColors.green),
                  ),
                  Expanded(
                    flex: ((1 - availPercent) * 100).toInt(),
                    child: Container(
                      color: isDark
                          ? const Color(0xFF333338)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Available: $available',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          color: secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF8A8A8E)
                            : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Booked: $booked',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          color: secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
