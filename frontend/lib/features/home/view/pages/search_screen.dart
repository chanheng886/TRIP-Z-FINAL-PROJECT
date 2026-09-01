import 'package:flutter/material.dart';
import 'package:frontend/features/home/view/pages/search_screen_desktop.dart';
import 'package:frontend/features/home/view/pages/search_screen_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SearchScreenMobile(),
      desktop: SearchScreenDesktop(),
    );
  }
}
