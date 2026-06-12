import 'restaurant_activity_filter.dart';
import 'restaurant_operation_activity.dart';

/// Derives filtered and capped operating-activity presentation state.
class RestaurantActivityPanelData {
  const RestaurantActivityPanelData._({
    required this.activities,
    required this.selectedFilter,
    required this.visibleActivities,
    required this.visibleCount,
  });

  factory RestaurantActivityPanelData.fromActivities({
    required Iterable<RestaurantOperationActivity> activities,
    required RestaurantActivityFilter selectedFilter,
    required int visibleCount,
  }) {
    final items = activities.toList(growable: false);
    final activityLimit = visibleCount < 0 ? 0 : visibleCount;
    final visibleActivities = items
        .where(selectedFilter.includes)
        .take(activityLimit)
        .toList(growable: false);

    return RestaurantActivityPanelData._(
      activities: items,
      selectedFilter: selectedFilter,
      visibleActivities: visibleActivities,
      visibleCount: activityLimit,
    );
  }

  final List<RestaurantOperationActivity> activities;
  final RestaurantActivityFilter selectedFilter;
  final List<RestaurantOperationActivity> visibleActivities;
  final int visibleCount;

  int get totalCount => activities.length;

  int get shownCount => visibleActivities.length;

  bool get hasActivities => activities.isNotEmpty;

  bool get hasVisibleActivities => visibleActivities.isNotEmpty;
}
