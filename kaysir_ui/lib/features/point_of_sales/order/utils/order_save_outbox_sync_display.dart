import 'order_save_outbox_sync.dart';
import 'order_save_outbox_sync_state.dart';

enum POSOrderSaveOutboxSyncNoticeTone { info, success, warning, danger }

class POSOrderSaveOutboxSyncMetric {
  final String label;
  final String value;

  const POSOrderSaveOutboxSyncMetric({
    required this.label,
    required this.value,
  });
}

class POSOrderSaveOutboxSyncDisplay {
  final bool isVisible;
  final POSOrderSaveOutboxSyncNoticeTone tone;
  final String title;
  final String message;
  final List<POSOrderSaveOutboxSyncMetric> metrics;

  POSOrderSaveOutboxSyncDisplay({
    required this.isVisible,
    required this.tone,
    required this.title,
    required this.message,
    Iterable<POSOrderSaveOutboxSyncMetric> metrics = const [],
  }) : metrics = List.unmodifiable(metrics);

  factory POSOrderSaveOutboxSyncDisplay.fromState(
    POSOrderSaveOutboxSyncState state,
  ) {
    switch (state.phase) {
      case POSOrderSaveOutboxSyncPhase.idle:
        return POSOrderSaveOutboxSyncDisplay(
          isVisible: false,
          tone: POSOrderSaveOutboxSyncNoticeTone.info,
          title: 'Order sync is idle',
          message: 'Queued order saves will appear here when available.',
        );
      case POSOrderSaveOutboxSyncPhase.running:
        return POSOrderSaveOutboxSyncDisplay(
          isVisible: true,
          tone: POSOrderSaveOutboxSyncNoticeTone.info,
          title: 'Sync in progress',
          message: 'Queued orders are being submitted now.',
        );
      case POSOrderSaveOutboxSyncPhase.failed:
        return POSOrderSaveOutboxSyncDisplay(
          isVisible: true,
          tone: POSOrderSaveOutboxSyncNoticeTone.danger,
          title: 'Unable to sync',
          message: state.lastError ?? 'Unknown sync failure',
        );
      case POSOrderSaveOutboxSyncPhase.completed:
        return _completedDisplay(state.lastResult);
    }
  }

  static POSOrderSaveOutboxSyncDisplay _completedDisplay(
    POSOrderSaveOutboxSyncResult? result,
  ) {
    if (result == null) {
      return POSOrderSaveOutboxSyncDisplay(
        isVisible: true,
        tone: POSOrderSaveOutboxSyncNoticeTone.success,
        title: 'Sync completed',
        message: 'Order sync finished.',
      );
    }

    final metrics = _metricsFor(result);
    if (result.hasFailures) {
      return POSOrderSaveOutboxSyncDisplay(
        isVisible: true,
        tone: POSOrderSaveOutboxSyncNoticeTone.warning,
        title: 'Sync needs attention',
        message: _resultMessage(result),
        metrics: metrics,
      );
    }

    if (result.sent == 0 && result.submitted == 0) {
      return POSOrderSaveOutboxSyncDisplay(
        isVisible: true,
        tone: POSOrderSaveOutboxSyncNoticeTone.info,
        title: 'Nothing to sync',
        message: 'No queued or failed order saves were ready.',
        metrics: metrics,
      );
    }

    return POSOrderSaveOutboxSyncDisplay(
      isVisible: true,
      tone: POSOrderSaveOutboxSyncNoticeTone.success,
      title: 'Sync completed',
      message: _resultMessage(result),
      metrics: metrics,
    );
  }

  static List<POSOrderSaveOutboxSyncMetric> _metricsFor(
    POSOrderSaveOutboxSyncResult result,
  ) {
    return [
      POSOrderSaveOutboxSyncMetric(
        label: 'Synced',
        value: result.sent.toString(),
      ),
      POSOrderSaveOutboxSyncMetric(
        label: 'Failed',
        value: result.failed.toString(),
      ),
      POSOrderSaveOutboxSyncMetric(
        label: 'Queued left',
        value: result.remainingPending.toString(),
      ),
      POSOrderSaveOutboxSyncMetric(
        label: 'Failed left',
        value: result.remainingFailed.toString(),
      ),
      if (result.skipped > 0)
        POSOrderSaveOutboxSyncMetric(
          label: 'Skipped',
          value: result.skipped.toString(),
        ),
    ];
  }

  static String _resultMessage(POSOrderSaveOutboxSyncResult result) {
    final parts = <String>[];
    if (result.sent > 0) {
      parts.add(_orders(result.sent, 'synced'));
    }
    if (result.failed > 0) {
      parts.add(_orders(result.failed, 'failed'));
    }
    if (result.remainingPending > 0) {
      parts.add(_orders(result.remainingPending, 'still queued'));
    }
    if (result.remainingFailed > 0) {
      parts.add(_orders(result.remainingFailed, 'still failed'));
    }
    if (parts.isEmpty) {
      return 'No queued order saves changed.';
    }
    return '${parts.join(', ')}.';
  }

  static String _orders(int count, String status) {
    final noun = count == 1 ? 'order' : 'orders';
    return '$count $noun $status';
  }
}
