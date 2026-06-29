// Providers
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/entity_count.dart';
import '../models/enums.dart';
import '../models/kpi.dart';

final currentFilterProvider = StateProvider<TimeFilter>(
  (ref) => TimeFilter.month,
);

final kpiDataProvider = Provider<List<KpiData>>((ref) {
  final filter = ref.watch(currentFilterProvider);

  // This would normally fetch from a repository based on the filter
  switch (filter) {
    case TimeFilter.day:
      return [
        KpiData(
          title: 'Student Attendance',
          value: 456,
          target: 500,
          progress: 0.91,
          icon: Icons.people,
          color: Colors.blue,
        ),
        KpiData(
          title: 'Academic Performance',
          value: 85,
          target: 100,
          progress: 0.85,
          icon: Icons.school,
          color: Colors.amber,
        ),
        KpiData(
          title: 'Islamic Studies',
          value: 92,
          target: 100,
          progress: 0.92,
          icon: Icons.book,
          color: Colors.green,
        ),
        KpiData(
          title: 'Extracurricular',
          value: 78,
          target: 100,
          progress: 0.78,
          icon: Icons.sports_soccer,
          color: Colors.purple,
        ),
      ];
    case TimeFilter.month:
      return [
        KpiData(
          title: 'Student Attendance',
          value: 472,
          target: 500,
          progress: 0.94,
          icon: Icons.people,
          color: Colors.blue,
        ),
        KpiData(
          title: 'Academic Performance',
          value: 87,
          target: 100,
          progress: 0.87,
          icon: Icons.school,
          color: Colors.amber,
        ),
        KpiData(
          title: 'Islamic Studies',
          value: 94,
          target: 100,
          progress: 0.94,
          icon: Icons.book,
          color: Colors.green,
        ),
        KpiData(
          title: 'Extracurricular',
          value: 82,
          target: 100,
          progress: 0.82,
          icon: Icons.sports_soccer,
          color: Colors.purple,
        ),
      ];
    case TimeFilter.semester:
      return [
        KpiData(
          title: 'Student Attendance',
          value: 485,
          target: 500,
          progress: 0.97,
          icon: Icons.people,
          color: Colors.blue,
        ),
        KpiData(
          title: 'Academic Performance',
          value: 90,
          target: 100,
          progress: 0.90,
          icon: Icons.school,
          color: Colors.amber,
        ),
        KpiData(
          title: 'Islamic Studies',
          value: 95,
          target: 100,
          progress: 0.95,
          icon: Icons.book,
          color: Colors.green,
        ),
        KpiData(
          title: 'Extracurricular',
          value: 88,
          target: 100,
          progress: 0.88,
          icon: Icons.sports_soccer,
          color: Colors.purple,
        ),
      ];
    case TimeFilter.year:
      return [
        KpiData(
          title: 'Student Attendance',
          value: 490,
          target: 500,
          progress: 0.98,
          icon: Icons.people,
          color: Colors.blue,
        ),
        KpiData(
          title: 'Academic Performance',
          value: 92,
          target: 100,
          progress: 0.92,
          icon: Icons.school,
          color: Colors.amber,
        ),
        KpiData(
          title: 'Islamic Studies',
          value: 96,
          target: 100,
          progress: 0.96,
          icon: Icons.book,
          color: Colors.green,
        ),
        KpiData(
          title: 'Extracurricular',
          value: 91,
          target: 100,
          progress: 0.91,
          icon: Icons.sports_soccer,
          color: Colors.purple,
        ),
      ];
  }
});

final entityDataProvider = Provider<List<EntityCount>>((ref) {
  final filter = ref.watch(currentFilterProvider);

  // Would normally pull from repository
  return [
    EntityCount(name: 'Students', count: 508, change: 12, isPositive: true),
    EntityCount(name: 'Teachers', count: 48, change: 3, isPositive: true),
    EntityCount(name: 'Staff', count: 36, change: 1, isPositive: true),
    EntityCount(name: 'Classes', count: 24, change: 0, isPositive: true),
  ];
});

final attendanceChartDataProvider = Provider<List<FlSpot>>((ref) {
  final filter = ref.watch(currentFilterProvider);

  // Sample data - would be fetched from a repository
  switch (filter) {
    case TimeFilter.day:
      return [
        FlSpot(0, 92),
        FlSpot(2, 95),
        FlSpot(4, 91),
        FlSpot(6, 96),
        FlSpot(8, 94),
        FlSpot(10, 92),
        FlSpot(12, 90),
      ];
    case TimeFilter.month:
      return [
        FlSpot(0, 91),
        FlSpot(5, 93),
        FlSpot(10, 95),
        FlSpot(15, 94),
        FlSpot(20, 96),
        FlSpot(25, 95),
        FlSpot(30, 97),
      ];
    case TimeFilter.semester:
      return [
        FlSpot(0, 90),
        FlSpot(1, 92),
        FlSpot(2, 94),
        FlSpot(3, 93),
        FlSpot(4, 96),
        FlSpot(5, 95),
      ];
    case TimeFilter.year:
      return [
        FlSpot(0, 89),
        FlSpot(2, 90),
        FlSpot(4, 92),
        FlSpot(6, 94),
        FlSpot(8, 95),
        FlSpot(10, 96),
        FlSpot(12, 97),
      ];
  }
});
