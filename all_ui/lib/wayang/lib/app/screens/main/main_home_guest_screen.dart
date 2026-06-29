import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';

class MainHomeGuestScreen extends StatelessWidget {
  const MainHomeGuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: AdaptiveScreen(
        largeScreen: HomePhoneGuest(), //DashboardLargeScreen(),
        mediumScreen: HomePhoneGuest(), //DashboardMediumScreen(),
        phone: HomePhoneGuest(),
      ),
    );
  }
}

class HomePhoneGuest extends StatelessWidget {
  const HomePhoneGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Guest')),
      body: const Center(
        child: Text('This is the guest layout of the main home screen.'),
      ),
    );
  }
}
