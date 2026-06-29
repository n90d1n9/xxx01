import 'package:flutter_riverpod/legacy.dart';

import '../models/timeline_view.dart';
import '../models/user_profile.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
      (ref) => UserProfileNotifier(),
    );

// User Profile State
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
    : super(UserProfile(userId: 'user_1', joinDate: DateTime.now()));

  void toggleFavorite(String eventId) {
    final favs = Set<String>.from(state.favoriteEventIds);
    favs.contains(eventId) ? favs.remove(eventId) : favs.add(eventId);
    state = state.copyWith(favoriteEventIds: favs);
  }

  void toggleBookmark(String eventId) {
    final bookmarks = Set<String>.from(state.bookmarkedEventIds);
    bookmarks.contains(eventId)
        ? bookmarks.remove(eventId)
        : bookmarks.add(eventId);
    state = state.copyWith(bookmarkedEventIds: bookmarks);
  }

  void addRecentlyViewed(String eventId) {
    final recent = List<String>.from(state.recentlyViewed);
    recent.remove(eventId);
    recent.insert(0, eventId);
    if (recent.length > 20) recent.removeLast();
    state = state.copyWith(recentlyViewed: recent);
  }

  void incrementCategoryView(EventCategory category) {
    final views = Map<EventCategory, int>.from(state.categoryViews);
    views[category] = (views[category] ?? 0) + 1;
    state = state.copyWith(categoryViews: views);
  }

  void addPoints(int points) {
    state = state.copyWith(totalPoints: state.totalPoints + points);
  }

  void unlockAchievement(String achievementId) {
    if (!state.achievements.contains(achievementId)) {
      final achievements = List<String>.from(state.achievements);
      achievements.add(achievementId);
      state = state.copyWith(achievements: achievements);
    }
  }

  void updateStreak() {
    final now = DateTime.now();
    final lastVisit = state.lastVisit;

    if (lastVisit == null) {
      state = state.copyWith(streakDays: 1, lastVisit: now);
    } else {
      final difference = now.difference(lastVisit).inDays;
      if (difference == 1) {
        state = state.copyWith(
          streakDays: state.streakDays + 1,
          lastVisit: now,
        );
      } else if (difference > 1) {
        state = state.copyWith(streakDays: 1, lastVisit: now);
      } else {
        state = state.copyWith(lastVisit: now);
      }
    }
  }
}
