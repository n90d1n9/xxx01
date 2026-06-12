import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_selected_action_presentation.dart';

/// Builds host-facing copy for a selected reservation QR scan action.
class RestaurantReservationQrSelectedActionPresenter {
  const RestaurantReservationQrSelectedActionPresenter();

  RestaurantReservationQrSelectedActionPresentation build(
    RestaurantReservationQrScanAction action, {
    String titlePrefix = 'Selected action',
  }) {
    return RestaurantReservationQrSelectedActionPresentation(
      title: '$titlePrefix: ${action.label}',
      message: _messageFor(action),
    );
  }

  String _messageFor(RestaurantReservationQrScanAction action) {
    return switch (action) {
      RestaurantReservationQrScanAction.createBooking =>
        'Open the booking flow with this QR context attached.',
      RestaurantReservationQrScanAction.joinWaitlist =>
        'Add the guest to the live waitlist and keep the scan trace.',
      RestaurantReservationQrScanAction.confirmCheckIn =>
        'Confirm the arriving party and mark the reservation as present.',
      RestaurantReservationQrScanAction.refreshLink =>
        'Generate a fresh QR link before the guest scans again.',
      RestaurantReservationQrScanAction.dismiss =>
        'Close this scan result without changing the reservation.',
    };
  }
}
