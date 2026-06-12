import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_auto_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync.dart';

void main() {
  test('auto sync state describes skip reasons for operators', () {
    final disabled = POSOrderSaveOutboxAutoSyncState.skipped(
      reason: POSOrderSaveOutboxAutoSyncSkipReason.disabled,
      finishedAt: DateTime(2026, 5, 31, 9),
    );
    final cooldown = POSOrderSaveOutboxAutoSyncState.skipped(
      reason: POSOrderSaveOutboxAutoSyncSkipReason.cooldown,
      finishedAt: DateTime(2026, 5, 31, 9, 1),
      workCount: 2,
    );

    expect(disabled.title, 'Auto-sync skipped');
    expect(disabled.operatorMessage, contains('operator control'));
    expect(cooldown.operatorMessage, contains('cooling down'));
    expect(cooldown.shouldSurface, isTrue);
  });

  test('auto sync state summarizes running and completed outcomes', () {
    final running = POSOrderSaveOutboxAutoSyncState.running(
      startedAt: DateTime(2026, 5, 31, 9),
      workCount: 2,
    );
    final completed = POSOrderSaveOutboxAutoSyncState.completed(
      result: POSOrderSaveOutboxSyncResult(
        submitted: 2,
        sent: 2,
        failed: 0,
        skipped: 0,
        remainingPending: 0,
        remainingFailed: 0,
      ),
      startedAt: DateTime(2026, 5, 31, 9),
      finishedAt: DateTime(2026, 5, 31, 9, 1),
      workCount: 2,
    );

    expect(running.isRunning, isTrue);
    expect(
      running.operatorMessage,
      'Submitting 2 queued order saves in the background.',
    );
    expect(completed.title, 'Auto-sync completed');
    expect(completed.operatorMessage, '2 orders synced automatically.');
  });

  test('auto sync state surfaces failed sync outcomes', () {
    final failed = POSOrderSaveOutboxAutoSyncState.failed(
      error: StateError('offline'),
      startedAt: DateTime(2026, 5, 31, 9),
      finishedAt: DateTime(2026, 5, 31, 9, 1),
      workCount: 1,
    );

    expect(failed.title, 'Auto-sync failed');
    expect(failed.operatorMessage, contains('offline'));
  });
}
