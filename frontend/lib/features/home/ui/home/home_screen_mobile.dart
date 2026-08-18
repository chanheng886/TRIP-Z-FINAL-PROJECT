import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/features/home/models/bus_location.dart';
import 'package:frontend/features/home/ui/bus_schedule/bus_schedule_mobile.dart';
import 'package:frontend/features/home/ui/search/search_screen_mobile.dart';
import 'package:frontend/features/home/widgets/date_picker_widget.dart';
import 'package:frontend/features/home/widgets/tab_bar_widget.dart';
import 'package:frontend/features/home/widgets/text_fileds_widget.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenMobile extends StatefulWidget {
  const HomeScreenMobile({super.key});

  @override
  State<HomeScreenMobile> createState() => _HomeScreenMobileState();
}

class _HomeScreenMobileState extends State<HomeScreenMobile> {
  final TextEditingController fromLocation = TextEditingController();
  final TextEditingController toLocation = TextEditingController();
  final TextEditingController leavingDate = TextEditingController();
  final TextEditingController returnDate = TextEditingController();
  int? fromLocationId;
  int? toLocationId;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scafoldBackground = Theme.of(context).scaffoldBackgroundColor;
    final textStyle = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scafoldBackground,
        appBar: AppBar(
          backgroundColor: scafoldBackground,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.user,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${Get.find<AuthViewmodel>().currentUser?.username ?? 'User'}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.white
                      : textStyle.headlineMedium?.color ??
                            const Color(0xff1E293B),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    FlutterRemix.map_pin_line,
                    size: 16,
                    color: Color(0xff4FD18B),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Where do you want to go?',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: isDarkMode
                          ? const Color(0xff94A3B8)
                          : Color(0xff1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: FaIcon(
                    FontAwesomeIcons.bell,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBarWidget(),
        ),
        body: TabBarView(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xFF2C313C)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.shade200,
                        blurRadius: 2,
                        offset: Offset(1, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        //✅ From Location Text Field
                        InkWell(
                          onTap: () async {
                            final result = await Get.to<BusLocation>(
                              () => SearchScreenMobile(),
                            );
                            if (result != null) {
                              setState(() {
                                fromLocation.text = result.locationName;
                                fromLocationId = result.id;
                              });
                            }
                          },
                          child: TextFiledsWidget(
                            leadingIcon: FlutterRemix.treasure_map_fill,
                            title: 'From',
                            subTitle: fromLocation.text.isEmpty
                                ? "Where?"
                                : fromLocation.text,
                            btn: IconButton(
                              onPressed: () async {},
                              icon: CircleAvatar(
                                backgroundColor: isDarkMode
                                    ? const Color(0xFF2C313C)
                                    : Colors.white,
                                child: Icon(
                                  FlutterRemix.arrow_up_down_line,
                                  color: Color(0xff4FD18B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //✅ To Location Text Field
                        InkWell(
                          onTap: () async {
                            final result = await Get.to<BusLocation>(
                              () => SearchScreenMobile(),
                            );
                            if (result != null) {
                              setState(() {
                                toLocation.text = result.locationName;
                                toLocationId = result.id;
                              });
                            }
                          },
                          child: TextFiledsWidget(
                            leadingIcon: FlutterRemix.map_pin_fill,
                            title: 'To',
                            subTitle: toLocation.text.isEmpty
                                ? "Where?"
                                : toLocation.text,
                          ),
                        ),
                        //✅ Leaving Date Text Field
                        InkWell(
                          onTap: () async {
                            final picked = await datePopUpPicker(
                              context,
                              initaialDate: leavingDate.text.isNotEmpty
                                  ? DateTime.tryParse(leavingDate.text)
                                  : null,
                            );
                            if (picked != null) {
                              setState(() {
                                leavingDate.text =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: TextFiledsWidget(
                            leadingIcon: FlutterRemix.calendar_event_fill,
                            title: 'Leaving',
                            subTitle: leavingDate.text.isEmpty
                                ? 'Select Date'
                                : leavingDate.text,
                          ),
                        ),
                        //✅ Return Date (Optional)
                        InkWell(
                          onTap: () async {
                            final picked = await datePopUpPicker(
                              context,
                              initaialDate: returnDate.text.isNotEmpty
                                  ? DateTime.tryParse(returnDate.text)
                                  : null,
                            );
                            if (picked != null) {
                              setState(() {
                                returnDate.text =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: TextFiledsWidget(
                            leadingIcon: FlutterRemix.calendar_2_fill,
                            title: 'Return',
                            subTitle: returnDate.text.isEmpty
                                ? "Optional"
                                : returnDate.text,
                          ),
                        ),
                        SizedBox(height: 5),
                        //✅ Find Bus Schedule Button
                        SizedBox(
                          width: 310,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff4FD18B),
                            ),
                            onPressed: () {
                              if (fromLocationId == null ||
                                  toLocationId == null ||
                                  leavingDate.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please select From, To, and Leaving Date",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                                return;
                              }
                              Get.to(
                                () => BusScheduleMobile(
                                  fromLocationId: fromLocationId!,
                                  toLocationId: toLocationId!,
                                  fromLocationName: fromLocation.text,
                                  toLocationName: toLocation.text,
                                  travelDate: DateTime.parse(leavingDate.text),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 20),
                                Text(
                                  'Find Bus',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
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
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.bed,
                    size: 40,
                    color: Color(0xff4FD18B),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Bed Booking Coming Soon",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
