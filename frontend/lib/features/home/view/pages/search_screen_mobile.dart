import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreenMobile extends StatelessWidget {
  const SearchScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
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
            : ListView.builder(
                padding: const EdgeInsets.only(top: kToolbarHeight + 24),
                itemCount: controller.filteredLocations.length,
                itemBuilder: (context, index) {
                  final loc = controller.filteredLocations[index];
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
                },
              );
      }),
    );
  }
}
