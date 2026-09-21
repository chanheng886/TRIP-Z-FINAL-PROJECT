import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/features/ai/view/ai_chat_floating_button.dart';
import 'package:frontend/features/contact/view/contact_screen.dart';
import 'package:frontend/features/history/view/history_screen.dart';
import 'package:frontend/features/home/view/pages/home_screen.dart';
import 'package:frontend/features/profile/view/profile_screen.dart';
import 'package:get/get.dart';

import 'package:frontend/shared/widgets/floating_pill_nav_bar.dart';

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
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_selectIndex],
      bottomNavigationBar: Obx(() {
        // Access locale to ensure reactivity when language switches
        final _ = languageController.locale.value;
        return FloatingPillNavBar(
          currentIndex: _selectIndex,
          onTap: _onItemTapped,
          trailing: const AiChatButton(),
          items: [
            PillNavItem(
              icon: FontAwesomeIcons.houseChimney,
              activeIcon: FontAwesomeIcons.houseChimney,
              label: 'nav_home'.tr,
            ),
            PillNavItem(
              icon: FontAwesomeIcons.ticket,
              activeIcon: FontAwesomeIcons.ticket,
              label: 'nav_history'.tr,
            ),
            PillNavItem(
              icon: FontAwesomeIcons.phone,
              activeIcon: FontAwesomeIcons.phone,
              label: 'nav_contact'.tr,
            ),
            PillNavItem(
              icon: FontAwesomeIcons.solidCircleUser,
              activeIcon: FontAwesomeIcons.solidCircleUser,
              label: 'nav_me'.tr,
            ),
          ],
        );
      }),
    );
  }
}
