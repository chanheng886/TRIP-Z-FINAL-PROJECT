import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/shared/services/bus_location_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreenMobile extends StatelessWidget {
  final controller = Get.put(
    BusLocationViewmodel(BusLocationRepository(BusLocationService())),
  );
  SearchScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDarkMode
        ? const Color(0xFF12161E)
        : const Color(0xffF7F8FC);

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
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                cursorColor: const Color(0xff4FD18B),
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, top: 12),
                    child: const FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: Color(0xff64748B),
                      size: 16,
                    ),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Search location',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: isDarkMode
                        ? const Color(0xFF94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff4FD18B)),
          );
        }
        if (controller.errorMessage.value != "") {
          return Center(
            child: Text(
              'Failed to load data❌🥰',
              style: GoogleFonts.dmSans(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        }
        return controller.filteredLocations.isEmpty
            ? Center(
                child: Text(
                  "No Location Found😟",
                  style: GoogleFonts.dmSans(
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
                  return InkWell(
                    onTap: () {
                      final selectLocation =
                          controller.filteredLocations[index];
                      Get.back(result: selectLocation);
                    },
                    child: ListTile(
                      title: Text(
                        controller.filteredLocations[index].locationName,
                        style: GoogleFonts.dmSans(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              );
      }),
    );
  }
}
