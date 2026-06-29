import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/legacy.dart';

import 'main_navigation_screen.dart';

class EnhancedBimbelApp extends StatelessWidget {
  const EnhancedBimbelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bimbel Pro - Enhanced',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
