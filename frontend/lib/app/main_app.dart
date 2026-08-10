import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/contact/presentation/contact_screen.dart';
import 'package:frontend/features/history/presentation/history_screen.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/profile/presentation/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Scaffold(
      body: _screens[_selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xff4FD18B),
        unselectedItemColor: isDarkMode
            ? const Color(0xFF94A3B8)
            : Color(0xff64748B),
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 10),
        backgroundColor: isDarkMode ? const Color(0xFF1E222B) : Colors.white,
        elevation: isDarkMode ? 8 : 8,
        iconSize: 23,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.houseChimney),
            activeIcon: FaIcon(FontAwesomeIcons.houseChimney, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.ticket),
            activeIcon: FaIcon(FontAwesomeIcons.ticket, size: 28),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.phone),
            activeIcon: FaIcon(FontAwesomeIcons.phone, size: 28),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.circleUser),
            activeIcon: FaIcon(FontAwesomeIcons.circleUser, size: 28),
            label: 'Me',
          ),
        ],
      ),
    );
  }
}
