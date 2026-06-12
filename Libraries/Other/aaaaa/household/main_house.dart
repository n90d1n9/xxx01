import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'screens/household_home_page.dart';

void main() {
  runApp(const ProviderScope(child: HouseholdApp()));
}

class HouseholdApp extends StatelessWidget {
  const HouseholdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Household Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HouseholdHomeScreen(),
    );
  }
}
