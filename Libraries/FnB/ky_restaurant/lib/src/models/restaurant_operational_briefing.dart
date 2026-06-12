import 'restaurant_models.dart';

/// Groups briefing recommendations by the restaurant operating lane they affect.
enum RestaurantBriefingCategory {
  overview,
  floor,
  reservations,
  kitchen,
  menu,
  task;

  String get label => switch (this) {
    RestaurantBriefingCategory.overview => 'Overview',
    RestaurantBriefingCategory.floor => 'Floor',
    RestaurantBriefingCategory.reservations => 'Reservations',
    RestaurantBriefingCategory.kitchen => 'Kitchen',
    RestaurantBriefingCategory.menu => 'Menu',
    RestaurantBriefingCategory.task => 'Task',
  };
}

/// Describes the type of operator action attached to a briefing item.
enum RestaurantBriefingActionKind {
  stabilizeZone,
  markReservationArrived,
  rebalanceStation,
  resolveMenuRisk,
  completeTask,
}

/// Identifies an actionable target produced by an operational briefing item.
class RestaurantBriefingAction {
  const RestaurantBriefingAction({required this.kind, required this.targetId});

  final RestaurantBriefingActionKind kind;
  final String targetId;
}

/// Describes one prioritized recommendation for the current restaurant shift.
class RestaurantBriefingItem {
  const RestaurantBriefingItem({
    required this.id,
    required this.category,
    required this.status,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.priorityLabel,
    this.reasonLabel,
    this.action,
  });

  final String id;
  final RestaurantBriefingCategory category;
  final RestaurantServiceStatus status;
  final String title;
  final String description;
  final String actionLabel;
  final String? priorityLabel;
  final String? reasonLabel;
  final RestaurantBriefingAction? action;

  RestaurantBriefingItem copyWith({
    String? priorityLabel,
    String? reasonLabel,
  }) {
    return RestaurantBriefingItem(
      id: id,
      category: category,
      status: status,
      title: title,
      description: description,
      actionLabel: actionLabel,
      priorityLabel: priorityLabel ?? this.priorityLabel,
      reasonLabel: reasonLabel ?? this.reasonLabel,
      action: action,
    );
  }
}
