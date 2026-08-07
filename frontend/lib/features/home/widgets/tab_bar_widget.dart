import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class TabBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          splashBorderRadius: BorderRadius.circular(30),
          overlayColor: WidgetStateProperty.all(Color(0xffD4F3E2)),
          isScrollable: false,
          unselectedLabelColor: Color(0xff64748B),
          labelColor: Colors.white,
          indicator: BoxDecoration(
            color: Color(0xff4FD18B),
            borderRadius: BorderRadius.circular(30),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.busSide, size: 20),
                  SizedBox(width: 5),
                  Text('Bus Booking', style: GoogleFonts.dmSans(fontSize: 16)),
                ],
              ),
            ),

            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.bed, size: 20),
                  SizedBox(width: 5),
                  Text('Bed Booking', style: GoogleFonts.dmSans(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
