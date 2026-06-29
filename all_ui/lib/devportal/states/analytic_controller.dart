import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';

class AnalyticsController extends StateNotifier<void> {
  //final Reader read;

  AnalyticsController(/* this.read */) : super(null);

  void exportData() {
    // In a real app, this would trigger data export
    print('Exporting analytics data...');
  }

  void viewAllLogs() {
    // In a real app, this would navigate to a detailed logs view
    print('Viewing all error logs...');
  }
}

final analyticsControllerProvider =
    StateNotifierProvider<AnalyticsController, void>((ref) {
      return AnalyticsController();
    });

// Helper functions

List<FlSpot> generateRandomSpots(int count, double min, double max) {
  final random = Random();
  return List.generate(count, (i) {
    return FlSpot(i.toDouble(), min + random.nextDouble() * (max - min));
  });
}
