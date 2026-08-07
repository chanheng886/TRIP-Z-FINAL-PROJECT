import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return mobile;
    } else {
      return desktop;
    }
  }
}
