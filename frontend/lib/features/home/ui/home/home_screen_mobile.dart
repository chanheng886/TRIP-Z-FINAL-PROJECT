import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/home/ui/search/search_screen_mobile.dart';
import 'package:frontend/features/home/widgets/tab_bar_widget.dart';
import 'package:frontend/features/home/widgets/text_fileds_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenMobile extends StatelessWidget {
  const HomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xffF7F8FC),
        appBar: AppBar(
          backgroundColor: Color(0xffF7F8FC),
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Image(
                image: CachedNetworkImageProvider(
                  'https://i.pinimg.com/736x/c5/8c/9d/c58c9d7eaaf5b09ee7b10bdb07ec1186.jpg',
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, chan',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E293B),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    FlutterRemix.map_pin_line,
                    size: 16,
                    color: Color(0xff4FD18B),
                  ),
                  Text(
                    'Where do you want to go?',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Color(0xff1E293B),
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
                  icon: FaIcon(FontAwesomeIcons.bell),
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
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
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
                        TextFiledsWidget(
                          leadingIcon: FlutterRemix.treasure_map_fill,
                          title: 'From',
                          subTitle: 'Phnom Penh',
                          btn: IconButton(
                            onPressed: () {},
                            icon: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                FlutterRemix.arrow_up_down_line,
                                color: Color(0xff4FD18B),
                              ),
                            ),
                          ),
                          page: SearchScreenMobile(),
                        ),
                        //✅ To Location Text Field
                        TextFiledsWidget(
                          leadingIcon: FlutterRemix.map_pin_fill,
                          title: 'To',
                          subTitle: 'Banteay Meanchey',
                        ),
                        //✅ Leaving Date Text Field
                        TextFiledsWidget(
                          leadingIcon: FlutterRemix.calendar_event_fill,
                          title: 'Leaving',
                          subTitle: '2026-08-15',
                        ),
                        //✅ Return Date (Optional)
                        TextFiledsWidget(
                          leadingIcon: FlutterRemix.calendar_2_fill,
                          title: 'Return',
                          subTitle: 'optional',
                        ),
                        SizedBox(height: 5),
                        SizedBox(
                          width: 310,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff4FD18B),
                            ),
                            onPressed: () {},
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
