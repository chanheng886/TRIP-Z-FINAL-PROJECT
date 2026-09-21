import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Top header bar with back navigation and styled search input field
class SearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final ValueChanged<String>? onChanged;
  final Color cardBg;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDark;

  const SearchHeader({
    super.key,
    required this.searchController,
    required this.focusNode,
    required this.onClear,
    this.onChanged,
    required this.cardBg,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12141A) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: borderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Back Button and Screen Title
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: FaIcon(
                  FontAwesomeIcons.angleLeft,
                  size: 24,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'select_destination'.tr.isNotEmpty
                          ? 'select_destination'.tr
                          : 'Select Destination',
                      style: AppFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      'Pick city or terminal in Cambodia',
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field
          AnimatedBuilder(
            animation: Listenable.merge([searchController, focusNode]),
            builder: (context, _) {
              final hasFocus = focusNode.hasFocus;
              final hasText = searchController.text.isNotEmpty;

              return Container(
                height: 50,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasFocus ? AppColors.green : borderColor,
                    width: hasFocus ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 15,
                      color: hasFocus ? AppColors.green : secondaryTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: focusNode,
                        cursorColor: AppColors.green,
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search city, province, or station...',
                          hintStyle: AppFonts.dmSans(
                            fontSize: 14,
                            color: secondaryTextColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: onChanged,
                      ),
                    ),
                    if (hasText)
                      IconButton(
                        splashRadius: 18,
                        icon: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: secondaryTextColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                        onPressed: () {
                          searchController.clear();
                          onClear();
                        },
                      )
                    else
                      const SizedBox(width: 10),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
