import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_view.dart';
import 'events_provider.dart';
import 'filtered_event_provider.dart';

final statisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final events = ref.watch(filteredEventsProvider);

  final categoryCount = <EventCategory, int>{};
  var totalPopularity = 0;
  var totalImpact = 0;
  DateTime? earliest;
  DateTime? latest;

  for (final event in events) {
    totalPopularity += event.popularity;
    totalImpact += event.impactScore;

    for (final cat in event.categories) {
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
    }

    if (earliest == null || event.date.isBefore(earliest))
      earliest = event.date;
    if (latest == null || event.date.isAfter(latest)) latest = event.date;
  }

  return {
    'count': events.length,
    'avgPopularity': events.isEmpty ? 0 : totalPopularity / events.length,
    'avgImpact': events.isEmpty ? 0 : totalImpact / events.length,
    'categoryCount': categoryCount,
    'earliest': earliest,
    'latest': latest,
  };
});

final allTagsProvider = Provider<List<String>>((ref) {
  final events = ref.watch(eventsProvider);
  final tags = <String>{};
  for (final event in events) {
    tags.addAll(event.tags);
  }
  return tags.toList()..sort();
});
