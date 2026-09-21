import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// Quick-pick chips showing popular destinations in Cambodia
class SearchPopularDestinations extends StatelessWidget {
  final List<Map<String, dynamic>> popularSpots;
  final ValueChanged<String> onSelectSpot;
  final Color cardBg;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDark;

  const SearchPopularDestinations({
    super.key,
    required this.popularSpots,
    required this.onSelectSpot,
    required this.cardBg,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.fire,
                size: 13,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              Text(
                'Popular Destinations',
                style: AppFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: secondaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularSpots.map((spot) {
            final name = spot['name'] as String;
            final dynamic icon = spot['icon'];
            final localizedName = name.trDb;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelectSpot(name),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(icon, size: 12, color: AppColors.green),
                      const SizedBox(width: 6),
                      Text(
                        localizedName,
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
