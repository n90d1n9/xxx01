import 'restaurant_models.dart';

/// Selects shift tasks by completion state or attention priority.
enum RestaurantTaskFilter {
  all,
  open,
  attention,
  done;

  String get label => switch (this) {
    RestaurantTaskFilter.all => 'All',
    RestaurantTaskFilter.open => 'Open',
    RestaurantTaskFilter.attention => 'Attention',
    RestaurantTaskFilter.done => 'Done',
  };

  bool includes(RestaurantShiftTask task) {
    final complete = task.progress >= 1;

    return switch (this) {
      RestaurantTaskFilter.all => true,
      RestaurantTaskFilter.open => !complete,
      RestaurantTaskFilter.attention =>
        !complete &&
            task.status.priorityScore >=
                RestaurantServiceStatus.busy.priorityScore,
      RestaurantTaskFilter.done => complete,
    };
  }
}
