import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_action_presentation.dart';

/// Builds button-ready copy for reservation QR scan actions.
class RestaurantReservationQrScanActionPresenter {
  const RestaurantReservationQrScanActionPresenter();

  RestaurantReservationQrScanActionPresentation build(
    RestaurantReservationQrScanAction action,
  ) {
    return RestaurantReservationQrScanActionPresentation(
      label: action.label,
      detail: _detailFor(action),
    );
  }

  String _detailFor(RestaurantReservationQrScanAction action) {
    return switch (action) {
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
}
