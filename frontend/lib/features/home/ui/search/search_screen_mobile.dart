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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xffF7F8FC),
      appBar: AppBar(
        backgroundColor: Color(0xffF7F8FC),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            backgroundColor: Color(0xff4FD18B),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: FaIcon(FontAwesomeIcons.angleLeft, color: Colors.white),
            ),
          ),
        ),
        title: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 2,
                offset: Offset(1, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                cursorColor: Color(0xff4FD18B),
                decoration: InputDecoration(
                  prefixIcon: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Color(0xff64748B),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Search location',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: Color(0xff64748B),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != "") {
          return Center(child: Text('Failed to load data❌🥰'));
        }
        return controller.filteredLocations.isEmpty
            ? Center(
                child: Text(
                  "No Location Found😟",
                  style: GoogleFonts.dmSans(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: controller.filteredLocations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      controller.filteredLocations[index].locationName,
                    ),
                  );
                },
              );
      }),
    );
  }
}
