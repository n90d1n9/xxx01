import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const ProviderScope(child: ConstructionManagementApp()));
}

class ConstructionManagementApp extends StatelessWidget {
  const ConstructionManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Manajemen Proyek Konstruksi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      ),
      home: const HomePage(),
    );
  }
}
