import 'restaurant_reservation_status_action.dart';

/// Separates reservation status actions into primary and secondary choices.
class RestaurantReservationStatusActionPlan {
  const RestaurantReservationStatusActionPlan({
    required this.primaryAction,
    required this.secondaryActions,
  });

  factory RestaurantReservationStatusActionPlan.fromActions(
    List<RestaurantReservationStatusAction> actions,
  ) {
    RestaurantReservationStatusAction? primaryAction;
    final secondaryActions = <RestaurantReservationStatusAction>[];

    for (final action in actions) {
      if (!action.isCautionary && primaryAction == null) {
        primaryAction = action;
      } else {
        secondaryActions.add(action);
      }
    }

    return RestaurantReservationStatusActionPlan(
      primaryAction: primaryAction,
      secondaryActions: secondaryActions,
    );
  }

  final RestaurantReservationStatusAction? primaryAction;
  final List<RestaurantReservationStatusAction> secondaryActions;

  bool get hasActions => primaryAction != null || secondaryActions.isNotEmpty;

  List<RestaurantReservationStatusAction> get orderedActions {
    return [?primaryAction, ...secondaryActions];
  }
}
