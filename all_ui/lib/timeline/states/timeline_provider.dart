import 'package:flutter_riverpod/legacy.dart';

import '../models/timeline_state.dart';
import '../models/timeline_view.dart';

final timelineProvider = StateNotifierProvider<TimelineNotifier, TimelineState>(
  (ref) => TimelineNotifier(),
);

class TimelineNotifier extends StateNotifier<TimelineState> {
  TimelineNotifier() : super(TimelineState());

  void setView(TimelineView view) => state = state.copyWith(view: view);
  void setViewMode(ViewMode mode) => state = state.copyWith(viewMode: mode);
  void setSortMode(SortMode mode) => state = state.copyWith(sortMode: mode);
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
  void setZoomLevel(double level) =>
      state = state.copyWith(zoomLevel: level.clamp(0.5, 3.0));
  void toggleTimeline() =>
      state = state.copyWith(showTimeline: !state.showTimeline);
  void toggleShowFavorites() =>
      state = state.copyWith(showFavorites: !state.showFavorites);
  void toggleShowBookmarks() =>
      state = state.copyWith(showOnlyBookmarks: !state.showOnlyBookmarks);
  void toggleComparisonMode() =>
      state = state.copyWith(comparisonMode: !state.comparisonMode);
  void toggleAnimatedTimeline() =>
      state = state.copyWith(animatedTimeline: !state.animatedTimeline);
  void setTimelineSpeed(double speed) =>
      state = state.copyWith(timelineSpeed: speed);

  void toggleCategory(EventCategory category) {
    final cats = Set<EventCategory>.from(state.selectedCategories);
    cats.contains(category) ? cats.remove(category) : cats.add(category);
    state = state.copyWith(selectedCategories: cats);
  }

  void clearCategories() => state = state.copyWith(selectedCategories: {});
  void setDateRange(DateTime? start, DateTime? end) =>
      state = state.copyWith(startDate: start, endDate: end);
  void clearDateRange() => state = state.copyWith(clearDates: true);
  void setMinImpactScore(int? score) =>
      state = state.copyWith(minImpactScore: score);
  void clearMinImpactScore() => state = state.copyWith(clearMinImpact: true);

  void toggleEventExpansion(String eventId) {
    state = state.copyWith(
      expandedEventId: state.expandedEventId == eventId ? null : eventId,
      clearExpanded: state.expandedEventId == eventId,
    );
  }

  void toggleTag(String tag) {
    final tags = List<String>.from(state.selectedTags);
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    state = state.copyWith(selectedTags: tags);
  }

  void toggleComparisonEvent(String eventId) {
    final events = List<String>.from(state.comparisonEventIds);
    if (events.contains(eventId)) {
      events.remove(eventId);
    } else if (events.length < 3) {
      events.add(eventId);
    }
    state = state.copyWith(comparisonEventIds: events);
  }
}
