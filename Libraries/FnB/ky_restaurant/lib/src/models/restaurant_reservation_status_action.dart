import 'restaurant_models.dart';
import 'restaurant_reservation.dart';

/// Host action that moves a reservation to the next lifecycle status.
enum RestaurantReservationStatusAction {
  confirm,
  cancel,
  markArrived,
  markNoShow,
  seat,
  complete;

  String get label => switch (this) {
    RestaurantReservationStatusAction.confirm => 'Confirm',
    RestaurantReservationStatusAction.cancel => 'Cancel',
    RestaurantReservationStatusAction.markArrived => 'Arrived',
    RestaurantReservationStatusAction.markNoShow => 'No-show',
    RestaurantReservationStatusAction.seat => 'Seat',
    RestaurantReservationStatusAction.complete => 'Complete',
  };

  RestaurantReservationStatus get targetStatus => switch (this) {
    RestaurantReservationStatusAction.confirm =>
      RestaurantReservationStatus.confirmed,
    RestaurantReservationStatusAction.cancel =>
      RestaurantReservationStatus.cancelled,
    RestaurantReservationStatusAction.markArrived =>
      RestaurantReservationStatus.arrived,
    RestaurantReservationStatusAction.markNoShow =>
      RestaurantReservationStatus.noShow,
    RestaurantReservationStatusAction.seat =>
      RestaurantReservationStatus.seated,
    RestaurantReservationStatusAction.complete =>
      RestaurantReservationStatus.completed,
  };

  bool get isCautionary => switch (this) {
    RestaurantReservationStatusAction.cancel ||
    RestaurantReservationStatusAction.markNoShow => true,
    RestaurantReservationStatusAction.confirm ||
    RestaurantReservationStatusAction.markArrived ||
    RestaurantReservationStatusAction.seat ||
    RestaurantReservationStatusAction.complete => false,
  };

  static List<RestaurantReservationStatusAction> nextFor(
    RestaurantReservationStatus status,
  ) {
    return switch (status) {
      RestaurantReservationStatus.requested => const [
        RestaurantReservationStatusAction.confirm,
        RestaurantReservationStatusAction.cancel,
      ],
      RestaurantReservationStatus.confirmed ||
      RestaurantReservationStatus.late => const [
        RestaurantReservationStatusAction.markArrived,
        RestaurantReservationStatusAction.markNoShow,
      ],
      RestaurantReservationStatus.arrived => const [
        RestaurantReservationStatusAction.seat,
        RestaurantReservationStatusAction.cancel,
      ],
      RestaurantReservationStatus.seated => const [
        RestaurantReservationStatusAction.complete,
      ],
      RestaurantReservationStatus.completed ||
      RestaurantReservationStatus.cancelled ||
      RestaurantReservationStatus.noShow => const [],
    };
  }
}

extension RestaurantReservationStatusPresentation
    on RestaurantReservationStatus {
  List<RestaurantReservationStatusAction> get nextActions {
    return RestaurantReservationStatusAction.nextFor(this);
  }

  RestaurantServiceStatus get serviceStatus => switch (this) {
    RestaurantReservationStatus.requested => RestaurantServiceStatus.busy,
    RestaurantReservationStatus.confirmed => RestaurantServiceStatus.calm,
    RestaurantReservationStatus.arrived => RestaurantServiceStatus.busy,
    RestaurantReservationStatus.seated => RestaurantServiceStatus.calm,
    RestaurantReservationStatus.completed => RestaurantServiceStatus.calm,
    RestaurantReservationStatus.late => RestaurantServiceStatus.critical,
    RestaurantReservationStatus.cancelled => RestaurantServiceStatus.blocked,
    RestaurantReservationStatus.noShow => RestaurantServiceStatus.critical,
  };
}
