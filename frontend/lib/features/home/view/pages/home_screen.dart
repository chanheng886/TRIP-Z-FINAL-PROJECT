import 'package:flutter/material.dart';
import 'package:frontend/features/home/view/pages/home_screen_desktop.dart';
import 'package:frontend/features/home/view/pages/home_screen_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: HomeScreenMobile(),
      desktop: HomeScreenDesktop(),
    );
  }
}
