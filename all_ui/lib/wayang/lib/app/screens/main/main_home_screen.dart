import 'package:adaptive_screen/adaptive_screen.dart';
import 'package:flutter/material.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveScreen(
      largeScreen: SafeArea(child: Text('Main Home Screen')),
      phone: SafeArea(child: HomePhone()),
    );
  }
}

class HomePhone extends StatelessWidget {
  const HomePhone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Phone Layout')),
      body: const Center(
        child: Text('This is the phone layout of the main home screen.'),
      ),
    );
  }
}
