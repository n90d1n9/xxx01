import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/historical_event.dart';
import '../models/timeline_view.dart';
import 'events_provider.dart';
import 'timeline_provider.dart';
import 'user_profile_provider.dart';

final filteredEventsProvider = Provider<List<HistoricalEvent>>((ref) {
  final events = ref.watch(eventsProvider);
  final state = ref.watch(timelineProvider);
  final userProfile = ref.watch(userProfileProvider);

  var filtered =
      events.where((event) {
        if (state.showFavorites &&
            !userProfile.favoriteEventIds.contains(event.id))
          return false;
        if (state.showOnlyBookmarks &&
            !userProfile.bookmarkedEventIds.contains(event.id))
          return false;

        if (state.selectedCategories.isNotEmpty) {
          if (!event.categories.any(
            (cat) => state.selectedCategories.contains(cat),
          ))
            return false;
        }

        if (state.startDate != null && event.date.isBefore(state.startDate!))
          return false;
        if (state.endDate != null && event.date.isAfter(state.endDate!))
          return false;

        if (state.minImpactScore != null &&
            event.impactScore < state.minImpactScore!)
          return false;

        if (state.selectedTags.isNotEmpty) {
          if (!event.tags.any((tag) => state.selectedTags.contains(tag)))
            return false;
        }

        if (state.searchQuery.isNotEmpty) {
          final query = state.searchQuery.toLowerCase();
          if (!event.title.toLowerCase().contains(query) &&
              !event.description.toLowerCase().contains(query) &&
              !event.location.toLowerCase().contains(query) &&
              !(event.quote?.toLowerCase().contains(query) ?? false) &&
              !event.tags.any((tag) => tag.toLowerCase().contains(query))) {
            return false;
          }
        }

        return true;
      }).toList();

  switch (state.sortMode) {
    case SortMode.popularity:
      filtered.sort((a, b) => b.popularity.compareTo(a.popularity));
      break;
    case SortMode.chronological:
      filtered.sort((a, b) => a.date.compareTo(b.date));
      break;
    case SortMode.reverseChronological:
      filtered.sort((a, b) => b.date.compareTo(a.date));
      break;
    case SortMode.relevance:
      filtered.sort((a, b) => b.impactScore.compareTo(a.impactScore));
      break;
  }

  return filtered;
});
