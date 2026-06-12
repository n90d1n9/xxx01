import 'reservation_qr_payload.dart';

/// Describes the next host action after a reservation QR scan is resolved.
enum RestaurantReservationQrScanAction {
  createBooking,
  joinWaitlist,
  confirmCheckIn,
  refreshLink,
  dismiss;

  String get label => switch (this) {
    RestaurantReservationQrScanAction.createBooking => 'Create booking',
    RestaurantReservationQrScanAction.joinWaitlist => 'Join waitlist',
    RestaurantReservationQrScanAction.confirmCheckIn => 'Confirm check-in',
    RestaurantReservationQrScanAction.refreshLink => 'Refresh QR link',
    RestaurantReservationQrScanAction.dismiss => 'Dismiss',
  };

  String get detailLabel => switch (this) {
    RestaurantReservationQrScanAction.createBooking =>
      'Continue the guest reservation form.',
    RestaurantReservationQrScanAction.joinWaitlist =>
      'Add the guest to the live waitlist.',
    RestaurantReservationQrScanAction.confirmCheckIn =>
      'Confirm the arriving party.',
    RestaurantReservationQrScanAction.refreshLink =>
      'Generate a fresh QR link for the guest.',
    RestaurantReservationQrScanAction.dismiss => 'Close the scan result.',
  };
}

/// Groups the primary and secondary actions available for one QR scan result.
class RestaurantReservationQrScanActionPlan {
  const RestaurantReservationQrScanActionPlan({
    required this.primaryAction,
    this.secondaryActions = const [],
  });

  final RestaurantReservationQrScanAction? primaryAction;
  final List<RestaurantReservationQrScanAction> secondaryActions;

  List<RestaurantReservationQrScanAction> get actions {
    return [?primaryAction, ...secondaryActions];
  }

  bool get hasActions => primaryAction != null || secondaryActions.isNotEmpty;
}

/// Maps reservation QR intents to the host action needed to continue service.
RestaurantReservationQrScanAction reservationQrScanActionForIntent(
  RestaurantReservationQrIntent intent,
) {
  return switch (intent) {
    RestaurantReservationQrIntent.booking =>
      RestaurantReservationQrScanAction.createBooking,
    RestaurantReservationQrIntent.waitlist =>
      RestaurantReservationQrScanAction.joinWaitlist,
    RestaurantReservationQrIntent.checkIn =>
      RestaurantReservationQrScanAction.confirmCheckIn,
  };
}
