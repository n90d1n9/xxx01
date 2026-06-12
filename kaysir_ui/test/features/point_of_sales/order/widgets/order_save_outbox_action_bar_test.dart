import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_actions.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_save_outbox_action_bar.dart';

void main() {
  testWidgets('action bar runs enabled sync and clear actions', (tester) async {
    var synced = false;
    var cleared = false;
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: _summary(pendingCount: 1, sentCount: 1),
      syncState: const POSOrderSaveOutboxSyncState.idle(),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasSyncHandler: true,
      hasClearSentHandler: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: OrderSaveOutboxActionBar(
              actions: actions,
              onSync: () => synced = true,
              onClearSent: () => cleared = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sync now'));
    await tester.tap(find.text('Clear synced'));

    expect(synced, isTrue);
    expect(cleared, isTrue);
  });

  testWidgets('action bar disables unsafe actions while syncing', (
    tester,
  ) async {
    var synced = false;
    var cleared = false;
    final actions = POSOrderSaveOutboxActions.resolve(
      summary: _summary(pendingCount: 1, sentCount: 1),
      syncState: POSOrderSaveOutboxSyncState.running(
        startedAt: DateTime(2026, 5, 31, 9),
      ),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
      hasSyncHandler: true,
      hasClearSentHandler: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxActionBar(
            actions: actions,
            onSync: () => synced = true,
            onClearSent: () => cleared = true,
          ),
        ),
      ),
    );

    final syncButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Syncing'),
    );
    final clearButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Clear synced'),
    );

    expect(syncButton.onPressed, isNull);
    expect(clearButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(synced, isFalse);
    expect(cleared, isFalse);
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
