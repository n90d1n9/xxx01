import 'restaurant_reservation.dart';
import 'restaurant_reservation_status_action.dart';

/// Describes one allowed reservation lifecycle move.
class RestaurantReservationStatusTransition {
  const RestaurantReservationStatusTransition({
    required this.fromStatus,
    required this.action,
    required this.targetStatus,
  });

  final RestaurantReservationStatus fromStatus;
  final RestaurantReservationStatusAction action;
  final RestaurantReservationStatus targetStatus;
}

/// Validates reservation status moves against the shared host action workflow.
class RestaurantReservationStatusTransitionPolicy {
  const RestaurantReservationStatusTransitionPolicy();

  List<RestaurantReservationStatusAction> actionsFor(
    RestaurantReservationStatus status,
  ) {
    return RestaurantReservationStatusAction.nextFor(status);
  }

  List<RestaurantReservationStatus> targetStatusesFor(
    RestaurantReservationStatus status,
  ) {
    return [for (final action in actionsFor(status)) action.targetStatus];
  }

  RestaurantReservationStatusTransition? transitionForAction({
    required RestaurantReservationStatus fromStatus,
    required RestaurantReservationStatusAction action,
  }) {
    if (!actionsFor(fromStatus).contains(action)) return null;

    return RestaurantReservationStatusTransition(
      fromStatus: fromStatus,
      action: action,
      targetStatus: action.targetStatus,
    );
  }

  RestaurantReservationStatusTransition? transitionForStatus({
    required RestaurantReservationStatus fromStatus,
    required RestaurantReservationStatus targetStatus,
  }) {
    if (fromStatus == targetStatus) return null;

    for (final action in actionsFor(fromStatus)) {
      if (action.targetStatus == targetStatus) {
        return RestaurantReservationStatusTransition(
          fromStatus: fromStatus,
          action: action,
          targetStatus: targetStatus,
        );
      }
    }
    return null;
  }

  bool canPerformAction({
    required RestaurantReservationStatus fromStatus,
    required RestaurantReservationStatusAction action,
  }) {
    return transitionForAction(fromStatus: fromStatus, action: action) != null;
  }

  bool canTransition({
    required RestaurantReservationStatus fromStatus,
    required RestaurantReservationStatus targetStatus,
  }) {
    return transitionForStatus(
          fromStatus: fromStatus,
          targetStatus: targetStatus,
        ) !=
        null;
  }
}
