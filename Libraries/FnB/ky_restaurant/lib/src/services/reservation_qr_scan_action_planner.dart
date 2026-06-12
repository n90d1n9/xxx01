import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_result.dart';

/// Builds host action plans for valid, expired, and invalid QR scan results.
class RestaurantReservationQrScanActionPlanner {
  const RestaurantReservationQrScanActionPlanner();

  RestaurantReservationQrScanActionPlan planFor(
    RestaurantReservationQrScanResult result, {
    bool includeDismiss = true,
  }) {
    final dismissActions = includeDismiss
        ? const [RestaurantReservationQrScanAction.dismiss]
        : const <RestaurantReservationQrScanAction>[];

    if (result.isExpired) {
      return RestaurantReservationQrScanActionPlan(
        primaryAction: RestaurantReservationQrScanAction.refreshLink,
        secondaryActions: dismissActions,
      );
    }
    if (result.isInvalid) {
      return RestaurantReservationQrScanActionPlan(
        primaryAction: includeDismiss
            ? RestaurantReservationQrScanAction.dismiss
            : null,
      );
    }

    final payload = result.payload;
    if (payload == null) {
      return RestaurantReservationQrScanActionPlan(
        primaryAction: includeDismiss
            ? RestaurantReservationQrScanAction.dismiss
            : null,
      );
    }

    return RestaurantReservationQrScanActionPlan(
      primaryAction: reservationQrScanActionForIntent(payload.intent),
      secondaryActions: dismissActions,
    );
  }
}
