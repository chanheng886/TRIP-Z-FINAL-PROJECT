import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class SummaryCardData {
  final String label;
  final int count;
  final FaIconData icon;
  final Color color;
  final int tabIndex;

  const SummaryCardData({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.tabIndex,
  });
}

class AdminSummaryCard extends StatelessWidget {
  final SummaryCardData card;
  final Color cardBg;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final ValueChanged<int> onCardTap;

  const AdminSummaryCard({
    super.key,
    required this.card,
    required this.cardBg,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCardTap(card.tabIndex),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: FaIcon(
                        card.icon,
                        color: AppColors.green,
                        size: 12,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 9,
                    color: secondaryText.withValues(alpha: 0.6),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${card.count}',
                style: AppFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                card.label,
                style: AppFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
