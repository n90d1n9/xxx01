import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_display.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';

void main() {
  test('sync display stays hidden while idle', () {
    final display = POSOrderSaveOutboxSyncDisplay.fromState(
      const POSOrderSaveOutboxSyncState.idle(),
    );

    expect(display.isVisible, isFalse);
    expect(display.title, 'Order sync is idle');
  });

  test('sync display summarizes successful results with metrics', () {
    final display = POSOrderSaveOutboxSyncDisplay.fromState(
      POSOrderSaveOutboxSyncState.completed(
        result: const POSOrderSaveOutboxSyncResult(
          submitted: 2,
          sent: 2,
          failed: 0,
          skipped: 0,
          remainingPending: 0,
          remainingFailed: 0,
        ),
        startedAt: _startedAt,
        finishedAt: _finishedAt,
      ),
    );

    expect(display.isVisible, isTrue);
    expect(display.tone, POSOrderSaveOutboxSyncNoticeTone.success);
    expect(display.title, 'Sync completed');
    expect(display.message, '2 orders synced.');
    expect(
      display.metrics.map((metric) => '${metric.label}:${metric.value}'),
      containsAll(['Synced:2', 'Failed:0', 'Queued left:0']),
    );
  });

  test('sync display marks remaining failed work as attention', () {
    final display = POSOrderSaveOutboxSyncDisplay.fromState(
      POSOrderSaveOutboxSyncState.completed(
        result: const POSOrderSaveOutboxSyncResult(
          submitted: 2,
          sent: 1,
          failed: 1,
          skipped: 0,
          remainingPending: 1,
          remainingFailed: 1,
        ),
        startedAt: _startedAt,
        finishedAt: _finishedAt,
      ),
    );

    expect(display.tone, POSOrderSaveOutboxSyncNoticeTone.warning);
    expect(display.title, 'Sync needs attention');
    expect(
      display.message,
      '1 order synced, 1 order failed, 1 order still queued, 1 order still failed.',
    );
  });

  test('sync display reports thrown failures', () {
    final display = POSOrderSaveOutboxSyncDisplay.fromState(
      POSOrderSaveOutboxSyncState.failed(
        error: StateError('offline'),
        startedAt: _startedAt,
        finishedAt: _finishedAt,
      ),
    );

    expect(display.tone, POSOrderSaveOutboxSyncNoticeTone.danger);
    expect(display.title, 'Unable to sync');
    expect(display.message, 'Bad state: offline');
  });
}

final _startedAt = DateTime(2026, 5, 31, 8);
final _finishedAt = DateTime(2026, 5, 31, 8, 1);
