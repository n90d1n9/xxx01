import 'reservation_qr_link.dart';
import 'reservation_qr_scan_action_plan.dart';
import 'reservation_qr_scan_result.dart';
import 'reservation_qr_scan_workflow.dart';

/// Identifies the kind of event captured in a reservation QR session trail.
enum RestaurantReservationQrSessionActivityKind {
  linkGenerated,
  linkRefreshed,
  scanResolved,
  actionSelected,
  actionHandled,
  scanCleared,
  linkCleared,
  sessionReset,
}

/// Describes the visual priority of a reservation QR session activity.
enum RestaurantReservationQrSessionActivityTone {
  neutral,
  success,
  warning,
  critical,
}

/// Captures one operator-visible event from a reservation QR workflow.
class RestaurantReservationQrSessionActivity {
  const RestaurantReservationQrSessionActivity({
    required this.kind,
    required this.label,
    required this.occurredAt,
    this.detail,
    this.action,
    this.scanStatus,
    this.tone = RestaurantReservationQrSessionActivityTone.neutral,
  });

  factory RestaurantReservationQrSessionActivity.linkGenerated({
    required RestaurantReservationQrLink link,
    required DateTime occurredAt,
  }) {
    final payload = link.payload;
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.linkGenerated,
      label: '${payload.intent.label} QR generated',
      detail: _payloadContext(payload.zoneLabel, payload.tableLabel),
      occurredAt: occurredAt,
      tone: RestaurantReservationQrSessionActivityTone.success,
    );
  }

  factory RestaurantReservationQrSessionActivity.linkRefreshed({
    required RestaurantReservationQrLink link,
    required DateTime occurredAt,
  }) {
    final payload = link.payload;
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.linkRefreshed,
      label: '${payload.intent.label} QR refreshed',
      detail: _payloadContext(payload.zoneLabel, payload.tableLabel),
      occurredAt: occurredAt,
      tone: RestaurantReservationQrSessionActivityTone.success,
    );
  }

  factory RestaurantReservationQrSessionActivity.scanResolved({
    required RestaurantReservationQrScanWorkflow workflow,
  }) {
    final result = workflow.result;
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.scanResolved,
      label: result.status.label,
      detail: result.detailLabel,
      occurredAt: result.scannedAt,
      scanStatus: result.status,
      tone: _toneForScanStatus(result.status),
    );
  }

  factory RestaurantReservationQrSessionActivity.actionSelected({
    required RestaurantReservationQrScanAction action,
    required DateTime occurredAt,
    bool repeated = false,
  }) {
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.actionSelected,
      label: repeated ? '${action.label} retried' : '${action.label} selected',
      detail: action.detailLabel,
      occurredAt: occurredAt,
      action: action,
    );
  }

  factory RestaurantReservationQrSessionActivity.actionHandled({
    required RestaurantReservationQrScanAction? action,
    required String label,
    required DateTime occurredAt,
    String? detail,
    RestaurantReservationQrSessionActivityTone tone =
        RestaurantReservationQrSessionActivityTone.success,
  }) {
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.actionHandled,
      label: label,
      detail: detail,
      occurredAt: occurredAt,
      action: action,
      tone: tone,
    );
  }

  factory RestaurantReservationQrSessionActivity.scanCleared({
    required DateTime occurredAt,
  }) {
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.scanCleared,
      label: 'Scan cleared',
      detail: 'Latest QR scan was dismissed.',
      occurredAt: occurredAt,
    );
  }

  factory RestaurantReservationQrSessionActivity.linkCleared({
    required DateTime occurredAt,
  }) {
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.linkCleared,
      label: 'QR handoff cleared',
      detail: 'Active reservation QR link was removed.',
      occurredAt: occurredAt,
    );
  }

  factory RestaurantReservationQrSessionActivity.sessionReset({
    required DateTime occurredAt,
  }) {
    return RestaurantReservationQrSessionActivity(
      kind: RestaurantReservationQrSessionActivityKind.sessionReset,
      label: 'QR session reset',
      detail: 'Active QR handoff state was reset.',
      occurredAt: occurredAt,
    );
  }

  final RestaurantReservationQrSessionActivityKind kind;
  final String label;
  final String? detail;
  final DateTime occurredAt;
  final RestaurantReservationQrScanAction? action;
  final RestaurantReservationQrScanStatus? scanStatus;
  final RestaurantReservationQrSessionActivityTone tone;
}

RestaurantReservationQrSessionActivityTone _toneForScanStatus(
  RestaurantReservationQrScanStatus status,
) {
  return switch (status) {
    RestaurantReservationQrScanStatus.valid =>
      RestaurantReservationQrSessionActivityTone.success,
    RestaurantReservationQrScanStatus.expired =>
      RestaurantReservationQrSessionActivityTone.warning,
    RestaurantReservationQrScanStatus.invalid =>
      RestaurantReservationQrSessionActivityTone.critical,
  };
}

String? _payloadContext(String? zoneLabel, String? tableLabel) {
  final labels = [?zoneLabel, ?tableLabel];
  if (labels.isEmpty) return null;
  return labels.join(' - ');
}
