import 'focused_visible_items.dart';
import 'restaurant_models.dart';
import 'restaurant_task_filter.dart';
import 'restaurant_task_summary.dart';

/// Derives filtered shift-task presentation state for the task panel.
class RestaurantTaskPanelData {
  const RestaurantTaskPanelData._({
    required this.tasks,
    required this.selectedFilter,
    required this.visibleTasks,
    required this.summary,
  });

  factory RestaurantTaskPanelData.fromTasks({
    required Iterable<RestaurantShiftTask> tasks,
    required RestaurantTaskFilter selectedFilter,
    String? focusedTaskId,
  }) {
    final items = tasks.toList(growable: false);
    final filteredTasks = items
        .where(selectedFilter.includes)
        .toList(growable: false);
    final visibleTasks = restaurantVisibleItemsWithFocus(
      visibleItems: filteredTasks,
      sourceItems: items,
      focusedId: focusedTaskId,
      idOf: (task) => task.id,
    );

    return RestaurantTaskPanelData._(
      tasks: items,
      selectedFilter: selectedFilter,
      visibleTasks: visibleTasks,
      summary: RestaurantTaskSummary.fromTasks(items),
    );
  }

  final List<RestaurantShiftTask> tasks;
  final RestaurantTaskFilter selectedFilter;
  final List<RestaurantShiftTask> visibleTasks;
  final RestaurantTaskSummary summary;

  bool get hasTasks => tasks.isNotEmpty;

  bool get hasVisibleTasks => visibleTasks.isNotEmpty;
}
