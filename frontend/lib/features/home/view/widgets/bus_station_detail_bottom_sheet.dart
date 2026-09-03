import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/model/bus_station.dart';
import 'package:get/get.dart';

class BusStationDetailBottomSheet extends StatelessWidget {
  final BusStation station;
  final void Function(BusStation station)? onSelectAsOrigin;

  const BusStationDetailBottomSheet({
    super.key,
    required this.station,
    this.onSelectAsOrigin,
  });

  static void show(
    BuildContext context, {
    required BusStation station,
    void Function(BusStation station)? onSelectAsOrigin,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BusStationDetailBottomSheet(
        station: station,
        onSelectAsOrigin: onSelectAsOrigin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? AppColors.darkCardBackground : Colors.white;
    final textPrimary = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final textSecondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final isKhmer = Get.find<LanguageController>().isKhmer;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Station Image Header (if available)
            if (station.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: station.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDarkMode
                                ? const Color(0xFF2C313C)
                                : Colors.grey.shade200,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.bus,
                                size: 36,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Rating Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFB800),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                station.rating.toString(),
                                style: AppFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // City Pill
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_city_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                station.city,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
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
                ),
              ),
            const SizedBox(height: 16),

            // Station Name
            Text(
              station.localizedName(isKhmer),
              style: AppFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Address Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    station.localizedAddress(isKhmer),
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info Quick Badges: Hours & Phone
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF222630)
                          : const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hours',
                                style: AppFonts.dmSans(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                station.openingHours,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: station.phone));
                      Get.snackbar(
                        'Copied',
                        'Phone number copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF22C55E),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF222630)
                            : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: Color(0xFF22C55E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone',
                                  style: AppFonts.dmSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                                Text(
                                  station.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Operating Bus Companies
            Text(
              'Operating Bus Companies',
              style: AppFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: station.operators.map((op) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1B382B)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.busSimple,
                        size: 12,
                        color: Color(0xFF22C55E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        op,
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? const Color(0xFF34D979)
                              : const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Facilities Section
            if (station.facilities.isNotEmpty) ...[
              Text(
                'Station Amenities',
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: station.facilities.map((f) {
                  return Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: isDarkMode
                        ? const Color(0xFF242428)
                        : const Color(0xFFF1F5F9),
                    label: Text(
                      f,
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        color: textPrimary,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Action Button: "Select as Origin / Departure"
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  onSelectAsOrigin?.call(station);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_bus_filled_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Select as Departure Station',
                      style: AppFonts.dmSans(
                        fontSize: 15,
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
      ),
    );
  }
}
