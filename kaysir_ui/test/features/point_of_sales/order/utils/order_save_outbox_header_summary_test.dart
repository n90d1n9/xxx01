import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_header_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';

void main() {
  test('header summary exposes failed, review, and synced metrics', () {
    final header = POSOrderSaveOutboxHeaderSummary.fromSummary(
      const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.failed,
        pendingCount: 1,
        sendingCount: 0,
        failedCount: 2,
        sentCount: 3,
        totalCount: 6,
      ),
    );

    expect(header.metrics.map((metric) => metric.kind), [
      POSOrderSaveOutboxHeaderMetricKind.status,
      POSOrderSaveOutboxHeaderMetricKind.review,
      POSOrderSaveOutboxHeaderMetricKind.synced,
    ]);
    expect(header.metrics.map((metric) => '${metric.label}:${metric.value}'), [
      'Status:Failed',
      'Needs review:3',
      'Synced:3',
    ]);
  });

  test('header summary omits review and synced metrics when empty', () {
    final header = POSOrderSaveOutboxHeaderSummary.fromSummary(
      const POSOrderSaveOutboxSummary.empty(),
    );

    expect(header.metrics, hasLength(1));
    expect(
      header.metrics.single.kind,
      POSOrderSaveOutboxHeaderMetricKind.status,
    );
    expect(header.metrics.single.value, 'Ready');
  });

  test('header summary reports syncing and queued status labels', () {
    final syncing = POSOrderSaveOutboxHeaderSummary.fromSummary(
      const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.syncing,
        pendingCount: 0,
        sendingCount: 1,
        failedCount: 0,
        sentCount: 0,
        totalCount: 1,
      ),
    );
    final queued = POSOrderSaveOutboxHeaderSummary.fromSummary(
      const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 2,
        sendingCount: 0,
        failedCount: 0,
        sentCount: 0,
        totalCount: 2,
      ),
    );

    expect(syncing.metrics.first.value, 'Syncing');
    expect(queued.metrics.first.value, 'Queued');
  });
}
