import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

/// Top overlay: back button, station search input, and map/list toggle button.
class MapSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final bool showListView;
  final VoidCallback onToggleView;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;

  const MapSearchBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.showListView,
    required this.onToggleView,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back Button
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.angleLeft,
                size: 20,
                color: textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Search Input
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: Color(0xFF22C55E), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => onSearchChanged(),
                    style: AppFonts.dmSans(fontSize: 14, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search bus station or city...',
                      hintStyle:
                          AppFonts.dmSans(fontSize: 13, color: textSecondary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      onSearchChanged();
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // List / Map Toggle Button
        GestureDetector(
          onTap: onToggleView,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: showListView ? const Color(0xFF22C55E) : cardBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                showListView ? Icons.map_rounded : Icons.list_rounded,
                size: 22,
                color: showListView ? Colors.white : textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
