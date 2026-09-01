import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class TabBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.shade300,
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          splashBorderRadius: BorderRadius.circular(30),
          overlayColor: WidgetStateProperty.all(
            isDarkMode ? const Color(0xFF2C3E35) : const Color(0xffD4F3E2),
          ),
          isScrollable: false,
          unselectedLabelColor: isDarkMode
              ? const Color(0xFF94A3B8)
              : const Color(0xff64748B),
          labelColor: Colors.white,
          indicator: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.busSide, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'explore_cambodia'.tr,
                    style: AppFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.bed, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Hotel / Bed',
                    style: AppFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
