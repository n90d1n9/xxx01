import 'package:adaptive_screen/index.dart';
import 'package:flutter/material.dart';
import 'package:syirkah/app/pages/home_large.dart';
import 'package:syirkah/modules/dashboard/pages/dashboard_page.dart';

import 'home_phone.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveScreen(
      largeScreen: DashboardPage(),
      mediumScreen: HomeLargePage(),
      phone: HomePhonePage(),
    );
  }
}