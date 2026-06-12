import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_auto_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_freshness.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_status_presentation.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';

void main() {
  test('status presentation stays hidden for quiet queues', () {
    final presentation = POSOrderSaveOutboxStatusPresentation.resolve(
      summary: const POSOrderSaveOutboxSummary.empty(),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      freshnessState: const POSOrderSaveOutboxFreshnessState.fresh(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
    );

    expect(presentation.shouldSurface, isFalse);
    expect(presentation.canPress, isFalse);
    expect(presentation.intent, POSOrderSaveOutboxStatusIntent.ready);
  });

  test('status presentation exposes pressable queued work', () {
    final presentation = POSOrderSaveOutboxStatusPresentation.resolve(
      summary: _summary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 1,
      ),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      freshnessState: const POSOrderSaveOutboxFreshnessState.fresh(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasAction: true,
    );

    expect(presentation.shouldSurface, isTrue);
    expect(presentation.canPress, isTrue);
    expect(presentation.label, '1 queued');
    expect(presentation.intent, POSOrderSaveOutboxStatusIntent.queued);
    expect(
      presentation.tooltip,
      'Order sync queue: 1 order waiting to sync. Tap to sync.',
    );
  });

  test('status presentation prioritizes running sync state', () {
    final presentation = POSOrderSaveOutboxStatusPresentation.resolve(
      summary: _summary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 1,
      ),
      syncState: POSOrderSaveOutboxSyncState.running(
        startedAt: DateTime(2026, 5, 31, 9),
      ),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      freshnessState: const POSOrderSaveOutboxFreshnessState(
        level: POSOrderSaveOutboxFreshnessLevel.stale,
        stalePendingCount: 1,
        staleFailedCount: 0,
        agingPendingCount: 0,
        agingFailedCount: 0,
        oldestPendingAge: Duration(minutes: 15),
        oldestFailedAge: null,
        syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      ),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasAction: true,
    );

    expect(presentation.isBusy, isTrue);
    expect(presentation.canPress, isFalse);
    expect(presentation.label, 'Syncing');
    expect(presentation.intent, POSOrderSaveOutboxStatusIntent.syncing);
    expect(presentation.tooltip, contains('Syncing queued orders'));
  });

  test('status presentation surfaces stale queue freshness', () {
    final presentation = POSOrderSaveOutboxStatusPresentation.resolve(
      summary: _summary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 1,
      ),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      freshnessState: const POSOrderSaveOutboxFreshnessState(
        level: POSOrderSaveOutboxFreshnessLevel.stale,
        stalePendingCount: 1,
        staleFailedCount: 0,
        agingPendingCount: 0,
        agingFailedCount: 0,
        oldestPendingAge: Duration(minutes: 15),
        oldestFailedAge: null,
        syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      ),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasAction: true,
    );

    expect(presentation.label, 'Stale');
    expect(presentation.intent, POSOrderSaveOutboxStatusIntent.staleQueued);
    expect(
      presentation.tooltip,
      contains(
        'Freshness: 1 queued save waited for 15 min. Run Sync now when ready.',
      ),
    );
  });

  test('status presentation appends auto-sync state', () {
    final presentation = POSOrderSaveOutboxStatusPresentation.resolve(
      summary: _summary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 1,
      ),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: POSOrderSaveOutboxAutoSyncState.skipped(
        reason: POSOrderSaveOutboxAutoSyncSkipReason.cooldown,
        finishedAt: DateTime(2026, 5, 31, 9),
        workCount: 1,
      ),
      freshnessState: const POSOrderSaveOutboxFreshnessState.fresh(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
    );

    expect(
      presentation.tooltip,
      'Order sync queue: 1 order waiting to sync Auto-sync: Auto-sync is cooling down briefly before another background run.',
    );
  });

  test('status presentation can describe review actions', () {
    final presentation = POSOrderSaveOutboxStatusPresentation.resolve(
      summary: _summary(
        health: POSOrderSaveOutboxHealth.queued,
        pendingCount: 1,
      ),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      autoSyncState: const POSOrderSaveOutboxAutoSyncState.idle(),
      freshnessState: const POSOrderSaveOutboxFreshnessState.fresh(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasAction: true,
      actionKind: POSOrderSaveOutboxStatusActionKind.review,
    );

    expect(presentation.canPress, isTrue);
    expect(
      presentation.tooltip,
      'Order sync queue: 1 order waiting to sync. Tap to review.',
    );
  });
}

POSOrderSaveOutboxSummary _summary({
  required POSOrderSaveOutboxHealth health,
  int pendingCount = 0,
  int sendingCount = 0,
  int failedCount = 0,
  int sentCount = 0,
}) {
  return POSOrderSaveOutboxSummary(
    health: health,
    pendingCount: pendingCount,
    sendingCount: sendingCount,
    failedCount: failedCount,
    sentCount: sentCount,
    totalCount: pendingCount + sendingCount + failedCount + sentCount,
  );
}
