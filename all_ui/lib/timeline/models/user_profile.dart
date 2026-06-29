import 'timeline_view.dart';

class UserProfile {
  final String userId;
  final Set<String> favoriteEventIds;
  final Set<String> bookmarkedEventIds;
  final List<String> recentlyViewed;
  final Map<EventCategory, int> categoryViews;
  final int totalPoints;
  final List<String> achievements;
  final DateTime joinDate;
  final int streakDays;
  final DateTime? lastVisit;

  UserProfile({
    required this.userId,
    this.favoriteEventIds = const {},
    this.bookmarkedEventIds = const {},
    this.recentlyViewed = const [],
    this.categoryViews = const {},
    this.totalPoints = 0,
    this.achievements = const [],
    required this.joinDate,
    this.streakDays = 0,
    this.lastVisit,
  });

  UserProfile copyWith({
    Set<String>? favoriteEventIds,
    Set<String>? bookmarkedEventIds,
    List<String>? recentlyViewed,
    Map<EventCategory, int>? categoryViews,
    int? totalPoints,
    List<String>? achievements,
    int? streakDays,
    DateTime? lastVisit,
  }) {
    return UserProfile(
      userId: userId,
      favoriteEventIds: favoriteEventIds ?? this.favoriteEventIds,
      bookmarkedEventIds: bookmarkedEventIds ?? this.bookmarkedEventIds,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      categoryViews: categoryViews ?? this.categoryViews,
      totalPoints: totalPoints ?? this.totalPoints,
      achievements: achievements ?? this.achievements,
      joinDate: joinDate,
      streakDays: streakDays ?? this.streakDays,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}
