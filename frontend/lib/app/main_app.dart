import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/ai/view/ai_chat_floating_button.dart';
import 'package:frontend/features/contact/view/contact_screen.dart';
import 'package:frontend/features/history/view/history_screen.dart';
import 'package:frontend/features/home/view/pages/home_screen.dart';
import 'package:frontend/features/profile/view/profile_screen.dart';
import 'package:get/get.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    HistoryScreen(),
    ContactScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      body: Stack(
        children: [
          _screens[_selectIndex],
          const AiChatFloatingButton(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        // Access locale to ensure reactivity when language switches
        final _ = languageController.locale.value;
        return BottomNavigationBar(
          currentIndex: _selectIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xff4FD18B),
          unselectedItemColor: isDarkMode
              ? const Color(0xFF94A3B8)
              : const Color(0xff64748B),
          selectedLabelStyle: AppFonts.dmSans(fontSize: 12),
          unselectedLabelStyle: AppFonts.dmSans(fontSize: 10),
          backgroundColor: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
          elevation: 8,
          iconSize: 23,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const FaIcon(FontAwesomeIcons.houseChimney),
              activeIcon: const FaIcon(FontAwesomeIcons.houseChimney, size: 28),
              label: 'nav_home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const FaIcon(FontAwesomeIcons.ticket),
              activeIcon: const FaIcon(FontAwesomeIcons.ticket, size: 28),
              label: 'nav_history'.tr,
            ),
            BottomNavigationBarItem(
              icon: const FaIcon(FontAwesomeIcons.phone),
              activeIcon: const FaIcon(FontAwesomeIcons.phone, size: 28),
              label: 'nav_contact'.tr,
            ),
            BottomNavigationBarItem(
              icon: const FaIcon(FontAwesomeIcons.circleUser),
              activeIcon: const FaIcon(FontAwesomeIcons.circleUser, size: 28),
              label: 'nav_me'.tr,
            ),
          ],
        );
      }),
    );
  }
}
