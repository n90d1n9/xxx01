import '../models/reservation_qr_expiry_status.dart';
import '../models/reservation_qr_scan_result.dart';
import '../models/reservation_qr_session_state.dart';
import '../models/reservation_qr_session_summary.dart';
import 'reservation_qr_expiry_status_presenter.dart';

/// Builds compact host-facing summaries for reservation QR session state.
class RestaurantReservationQrSessionSummaryPresenter {
  const RestaurantReservationQrSessionSummaryPresenter({
    this.expiryWarningThreshold = const Duration(minutes: 5),
  });

  final Duration expiryWarningThreshold;

  RestaurantReservationQrSessionSummaryPresentation build(
    RestaurantReservationQrSessionState state, {
    DateTime? now,
  }) {
    final selectedAction = state.selectedAction;
    final workflow = state.scanWorkflow;
    final activeLink = state.activeLink;
    final referenceTime = now ?? DateTime.now();
    final metrics = _buildMetrics(state, now: referenceTime);

    if (selectedAction != null) {
      return RestaurantReservationQrSessionSummaryPresentation(
        title: 'QR action selected',
        message: '${selectedAction.label}: ${selectedAction.detailLabel}',
        tone: RestaurantReservationQrSessionSummaryTone.active,
        metrics: metrics,
      );
    }

    if (workflow != null) {
      return _scanSummary(
        status: workflow.result.status,
        message: workflow.result.detailLabel,
        metrics: metrics,
      );
    }

    if (activeLink != null) {
      final expiry = _buildExpiry(activeLink.payload.expiresAt, referenceTime);
      final intentLabel = activeLink.payload.intent.label;

      return switch (expiry.urgency) {
        RestaurantReservationQrExpiryUrgency.fresh =>
          RestaurantReservationQrSessionSummaryPresentation(
            title: 'QR handoff active',
            message: '$intentLabel link is ready for scan. ${expiry.label}.',
            tone: RestaurantReservationQrSessionSummaryTone.active,
            metrics: metrics,
          ),
        RestaurantReservationQrExpiryUrgency.expiringSoon =>
          RestaurantReservationQrSessionSummaryPresentation(
            title: 'QR handoff expiring soon',
            message:
                '$intentLabel link ${expiry.label.toLowerCase()}. '
                'Refresh if the guest has not scanned yet.',
            tone: RestaurantReservationQrSessionSummaryTone.warning,
            metrics: metrics,
          ),
        RestaurantReservationQrExpiryUrgency.expired =>
          RestaurantReservationQrSessionSummaryPresentation(
            title: 'QR handoff expired',
            message:
                '$intentLabel link expired. Generate a fresh QR link before '
                'the guest scans.',
            tone: RestaurantReservationQrSessionSummaryTone.critical,
            metrics: metrics,
          ),
      };
    }

    return RestaurantReservationQrSessionSummaryPresentation(
      title: 'QR session idle',
      message: 'No active QR handoff.',
      tone: RestaurantReservationQrSessionSummaryTone.neutral,
      metrics: metrics,
    );
  }

  RestaurantReservationQrSessionSummaryPresentation _scanSummary({
    required RestaurantReservationQrScanStatus status,
    required String message,
    required List<RestaurantReservationQrSessionSummaryMetric> metrics,
  }) {
    return switch (status) {
      RestaurantReservationQrScanStatus.valid =>
        RestaurantReservationQrSessionSummaryPresentation(
          title: 'QR scan ready',
          message: message,
          tone: RestaurantReservationQrSessionSummaryTone.success,
          metrics: metrics,
        ),
      RestaurantReservationQrScanStatus.expired =>
        RestaurantReservationQrSessionSummaryPresentation(
          title: 'QR scan needs refresh',
          message: message,
          tone: RestaurantReservationQrSessionSummaryTone.warning,
          metrics: metrics,
        ),
      RestaurantReservationQrScanStatus.invalid =>
        RestaurantReservationQrSessionSummaryPresentation(
          title: 'QR scan blocked',
          message: message,
          tone: RestaurantReservationQrSessionSummaryTone.critical,
          metrics: metrics,
        ),
    };
  }

  List<RestaurantReservationQrSessionSummaryMetric> _buildMetrics(
    RestaurantReservationQrSessionState state, {
    required DateTime now,
  }) {
    return [
      if (state.activeLink != null)
        RestaurantReservationQrSessionSummaryMetric(
          label: 'Link',
          value: state.activeLink!.payload.intent.label,
        ),
      if (state.activeLink != null)
        RestaurantReservationQrSessionSummaryMetric(
          label: 'Expiry',
          value: _buildExpiry(state.activeLink!.payload.expiresAt, now).label,
        ),
      if (state.scanWorkflow != null)
        RestaurantReservationQrSessionSummaryMetric(
          label: 'Scan',
          value: state.scanWorkflow!.result.status.label,
        ),
      if (state.selectedAction != null)
        RestaurantReservationQrSessionSummaryMetric(
          label: 'Action',
          value: state.selectedAction!.label,
        ),
      if (state.activityTrail.isNotEmpty)
        RestaurantReservationQrSessionSummaryMetric(
          label: 'Events',
          value: _eventCountLabel(state.activityTrail.length),
        ),
    ];
  }

  String _eventCountLabel(int count) {
    return count == 1 ? '1 event' : '$count events';
  }

  RestaurantReservationQrExpiryStatus _buildExpiry(
    DateTime expiresAt,
    DateTime now,
  ) {
    return RestaurantReservationQrExpiryStatusPresenter(
      warningThreshold: expiryWarningThreshold,
    ).build(expiresAt: expiresAt, now: now);
  }
}
