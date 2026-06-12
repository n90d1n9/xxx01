import 'package:flutter/foundation.dart';

import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_link.dart';
import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_workflow.dart';
import '../models/reservation_qr_session_activity.dart';
import '../models/reservation_qr_session_state.dart';
import '../services/reservation_qr_action_handler.dart';
import '../services/reservation_qr_workflow.dart';

/// Owns the interactive state for generating and scanning reservation QR links.
class RestaurantReservationQrSessionController extends ChangeNotifier {
  RestaurantReservationQrSessionController({
    RestaurantReservationQrWorkflow? workflow,
    DateTime Function()? clock,
    this.activityLimit = 6,
    RestaurantReservationQrSessionState initialState =
        const RestaurantReservationQrSessionState(),
  }) : assert(activityLimit > 0, 'activityLimit must be greater than zero.'),
       workflow = workflow ?? RestaurantReservationQrWorkflow(),
       _clock = clock ?? DateTime.now,
       _state = _trimInitialActivityTrail(initialState, activityLimit);

  final RestaurantReservationQrWorkflow workflow;
  final int activityLimit;
  final DateTime Function() _clock;

  RestaurantReservationQrSessionState _state;

  RestaurantReservationQrSessionState get state => _state;

  RestaurantReservationQrLink? get activeLink => _state.activeLink;

  RestaurantReservationQrScanWorkflow? get scanWorkflow => _state.scanWorkflow;

  RestaurantReservationQrScanAction? get selectedAction {
    return _state.selectedAction;
  }

  List<RestaurantReservationQrSessionActivity> get activityTrail {
    return _state.activityTrail;
  }

  RestaurantReservationQrLink generateLink({
    required RestaurantReservationIntakeAction action,
    required Uri baseUri,
    Duration? lifetime,
    String? reservationId,
    String? zoneLabel,
    String? tableLabel,
    Map<String, String> queryParameters = const {},
  }) {
    final link = workflow.composeLink(
      action: action,
      baseUri: baseUri,
      lifetime: lifetime,
      reservationId: reservationId,
      zoneLabel: zoneLabel,
      tableLabel: tableLabel,
      queryParameters: queryParameters,
    );

    _setState(
      _state.copyWith(
        activeLink: link,
        scanWorkflow: null,
        selectedAction: null,
        activityTrail: _activityTrailWith(
          RestaurantReservationQrSessionActivity.linkGenerated(
            link: link,
            occurredAt: _clock(),
          ),
        ),
      ),
    );
    return link;
  }

  RestaurantReservationQrLink? refreshLink({
    required Uri baseUri,
    Duration? lifetime,
    Map<String, String> queryParameters = const {},
  }) {
    final activeLink = _state.activeLink;
    if (activeLink == null) return null;

    final payload = activeLink.payload;
    final originalLifetime = payload.expiresAt.difference(activeLink.createdAt);
    final link = workflow.composeLink(
      action: activeLink.action,
      baseUri: baseUri,
      lifetime:
          lifetime ??
          (originalLifetime > Duration.zero ? originalLifetime : null),
      reservationId: payload.reservationId,
      zoneLabel: payload.zoneLabel,
      tableLabel: payload.tableLabel,
      queryParameters: queryParameters,
    );

    _setState(
      _state.copyWith(
        activeLink: link,
        scanWorkflow: null,
        selectedAction: null,
        activityTrail: _activityTrailWith(
          RestaurantReservationQrSessionActivity.linkRefreshed(
            link: link,
            occurredAt: _clock(),
          ),
        ),
      ),
    );
    return link;
  }

  RestaurantReservationQrScanWorkflow scanUri(
    Uri uri, {
    bool includeDismiss = true,
  }) {
    return _setScanWorkflow(
      workflow.resolveUri(uri, includeDismiss: includeDismiss),
    );
  }

  RestaurantReservationQrScanWorkflow scanValue(
    String value, {
    bool includeDismiss = true,
  }) {
    return _setScanWorkflow(
      workflow.resolveValue(value, includeDismiss: includeDismiss),
    );
  }

  /// Selects an available scan action and returns whether callbacks can run.
  ///
  /// Re-selecting the current action is still accepted so hosts can retry
  /// idempotent QR workflows without forcing a scan reset.
  bool selectScanAction(RestaurantReservationQrScanAction action) {
    final actions = _state.actionPlan?.actions ?? const [];
    if (!actions.contains(action)) {
      return false;
    }

    final repeated = _state.selectedAction == action;
    final activity = RestaurantReservationQrSessionActivity.actionSelected(
      action: action,
      occurredAt: _clock(),
      repeated: repeated,
    );
    if (repeated) {
      _setState(_state.copyWith(activityTrail: _activityTrailWith(activity)));
      return true;
    }

    _setState(
      _state.copyWith(
        selectedAction: action,
        activityTrail: _activityTrailWith(activity),
      ),
    );
    return true;
  }

  bool clearLink() {
    if (_state.activeLink == null) return false;

    _setState(
      _state.copyWith(
        activeLink: null,
        activityTrail: _activityTrailWith(
          RestaurantReservationQrSessionActivity.linkCleared(
            occurredAt: _clock(),
          ),
        ),
      ),
    );
    return true;
  }

  bool clearScan() {
    if (_state.scanWorkflow == null && _state.selectedAction == null) {
      return false;
    }

    _setState(
      _state.copyWith(
        scanWorkflow: null,
        selectedAction: null,
        activityTrail: _activityTrailWith(
          RestaurantReservationQrSessionActivity.scanCleared(
            occurredAt: _clock(),
          ),
        ),
      ),
    );
    return true;
  }

  bool reset() {
    if (_state.isIdle) return false;

    _setState(
      const RestaurantReservationQrSessionState().copyWith(
        activityTrail: _activityTrailWith(
          RestaurantReservationQrSessionActivity.sessionReset(
            occurredAt: _clock(),
          ),
        ),
      ),
    );
    return true;
  }

  void recordActionHandled(RestaurantReservationQrActionHandlingResult result) {
    _setState(
      _state.copyWith(
        activityTrail: _activityTrailWith(_activityForHandledResult(result)),
      ),
    );
  }

  RestaurantReservationQrScanWorkflow _setScanWorkflow(
    RestaurantReservationQrScanWorkflow scanWorkflow,
  ) {
    _setState(
      _state.copyWith(
        scanWorkflow: scanWorkflow,
        selectedAction: null,
        activityTrail: _activityTrailWith(
          RestaurantReservationQrSessionActivity.scanResolved(
            workflow: scanWorkflow,
          ),
        ),
      ),
    );
    return scanWorkflow;
  }

  List<RestaurantReservationQrSessionActivity> _activityTrailWith(
    RestaurantReservationQrSessionActivity activity,
  ) {
    return [
      activity,
      ..._state.activityTrail,
    ].take(activityLimit).toList(growable: false);
  }

  void _setState(RestaurantReservationQrSessionState state) {
    _state = state;
    notifyListeners();
  }

  RestaurantReservationQrSessionActivity _activityForHandledResult(
    RestaurantReservationQrActionHandlingResult result,
  ) {
    final action = result.action;
    final actionLabel = action?.label ?? 'QR action';

    return RestaurantReservationQrSessionActivity.actionHandled(
      action: action,
      label: switch (result.status) {
        RestaurantReservationQrActionHandlingStatus.pending =>
          '$actionLabel in progress',
        RestaurantReservationQrActionHandlingStatus.handled =>
          '$actionLabel completed',
        RestaurantReservationQrActionHandlingStatus.failed =>
          '$actionLabel failed',
        RestaurantReservationQrActionHandlingStatus.unavailable =>
          '$actionLabel needs setup',
        RestaurantReservationQrActionHandlingStatus.notAllowed =>
          '$actionLabel unavailable',
        RestaurantReservationQrActionHandlingStatus.missingReservationId =>
          '$actionLabel missing reservation id',
      },
      detail: _activityDetailForHandledResult(result),
      occurredAt: _clock(),
      tone: switch (result.status) {
        RestaurantReservationQrActionHandlingStatus.pending =>
          RestaurantReservationQrSessionActivityTone.neutral,
        RestaurantReservationQrActionHandlingStatus.handled =>
          RestaurantReservationQrSessionActivityTone.success,
        RestaurantReservationQrActionHandlingStatus.failed =>
          RestaurantReservationQrSessionActivityTone.critical,
        RestaurantReservationQrActionHandlingStatus.unavailable =>
          RestaurantReservationQrSessionActivityTone.warning,
        RestaurantReservationQrActionHandlingStatus.notAllowed ||
        RestaurantReservationQrActionHandlingStatus.missingReservationId =>
          RestaurantReservationQrSessionActivityTone.critical,
      },
    );
  }
}

String? _activityDetailForHandledResult(
  RestaurantReservationQrActionHandlingResult result,
) {
  return switch (result.status) {
    RestaurantReservationQrActionHandlingStatus.pending => result.detail,
    RestaurantReservationQrActionHandlingStatus.handled => result.detail,
    RestaurantReservationQrActionHandlingStatus.failed => result.detail,
    RestaurantReservationQrActionHandlingStatus.unavailable =>
      'Workflow setup is required before this can run.',
    RestaurantReservationQrActionHandlingStatus.notAllowed =>
      'The scan does not allow this action.',
    RestaurantReservationQrActionHandlingStatus.missingReservationId =>
      'The scan needs a reservation id.',
  };
}

RestaurantReservationQrSessionState _trimInitialActivityTrail(
  RestaurantReservationQrSessionState state,
  int activityLimit,
) {
  if (state.activityTrail.length <= activityLimit) return state;

  return state.copyWith(
    activityTrail: state.activityTrail
        .take(activityLimit)
        .toList(growable: false),
  );
}
