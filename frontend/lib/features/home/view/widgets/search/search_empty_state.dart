import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Empty state when no destinations match the search query
class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onClear;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color cardBg;
  final Color borderColor;
  final bool isDark;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
    required this.onClear,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.cardBg,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2430)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.mapLocationDot,
                  size: 32,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'no_data'.tr,
              style: AppFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No cities or stations matched "$searchQuery".\nTry checking spelling or exploring popular spots.',
              textAlign: TextAlign.center,
              style: AppFonts.dmSans(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cardBg,
                foregroundColor: AppColors.green,
                side: BorderSide(color: borderColor),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onClear,
              icon: const FaIcon(FontAwesomeIcons.xmark, size: 12),
              label: Text(
                'Clear Search',
                style: AppFonts.dmSans(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
