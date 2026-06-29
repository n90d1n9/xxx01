import 'timeline_view.dart';

class TimelineState {
  final TimelineView view;
  final ViewMode viewMode;
  final Set<EventCategory> selectedCategories;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? expandedEventId;
  final SortMode sortMode;
  final bool showFavorites;
  final bool showTimeline;
  final double zoomLevel;
  final bool showOnlyBookmarks;
  final int? minImpactScore;
  final List<String> selectedTags;
  final bool comparisonMode;
  final List<String> comparisonEventIds;
  final bool animatedTimeline;
  final double timelineSpeed;

  TimelineState({
    this.view = TimelineView.century,
    this.viewMode = ViewMode.list,
    this.selectedCategories = const {},
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.expandedEventId,
    this.sortMode = SortMode.popularity,
    this.showFavorites = false,
    this.showTimeline = true,
    this.zoomLevel = 1.0,
    this.showOnlyBookmarks = false,
    this.minImpactScore,
    this.selectedTags = const [],
    this.comparisonMode = false,
    this.comparisonEventIds = const [],
    this.animatedTimeline = false,
    this.timelineSpeed = 1.0,
  });

  TimelineState copyWith({
    TimelineView? view,
    ViewMode? viewMode,
    Set<EventCategory>? selectedCategories,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? expandedEventId,
    SortMode? sortMode,
    bool? showFavorites,
    bool? showTimeline,
    double? zoomLevel,
    bool? showOnlyBookmarks,
    int? minImpactScore,
    List<String>? selectedTags,
    bool? comparisonMode,
    List<String>? comparisonEventIds,
    bool? animatedTimeline,
    double? timelineSpeed,
    bool clearExpanded = false,
    bool clearDates = false,
    bool clearMinImpact = false,
  }) {
    return TimelineState(
      view: view ?? this.view,
      viewMode: viewMode ?? this.viewMode,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      expandedEventId:
          clearExpanded ? null : (expandedEventId ?? this.expandedEventId),
      sortMode: sortMode ?? this.sortMode,
      showFavorites: showFavorites ?? this.showFavorites,
      showTimeline: showTimeline ?? this.showTimeline,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      showOnlyBookmarks: showOnlyBookmarks ?? this.showOnlyBookmarks,
      minImpactScore:
          clearMinImpact ? null : (minImpactScore ?? this.minImpactScore),
      selectedTags: selectedTags ?? this.selectedTags,
      comparisonMode: comparisonMode ?? this.comparisonMode,
      comparisonEventIds: comparisonEventIds ?? this.comparisonEventIds,
      animatedTimeline: animatedTimeline ?? this.animatedTimeline,
      timelineSpeed: timelineSpeed ?? this.timelineSpeed,
    );
  }
}
