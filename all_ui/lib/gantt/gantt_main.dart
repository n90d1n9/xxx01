import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'screens/gantt_screen.dart';

// Models

// UI Components

// Custom painter for dependency arrows

// Main app entry point
class GanttChartApp extends StatelessWidget {
  const GanttChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Advanced Gantt Chart',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const GanttChartScreen(),
      ),
    );
  }
}

void main() {
  runApp(const GanttChartApp());
}
