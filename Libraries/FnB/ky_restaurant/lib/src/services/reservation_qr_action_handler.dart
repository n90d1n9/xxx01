import 'dart:async';

import '../models/reservation_qr_payload.dart';
import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_result.dart';
import '../models/reservation_qr_scan_workflow.dart';
import '../models/restaurant_reservation.dart';

/// Handles a host action selected from a resolved reservation QR scan.
typedef RestaurantReservationQrActionCallback =
    FutureOr<void> Function(RestaurantReservationQrActionContext context);

/// Updates a reservation status as the result of a QR scan action.
typedef RestaurantReservationQrStatusUpdateCallback =
    FutureOr<void> Function(
      String reservationId,
      RestaurantReservationStatus status,
    );

/// Describes the outcome of routing a QR scan action to host workflow code.
enum RestaurantReservationQrActionHandlingStatus {
  pending,
  handled,
  failed,
  unavailable,
  notAllowed,
  missingReservationId,
}

/// Carries the scan workflow and selected action into host workflow callbacks.
class RestaurantReservationQrActionContext {
  const RestaurantReservationQrActionContext({
    required this.workflow,
    required this.action,
  });

  final RestaurantReservationQrScanWorkflow workflow;
  final RestaurantReservationQrScanAction action;

  RestaurantReservationQrScanResult get result => workflow.result;

  RestaurantReservationQrPayload? get payload => result.payload;

  RestaurantReservationQrIntent? get intent => payload?.intent;

  String? get reservationId => payload?.reservationId;
}

/// Reports whether a selected QR action was handled or why it was skipped.
class RestaurantReservationQrActionHandlingResult {
  const RestaurantReservationQrActionHandlingResult({
    required this.status,
    this.action,
    this.detail,
  });

  factory RestaurantReservationQrActionHandlingResult.handled(
    RestaurantReservationQrScanAction action,
  ) {
    return RestaurantReservationQrActionHandlingResult(
      status: RestaurantReservationQrActionHandlingStatus.handled,
      action: action,
    );
  }

  factory RestaurantReservationQrActionHandlingResult.unavailable(
    RestaurantReservationQrScanAction? action,
  ) {
    return RestaurantReservationQrActionHandlingResult(
      status: RestaurantReservationQrActionHandlingStatus.unavailable,
      action: action,
      detail: 'No handler is configured for this QR action.',
    );
  }

  factory RestaurantReservationQrActionHandlingResult.notAllowed(
    RestaurantReservationQrScanAction action,
  ) {
    return RestaurantReservationQrActionHandlingResult(
      status: RestaurantReservationQrActionHandlingStatus.notAllowed,
      action: action,
      detail: 'This QR action is not available for the current scan.',
    );
  }

  factory RestaurantReservationQrActionHandlingResult.missingReservationId(
    RestaurantReservationQrScanAction action,
  ) {
    return RestaurantReservationQrActionHandlingResult(
      status: RestaurantReservationQrActionHandlingStatus.missingReservationId,
      action: action,
      detail: 'A reservation id is required to confirm QR check-in.',
    );
  }

  final RestaurantReservationQrActionHandlingStatus status;
  final RestaurantReservationQrScanAction? action;
  final String? detail;

  factory RestaurantReservationQrActionHandlingResult.pending(
    RestaurantReservationQrScanAction action,
  ) {
    return RestaurantReservationQrActionHandlingResult(
      status: RestaurantReservationQrActionHandlingStatus.pending,
      action: action,
      detail: 'Keep this scan open while the workflow finishes.',
    );
  }

  bool get isHandled {
    return status == RestaurantReservationQrActionHandlingStatus.handled;
  }

  factory RestaurantReservationQrActionHandlingResult.failed(
    RestaurantReservationQrScanAction action, {
    String? detail,
  }) {
    return RestaurantReservationQrActionHandlingResult(
      status: RestaurantReservationQrActionHandlingStatus.failed,
      action: action,
      detail: detail ?? 'The QR action could not finish. Try again.',
    );
  }
}

/// Routes reservation QR scan actions into application-level workflow callbacks.
class RestaurantReservationQrActionHandler {
  const RestaurantReservationQrActionHandler({
    this.onCreateBooking,
    this.onJoinWaitlist,
    this.onConfirmCheckIn,
    this.onRefreshLink,
    this.onDismiss,
    this.onReservationStatusChanged,
  });

  static const empty = RestaurantReservationQrActionHandler();

  final RestaurantReservationQrActionCallback? onCreateBooking;
  final RestaurantReservationQrActionCallback? onJoinWaitlist;
  final RestaurantReservationQrActionCallback? onConfirmCheckIn;
  final RestaurantReservationQrActionCallback? onRefreshLink;
  final RestaurantReservationQrActionCallback? onDismiss;

  /// Used by the default check-in handler to mark a reservation as arrived.
  final RestaurantReservationQrStatusUpdateCallback? onReservationStatusChanged;

  /// Returns a handler that keeps local callbacks and fills gaps from [fallback].
  RestaurantReservationQrActionHandler withFallbacks(
    RestaurantReservationQrActionHandler fallback,
  ) {
    return RestaurantReservationQrActionHandler(
      onCreateBooking: onCreateBooking ?? fallback.onCreateBooking,
      onJoinWaitlist: onJoinWaitlist ?? fallback.onJoinWaitlist,
      onConfirmCheckIn: onConfirmCheckIn ?? fallback.onConfirmCheckIn,
      onRefreshLink: onRefreshLink ?? fallback.onRefreshLink,
      onDismiss: onDismiss ?? fallback.onDismiss,
      onReservationStatusChanged:
          onReservationStatusChanged ?? fallback.onReservationStatusChanged,
    );
  }

  RestaurantReservationQrActionHandlingResult handlePrimary(
    RestaurantReservationQrScanWorkflow workflow,
  ) {
    final action = workflow.primaryAction;
    if (action == null) {
      return RestaurantReservationQrActionHandlingResult.unavailable(null);
    }

    return handle(workflow: workflow, action: action);
  }

  Future<RestaurantReservationQrActionHandlingResult> handlePrimaryAsync(
    RestaurantReservationQrScanWorkflow workflow,
  ) {
    final action = workflow.primaryAction;
    if (action == null) {
      return Future.value(
        RestaurantReservationQrActionHandlingResult.unavailable(null),
      );
    }

    return handleAsync(workflow: workflow, action: action);
  }

  RestaurantReservationQrActionHandlingResult handle({
    required RestaurantReservationQrScanWorkflow workflow,
    required RestaurantReservationQrScanAction action,
  }) {
    if (!workflow.actionPlan.actions.contains(action)) {
      return RestaurantReservationQrActionHandlingResult.notAllowed(action);
    }

    final context = RestaurantReservationQrActionContext(
      workflow: workflow,
      action: action,
    );

    return switch (action) {
      RestaurantReservationQrScanAction.createBooking => _run(
        action,
        context,
        onCreateBooking,
      ),
      RestaurantReservationQrScanAction.joinWaitlist => _run(
        action,
        context,
        onJoinWaitlist,
      ),
      RestaurantReservationQrScanAction.confirmCheckIn => _confirmCheckIn(
        context,
      ),
      RestaurantReservationQrScanAction.refreshLink => _run(
        action,
        context,
        onRefreshLink,
      ),
      RestaurantReservationQrScanAction.dismiss => _run(
        action,
        context,
        onDismiss,
      ),
    };
  }

  Future<RestaurantReservationQrActionHandlingResult> handleAsync({
    required RestaurantReservationQrScanWorkflow workflow,
    required RestaurantReservationQrScanAction action,
  }) async {
    if (!workflow.actionPlan.actions.contains(action)) {
      return RestaurantReservationQrActionHandlingResult.notAllowed(action);
    }

    final context = RestaurantReservationQrActionContext(
      workflow: workflow,
      action: action,
    );

    try {
      return switch (action) {
        RestaurantReservationQrScanAction.createBooking => await _runAsync(
          action,
          context,
          onCreateBooking,
        ),
        RestaurantReservationQrScanAction.joinWaitlist => await _runAsync(
          action,
          context,
          onJoinWaitlist,
        ),
        RestaurantReservationQrScanAction.confirmCheckIn =>
          await _confirmCheckInAsync(context),
        RestaurantReservationQrScanAction.refreshLink => await _runAsync(
          action,
          context,
          onRefreshLink,
        ),
        RestaurantReservationQrScanAction.dismiss => await _runAsync(
          action,
          context,
          onDismiss,
        ),
      };
    } catch (_) {
      return RestaurantReservationQrActionHandlingResult.failed(action);
    }
  }

  RestaurantReservationQrActionHandlingResult _confirmCheckIn(
    RestaurantReservationQrActionContext context,
  ) {
    final customHandler = onConfirmCheckIn;
    if (customHandler != null) {
      customHandler(context);
      return RestaurantReservationQrActionHandlingResult.handled(
        context.action,
      );
    }

    final statusHandler = onReservationStatusChanged;
    if (statusHandler == null) {
      return RestaurantReservationQrActionHandlingResult.unavailable(
        context.action,
      );
    }

    final reservationId = context.reservationId;
    if (reservationId == null) {
      return RestaurantReservationQrActionHandlingResult.missingReservationId(
        context.action,
      );
    }

    statusHandler(reservationId, RestaurantReservationStatus.arrived);
    return RestaurantReservationQrActionHandlingResult.handled(context.action);
  }

  Future<RestaurantReservationQrActionHandlingResult> _confirmCheckInAsync(
    RestaurantReservationQrActionContext context,
  ) async {
    final customHandler = onConfirmCheckIn;
    if (customHandler != null) {
      await customHandler(context);
      return RestaurantReservationQrActionHandlingResult.handled(
        context.action,
      );
    }

    final statusHandler = onReservationStatusChanged;
    if (statusHandler == null) {
      return RestaurantReservationQrActionHandlingResult.unavailable(
        context.action,
      );
    }

    final reservationId = context.reservationId;
    if (reservationId == null) {
      return RestaurantReservationQrActionHandlingResult.missingReservationId(
        context.action,
      );
    }

    await statusHandler(reservationId, RestaurantReservationStatus.arrived);
    return RestaurantReservationQrActionHandlingResult.handled(context.action);
  }

  RestaurantReservationQrActionHandlingResult _run(
    RestaurantReservationQrScanAction action,
    RestaurantReservationQrActionContext context,
    RestaurantReservationQrActionCallback? callback,
  ) {
    if (callback == null) {
      return RestaurantReservationQrActionHandlingResult.unavailable(action);
    }

    callback(context);
    return RestaurantReservationQrActionHandlingResult.handled(action);
  }

  Future<RestaurantReservationQrActionHandlingResult> _runAsync(
    RestaurantReservationQrScanAction action,
    RestaurantReservationQrActionContext context,
    RestaurantReservationQrActionCallback? callback,
  ) async {
    if (callback == null) {
      return RestaurantReservationQrActionHandlingResult.unavailable(action);
    }

    await callback(context);
    return RestaurantReservationQrActionHandlingResult.handled(action);
  }
}
