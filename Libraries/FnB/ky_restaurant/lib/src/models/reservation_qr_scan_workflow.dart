import 'reservation_qr_scan_action_plan.dart';
import 'reservation_qr_scan_result.dart';

/// Carries a resolved reservation QR scan together with its host action plan.
class RestaurantReservationQrScanWorkflow {
  const RestaurantReservationQrScanWorkflow({
    required this.result,
    required this.actionPlan,
  });

  final RestaurantReservationQrScanResult result;
  final RestaurantReservationQrScanActionPlan actionPlan;

  bool get isActionable => actionPlan.hasActions;

  RestaurantReservationQrScanAction? get primaryAction {
    return actionPlan.primaryAction;
  }
}
