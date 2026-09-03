import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
import 'package:frontend/shared/service/user_location_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreenMobile extends StatelessWidget {
  const SearchScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<BusLocationViewmodel>()
        ? Get.find<BusLocationViewmodel>()
        : Get.put(
            BusLocationViewmodel(BusLocationRepository(BusLocationService())),
          );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDarkMode
        ? const Color(0xFF12161E)
        : const Color(0xffF7F8FC);
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            backgroundColor: const Color(0xff4FD18B),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const FaIcon(
                FontAwesomeIcons.angleLeft,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.shade300,
                blurRadius: 2,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Obx(() {
                final _ = languageController.locale.value;
                return TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  cursorColor: const Color(0xff4FD18B),
                  style: AppFonts.dmSans(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 14, top: 12),
                      child: FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: Color(0xff64748B),
                        size: 16,
                      ),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'search'.tr,
                    hintStyle: AppFonts.dmSans(
                      fontSize: 16,
                      color: isDarkMode
                          ? const Color(0xFF94A3B8)
                          : const Color(0xff64748B),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final _ = languageController.locale.value;
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff4FD18B)),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              'error'.tr,
              style: AppFonts.dmSans(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        }
        return controller.filteredLocations.isEmpty
            ? Center(
                child: Text(
                  'no_data'.tr,
                  style: AppFonts.dmSans(
                    fontSize: 16,
                    color: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : Colors.black87,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.only(top: kToolbarHeight + 24),
                children: [
                  // Use Current Location Tile
                  if (controller.searchQuery.value.isEmpty) ...[
                    InkWell(
                      onTap: () async {
                        final userLocService =
                            Get.isRegistered<UserLocationService>()
                            ? Get.find<UserLocationService>()
                            : Get.put(UserLocationService());

                        Get.snackbar(
                          "Locating...",
                          "Detecting your GPS position...",
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );

                        final pos = await userLocService.determinePosition(
                          showErrors: true,
                        );
                        if (pos != null) {
                          final nearest = userLocService.nearestStation.value;
                          if (nearest != null) {
                            final match = controller.locations.firstWhereOrNull(
                              (l) =>
                                  nearest.city.toLowerCase().contains(
                                    l.locationName.toLowerCase(),
                                  ) ||
                                  l.locationName.toLowerCase().contains(
                                    nearest.city.toLowerCase(),
                                  ) ||
                                  nearest.name.toLowerCase().contains(
                                    l.locationName.toLowerCase(),
                                  ),
                            );
                            if (match != null) {
                              Get.back(result: match);
                              return;
                            }
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFF22C55E,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Use My Current Location",
                                    style: AppFonts.dmSans(
                                      color: const Color(0xFF22C55E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Auto-detect nearest bus terminal via GPS",
                                    style: AppFonts.dmSans(
                                      color: isDarkMode
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 16),
                  ],

                  // Destination List
                  ...controller.filteredLocations.map((loc) {
                    final localizedName = loc.locationName.trDb;
                    return InkWell(
                      onTap: () {
                        Get.back(result: loc);
                      },
                      child: ListTile(
                        leading: const FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 16,
                          color: Color(0xff4FD18B),
                        ),
                        title: Text(
                          localizedName,
                          style: AppFonts.dmSans(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: (localizedName != loc.locationName)
                            ? Text(
                                loc.locationName,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xff64748B),
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                ],
              );
      }),
    );
  }
}
