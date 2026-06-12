import 'reservation_qr_link.dart';
import 'reservation_qr_scan_action_plan.dart';
import 'reservation_qr_scan_result.dart';
import 'reservation_qr_scan_workflow.dart';
import 'reservation_qr_session_activity.dart';

const Object _notProvided = Object();

/// Holds the active reservation QR link, scan result, and selected host action.
class RestaurantReservationQrSessionState {
  const RestaurantReservationQrSessionState({
    this.activeLink,
    this.scanWorkflow,
    this.selectedAction,
    this.activityTrail = const [],
  });

  final RestaurantReservationQrLink? activeLink;
  final RestaurantReservationQrScanWorkflow? scanWorkflow;
  final RestaurantReservationQrScanAction? selectedAction;
  final List<RestaurantReservationQrSessionActivity> activityTrail;

  RestaurantReservationQrScanResult? get scanResult => scanWorkflow?.result;

  RestaurantReservationQrScanActionPlan? get actionPlan {
    return scanWorkflow?.actionPlan;
  }

  bool get hasActiveLink => activeLink != null;

  bool get hasScanResult => scanWorkflow != null;

  bool get hasSelectedAction => selectedAction != null;

  bool get hasActivityTrail => activityTrail.isNotEmpty;

  bool get hasActionableScan => scanWorkflow?.isActionable ?? false;

  bool get isIdle =>
      activeLink == null && scanWorkflow == null && selectedAction == null;

  RestaurantReservationQrSessionState copyWith({
    Object? activeLink = _notProvided,
    Object? scanWorkflow = _notProvided,
    Object? selectedAction = _notProvided,
    Object? activityTrail = _notProvided,
  }) {
    return RestaurantReservationQrSessionState(
      activeLink: identical(activeLink, _notProvided)
          ? this.activeLink
          : activeLink as RestaurantReservationQrLink?,
      scanWorkflow: identical(scanWorkflow, _notProvided)
          ? this.scanWorkflow
          : scanWorkflow as RestaurantReservationQrScanWorkflow?,
      selectedAction: identical(selectedAction, _notProvided)
          ? this.selectedAction
          : selectedAction as RestaurantReservationQrScanAction?,
      activityTrail: identical(activityTrail, _notProvided)
          ? this.activityTrail
          : List<RestaurantReservationQrSessionActivity>.unmodifiable(
              activityTrail as Iterable<RestaurantReservationQrSessionActivity>,
            ),
    );
  }
}
