import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/gantt_theme.dart';
import 'features/gantt/gantt_screen.dart';

void main() {
  runApp(const ProviderScope(child: GanttApp()));
}

class GanttApp extends StatelessWidget {
  const GanttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Gantt Chart',
      debugShowCheckedModeBanner: false,
      theme: GanttTheme.dark,
      home: const GanttScreen(),
    );
  }
}
