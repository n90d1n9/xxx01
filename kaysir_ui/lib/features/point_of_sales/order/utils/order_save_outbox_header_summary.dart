import 'order_save_outbox_summary.dart';

enum POSOrderSaveOutboxHeaderMetricKind { status, review, synced }

class POSOrderSaveOutboxHeaderMetric {
  final POSOrderSaveOutboxHeaderMetricKind kind;
  final String label;
  final String value;

  const POSOrderSaveOutboxHeaderMetric({
    required this.kind,
    required this.label,
    required this.value,
  });
}

class POSOrderSaveOutboxHeaderSummary {
  final List<POSOrderSaveOutboxHeaderMetric> metrics;

  POSOrderSaveOutboxHeaderSummary._(
    Iterable<POSOrderSaveOutboxHeaderMetric> metrics,
  ) : metrics = List.unmodifiable(metrics);

  factory POSOrderSaveOutboxHeaderSummary.fromSummary(
    POSOrderSaveOutboxSummary summary,
  ) {
    return POSOrderSaveOutboxHeaderSummary._([
      POSOrderSaveOutboxHeaderMetric(
        kind: POSOrderSaveOutboxHeaderMetricKind.status,
        label: 'Status',
        value: _statusLabel(summary.health),
      ),
      if (summary.attentionCount > 0)
        POSOrderSaveOutboxHeaderMetric(
          kind: POSOrderSaveOutboxHeaderMetricKind.review,
          label: 'Needs review',
          value: summary.attentionCount.toString(),
        ),
      if (summary.sentCount > 0)
        POSOrderSaveOutboxHeaderMetric(
          kind: POSOrderSaveOutboxHeaderMetricKind.synced,
          label: 'Synced',
          value: summary.sentCount.toString(),
        ),
    ]);
  }
}

String _statusLabel(POSOrderSaveOutboxHealth health) {
  switch (health) {
    case POSOrderSaveOutboxHealth.failed:
      return 'Failed';
    case POSOrderSaveOutboxHealth.syncing:
      return 'Syncing';
    case POSOrderSaveOutboxHealth.queued:
      return 'Queued';
    case POSOrderSaveOutboxHealth.ready:
      return 'Ready';
  }
}
