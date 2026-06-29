import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:async';

import 'screens/timeline_screen.dart';

// ==================== MODELS ====================

// ==================== STATE MANAGEMENT ====================

// ==================== DATA PROVIDERS ====================

// ==================== MAIN APP ====================

void main() {
  runApp(const ProviderScope(child: HistoricalTimelineApp()));
}

class HistoricalTimelineApp extends StatelessWidget {
  const HistoricalTimelineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Historical Timeline Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
      ),
      home: const TimelineScreen(),
    );
  }
}

// ==================== MAIN SCREEN ====================
/* () => ref.read(timelineProvider.notifier).toggleShowFavorites(),
        ),
        IconButton(
          icon: Icon(
            state.showOnlyBookmarks ? Icons.bookmark : Icons.bookmark_border,
            color: state.showOnlyBookmarks ? Colors.amber : null,
          ),
          onPressed: () => ref.read(timelineProvider.notifier).toggleShowBookmarks(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterSheet(context),
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: */
