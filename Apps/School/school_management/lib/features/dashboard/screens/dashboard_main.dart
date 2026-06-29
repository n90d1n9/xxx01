import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';

import 'dashboard_large.dart';
import 'dashboard_medium.dart';
import 'dashboard_phone.dart';

class DashboardMainScreen extends StatelessWidget {
  const DashboardMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: AdaptiveScreen(
            // If fit large screen (Desktop)
            largeScreen: DashboardLargeScreen(),
            mediumScreen: DashboardMediumScreen(),
            phone: DashboardPhoneScreen()));
  }
}
