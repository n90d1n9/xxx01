import 'restaurant_reservation.dart';
import 'restaurant_reservation_status_action.dart';

/// Provides host-facing copy for confirming a cautionary reservation action.
class RestaurantReservationStatusActionConfirmation {
  const RestaurantReservationStatusActionConfirmation({
    required this.action,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Keep reservation',
  });

  final RestaurantReservationStatusAction action;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
}

/// Builds confirmation prompts for reservation actions that can close demand.
class RestaurantReservationStatusActionConfirmationPolicy {
  const RestaurantReservationStatusActionConfirmationPolicy();

  RestaurantReservationStatusActionConfirmation? confirmationFor({
    required RestaurantReservation reservation,
    required RestaurantReservationStatusAction action,
  }) {
    if (!action.isCautionary) return null;

    return switch (action) {
      RestaurantReservationStatusAction.cancel =>
        RestaurantReservationStatusActionConfirmation(
          action: action,
          title: 'Cancel reservation?',
          message:
              'This closes ${reservation.guestName} for ${reservation.partyLabel} at ${reservation.timeLabel}.',
          confirmLabel: 'Cancel reservation',
        ),
      RestaurantReservationStatusAction.markNoShow =>
        RestaurantReservationStatusActionConfirmation(
          action: action,
          title: 'Mark no-show?',
          message:
              'This moves ${reservation.guestName} for ${reservation.partyLabel} at ${reservation.timeLabel} out of the active arrival flow.',
          confirmLabel: 'Mark no-show',
        ),
      RestaurantReservationStatusAction.confirm ||
      RestaurantReservationStatusAction.markArrived ||
      RestaurantReservationStatusAction.seat ||
      RestaurantReservationStatusAction.complete => null,
    };
  }
}
