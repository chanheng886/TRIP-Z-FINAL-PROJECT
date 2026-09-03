import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class HomeSearchCard extends StatelessWidget {
  final String fromLocationName;
  final String toLocationName;
  final String leavingDate;
  final String returnDate;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onLeavingTap;
  final VoidCallback onReturnTap;
  final VoidCallback onSwap;
  final VoidCallback onFindBus;

  const HomeSearchCard({
    super.key,
    required this.fromLocationName,
    required this.toLocationName,
    required this.leavingDate,
    required this.returnDate,
    required this.onFromTap,
    required this.onToTap,
    required this.onLeavingTap,
    required this.onReturnTap,
    required this.onSwap,
    required this.onFindBus,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDarkMode ? AppColors.darkCardBackground : Colors.white;
    final itemBg = isDarkMode
        ? const Color(0xFF222630)
        : const Color(0xFFF7F8FA);
    final textPrimary = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final textSecondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF94A3B8);
    final iconContainerBg = isDarkMode
        ? const Color(0xFF1B382B)
        : const Color(0xFFDCFCE7);
    const accentGreen = Color(0xFF22C55E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF2C313C)
              : const Color(0xFFE5E7EB).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. From Location Field
          _buildFieldTile(
            context: context,
            onTap: onFromTap,
            itemBg: itemBg,
            iconBg: iconContainerBg,
            icon: FlutterRemix.road_map_fill,
            iconColor: accentGreen,
            title: 'from'.tr,
            subtitle: fromLocationName.isEmpty
                ? 'where_hint'.tr
                : fromLocationName.trDb,
            isPlaceholder: fromLocationName.isEmpty,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            trailing: GestureDetector(
              onTap: onSwap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2C313C)
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    FlutterRemix.arrow_up_down_line,
                    size: 18,
                    color: accentGreen,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 2. To Location Field
          _buildFieldTile(
            context: context,
            onTap: onToTap,
            itemBg: itemBg,
            iconBg: iconContainerBg,
            icon: FlutterRemix.map_pin_2_fill,
            iconColor: accentGreen,
            title: 'to'.tr,
            subtitle: toLocationName.isEmpty
                ? 'where_hint'.tr
                : toLocationName.trDb,
            isPlaceholder: toLocationName.isEmpty,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 10),

          // 3. Leaving Date Field
          _buildFieldTile(
            context: context,
            onTap: onLeavingTap,
            itemBg: itemBg,
            iconBg: iconContainerBg,
            icon: FlutterRemix.calendar_event_fill,
            iconColor: accentGreen,
            title: 'leaving'.tr,
            subtitle: leavingDate.isEmpty
                ? 'select_date_hint'.tr
                : leavingDate,
            isPlaceholder: leavingDate.isEmpty,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 10),

          // 4. Return Date Field
          _buildFieldTile(
            context: context,
            onTap: onReturnTap,
            itemBg: itemBg,
            iconBg: iconContainerBg,
            icon: FlutterRemix.calendar_event_fill,
            iconColor: accentGreen,
            title: 'return_label'.tr,
            subtitle: returnDate.isEmpty
                ? 'optional_hint'.tr
                : returnDate,
            isPlaceholder: returnDate.isEmpty,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 16),

          // 5. "Find Bus" Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onFindBus,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: accentGreen.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'find_bus'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTile({
    required BuildContext context,
    required VoidCallback onTap,
    required Color itemBg,
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isPlaceholder,
    required Color textPrimary,
    required Color textSecondary,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        fontWeight:
                            isPlaceholder ? FontWeight.normal : FontWeight.w600,
                        color: isPlaceholder ? textSecondary : textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Optional Trailing Action (e.g. Swap button)
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
