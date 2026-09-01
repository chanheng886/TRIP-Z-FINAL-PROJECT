import 'package:flutter/material.dart';
import 'package:frontend/features/history/view/history_desktop.dart';
import 'package:frontend/features/history/view/history_mobile.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: HistoryMobile(),
      desktop: HistoryDesktop(),
    );
  }
}
