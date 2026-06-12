import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_link.dart';
import '../models/reservation_qr_scan_result.dart';
import '../models/reservation_qr_scan_workflow.dart';
import 'reservation_qr_link_composer.dart';
import 'reservation_qr_scan_action_planner.dart';
import 'reservation_qr_scan_resolver.dart';

/// Coordinates reservation QR link creation, scan resolution, and host actions.
class RestaurantReservationQrWorkflow {
  RestaurantReservationQrWorkflow({
    RestaurantReservationQrLinkComposer? linkComposer,
    RestaurantReservationQrScanResolver? scanResolver,
    RestaurantReservationQrScanActionPlanner? actionPlanner,
  }) : linkComposer = linkComposer ?? RestaurantReservationQrLinkComposer(),
       scanResolver = scanResolver ?? RestaurantReservationQrScanResolver(),
       actionPlanner =
           actionPlanner ?? const RestaurantReservationQrScanActionPlanner();

  final RestaurantReservationQrLinkComposer linkComposer;
  final RestaurantReservationQrScanResolver scanResolver;
  final RestaurantReservationQrScanActionPlanner actionPlanner;

  RestaurantReservationQrLink composeLink({
    required RestaurantReservationIntakeAction action,
    required Uri baseUri,
    Duration? lifetime,
    String? reservationId,
    String? zoneLabel,
    String? tableLabel,
    Map<String, String> queryParameters = const {},
  }) {
    return linkComposer.composeForAction(
      action: action,
      baseUri: baseUri,
      lifetime: lifetime,
      reservationId: reservationId,
      zoneLabel: zoneLabel,
      tableLabel: tableLabel,
      queryParameters: queryParameters,
    );
  }

  RestaurantReservationQrScanWorkflow resolveUri(
    Uri uri, {
    bool includeDismiss = true,
  }) {
    return planFor(
      scanResolver.resolveUri(uri),
      includeDismiss: includeDismiss,
    );
  }

  RestaurantReservationQrScanWorkflow resolveValue(
    String value, {
    bool includeDismiss = true,
  }) {
    return planFor(
      scanResolver.resolveValue(value),
      includeDismiss: includeDismiss,
    );
  }

  RestaurantReservationQrScanWorkflow planFor(
    RestaurantReservationQrScanResult result, {
    bool includeDismiss = true,
  }) {
    return RestaurantReservationQrScanWorkflow(
      result: result,
      actionPlan: actionPlanner.planFor(result, includeDismiss: includeDismiss),
    );
  }
}
