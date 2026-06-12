import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: CarRepairApp()));
}

class CarRepairApp extends StatelessWidget {
  const CarRepairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Repair & Maintenance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
