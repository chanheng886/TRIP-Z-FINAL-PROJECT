import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/shared/model/bus_location.dart';
import 'package:frontend/features/home/view/pages/bus_schedule_mobile.dart';
import 'package:frontend/features/home/view/pages/search_screen_mobile.dart';
import 'package:frontend/features/home/view/widgets/date_picker_widget.dart';
import 'package:frontend/features/home/view/widgets/tab_bar_widget.dart';
import 'package:frontend/features/home/view/widgets/text_fileds_widget.dart';
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
  void dispose() {
    fromLocation.dispose();
    toLocation.dispose();
    leavingDate.dispose();
    returnDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scafoldBackground = Theme.of(context).scaffoldBackgroundColor;
    final textStyle = Theme.of(context).textTheme;
    final languageController = Get.find<LanguageController>();

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
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.user,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          title: Obx(() {
            final _ = languageController.locale.value;
            final user = Get.find<AuthViewmodel>().currentUser?.username ?? 'User';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'welcome_back'.tr} $user',
                  style: AppFonts.dmSans(
                    fontSize: 16,
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
                    const Icon(
                      FlutterRemix.map_pin_line,
                      size: 15,
                      color: Color(0xff4FD18B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'where_to_go'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: isDarkMode
                            ? const Color(0xff94A3B8)
                            : const Color(0xff1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
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
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBarWidget(),
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
                        offset: const Offset(1, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Obx(() {
                      final _ = languageController.locale.value;
                      return Column(
                        children: [
                          // From Location Text Field
                          InkWell(
                            onTap: () async {
                              final result = await Get.to<BusLocation>(
                                () => const SearchScreenMobile(),
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
                              title: 'from'.tr,
                              subTitle: fromLocation.text.isEmpty
                                  ? 'select_origin'.tr
                                  : fromLocation.text.trDb,
                              btn: IconButton(
                                onPressed: () {
                                  setState(() {
                                    final tempName = fromLocation.text;
                                    final tempId = fromLocationId;
                                    fromLocation.text = toLocation.text;
                                    fromLocationId = toLocationId;
                                    toLocation.text = tempName;
                                    toLocationId = tempId;
                                  });
                                },
                                icon: CircleAvatar(
                                  backgroundColor: isDarkMode
                                      ? const Color(0xFF2C313C)
                                      : Colors.white,
                                  child: const Icon(
                                    FlutterRemix.arrow_up_down_line,
                                    color: Color(0xff4FD18B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // To Location Text Field
                          InkWell(
                            onTap: () async {
                              final result = await Get.to<BusLocation>(
                                () => const SearchScreenMobile(),
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
                              title: 'to'.tr,
                              subTitle: toLocation.text.isEmpty
                                  ? 'select_destination'.tr
                                  : toLocation.text.trDb,
                            ),
                          ),
                          // Leaving Date Text Field
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
                              title: 'departure_date'.tr,
                              subTitle: leavingDate.text.isEmpty
                                  ? 'select_date'.tr
                                  : leavingDate.text,
                            ),
                          ),
                          // Return Date (Optional)
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
                              title: 'return_date'.tr,
                              subTitle: returnDate.text.isEmpty
                                  ? 'select_date'.tr
                                  : returnDate.text,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Find Bus Schedule Button
                          SizedBox(
                            width: 310,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff4FD18B),
                              ),
                              onPressed: () {
                                if (fromLocationId == null ||
                                    toLocationId == null ||
                                    leavingDate.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Please select From, To, and Leaving Date",
                                        style: AppFonts.dmSans(
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
                                  const FaIcon(
                                    FontAwesomeIcons.magnifyingGlass,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'find_buses'.tr,
                                    style: AppFonts.dmSans(
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
                      );
                    }),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.bed,
                    size: 40,
                    color: Color(0xff4FD18B),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bed Booking Coming Soon",
                    style: AppFonts.dmSans(
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
