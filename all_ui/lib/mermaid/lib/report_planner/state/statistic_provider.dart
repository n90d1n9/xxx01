// Statistics Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'filter_items_provider.dart';

final statisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final items = ref.watch(filteredItemsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final todayItems = items.where((item) {
    final itemDate = DateTime(
      item.startTime.year,
      item.startTime.month,
      item.startTime.day,
    );
    return itemDate == today;
  }).toList();

  final completedToday = todayItems.where((item) => item.isCompleted).length;
  final totalToday = todayItems.length;
  final upcomingToday = todayItems.where((item) {
    return item.startTime.isAfter(now) && !item.isCompleted;
  }).length;

  return {
    'totalToday': totalToday,
    'completedToday': completedToday,
    'upcomingToday': upcomingToday,
    'completionRate': totalToday > 0
        ? (completedToday / totalToday) * 100
        : 0.0,
  };
});
