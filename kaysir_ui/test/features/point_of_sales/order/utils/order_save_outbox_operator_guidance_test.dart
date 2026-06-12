import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_auto_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_operator_guidance.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';

void main() {
  test('operator guidance prioritizes failed saves', () {
    final guidance = POSOrderSaveOutboxOperatorGuidance.resolve(
      summary: const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.failed,
        pendingCount: 1,
        sendingCount: 0,
        failedCount: 2,
        sentCount: 0,
        totalCount: 3,
      ),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
    );

    expect(guidance.tone, POSOrderSaveOutboxGuidanceTone.danger);
    expect(guidance.title, 'Review failed saves first');
    expect(guidance.message, contains('2 orders failed'));
    expect(guidance.message, contains('Retry failed saves first'));
  });

  test('operator guidance calls out manual sync for standard queue work', () {
    final guidance = POSOrderSaveOutboxOperatorGuidance.resolve(
      summary: const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 1,
        sendingCount: 0,
        failedCount: 0,
        sentCount: 0,
        totalCount: 1,
      ),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
    );

    expect(guidance.tone, POSOrderSaveOutboxGuidanceTone.warning);
    expect(guidance.title, 'Manual sync required');
    expect(guidance.message, contains('Run Sync now'));
  });

  test('operator guidance explains auto-sync cooldowns', () {
    final guidance = POSOrderSaveOutboxOperatorGuidance.resolve(
      summary: const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 1,
        sendingCount: 0,
        failedCount: 0,
        sentCount: 0,
        totalCount: 1,
      ),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: POSOrderSaveOutboxAutoSyncState.skipped(
        reason: POSOrderSaveOutboxAutoSyncSkipReason.cooldown,
        finishedAt: DateTime(2026, 5, 31, 9),
        workCount: 1,
      ),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.quickCheckout,
    );

    expect(guidance.tone, POSOrderSaveOutboxGuidanceTone.warning);
    expect(guidance.title, 'Auto-sync paused briefly');
    expect(guidance.message, contains('cooling down'));
  });

  test('operator guidance summarizes completed syncs', () {
    final guidance = POSOrderSaveOutboxOperatorGuidance.resolve(
      summary: const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.ready,
        pendingCount: 0,
        sendingCount: 0,
        failedCount: 0,
        sentCount: 2,
        totalCount: 2,
      ),
      syncState: POSOrderSaveOutboxSyncState.completed(
        result: const POSOrderSaveOutboxSyncResult(
          submitted: 2,
          sent: 2,
          failed: 0,
          skipped: 0,
          remainingPending: 0,
          remainingFailed: 0,
        ),
        startedAt: DateTime(2026, 5, 31, 9),
        finishedAt: DateTime(2026, 5, 31, 9, 1),
      ),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
    );

    expect(guidance.tone, POSOrderSaveOutboxGuidanceTone.success);
    expect(guidance.title, 'Sync completed');
    expect(guidance.message, '2 orders synced');
  });
}
