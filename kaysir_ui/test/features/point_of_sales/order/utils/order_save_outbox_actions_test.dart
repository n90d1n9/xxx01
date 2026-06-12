import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_actions.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';

void main() {
  test('actions enable sync and clear only when work and handlers exist', () {
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: _summary(pendingCount: 2, sentCount: 1),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasSyncHandler: true,
      hasClearSentHandler: true,
    );

    expect(actions.syncNow.isEnabled, isTrue);
    expect(actions.syncNow.label, 'Sync now');
    expect(actions.syncNow.affectedCount, 2);
    expect(actions.clearSent.isEnabled, isTrue);
    expect(actions.clearSent.affectedCount, 1);
    expect(actions.retryShown.visible, isFalse);
  });

  test('actions explain disabled states for unavailable work', () {
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: _summary(),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasSyncHandler: true,
      hasClearSentHandler: true,
    );

    expect(actions.syncNow.isEnabled, isFalse);
    expect(
      actions.syncNow.disabledReason,
      'No queued or failed saves are ready to sync.',
    );
    expect(actions.clearSent.isEnabled, isFalse);
    expect(
      actions.clearSent.disabledReason,
      'No submitted saves are ready to clear.',
    );
  });

  test('actions lock unsafe operations while sync is running', () {
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: _summary(pendingCount: 1, failedCount: 1, sentCount: 1),
      syncState: POSOrderSaveOutboxSyncState.running(
        startedAt: DateTime(2026, 5, 31, 9),
      ),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      retryableShownCount: 1,
      hasSyncHandler: true,
      hasClearSentHandler: true,
      hasRetryShownHandler: true,
    );

    expect(actions.syncNow.label, 'Syncing');
    expect(actions.syncNow.busy, isTrue);
    expect(actions.syncNow.isEnabled, isFalse);
    expect(actions.clearSent.isEnabled, isFalse);
    expect(
      actions.clearSent.disabledReason,
      'Finish the current sync before clearing submitted saves.',
    );
    expect(actions.retryShown.label, 'Syncing');
    expect(actions.retryShown.isEnabled, isFalse);
  });

  test('actions keep retry labels mode-specific', () {
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: _summary(pendingCount: 1, failedCount: 2),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.quickCheckout,
      retryableShownCount: 2,
      hasRetryShownHandler: true,
    );

    expect(actions.retryShown.visible, isTrue);
    expect(actions.retryShown.isEnabled, isTrue);
    expect(actions.retryShown.label, 'Retry sales');
    expect(actions.retryShownNoticeTitle, '2 failed saves shown');
    expect(
      actions.retryShownNoticeMessage,
      contains('Queued saves stay ready'),
    );
  });
}

POSOrderSaveOutboxSummary _summary({
  int pendingCount = 0,
  int sendingCount = 0,
  int failedCount = 0,
  int sentCount = 0,
}) {
  final health =
      failedCount > 0
          ? POSOrderSaveOutboxHealth.failed
          : sendingCount > 0
          ? POSOrderSaveOutboxHealth.syncing
          : pendingCount > 0
          ? POSOrderSaveOutboxHealth.queued
          : POSOrderSaveOutboxHealth.ready;

  return POSOrderSaveOutboxSummary(
    health: health,
    pendingCount: pendingCount,
    sendingCount: sendingCount,
    failedCount: failedCount,
    sentCount: sentCount,
    totalCount: pendingCount + sendingCount + failedCount + sentCount,
  );
}
