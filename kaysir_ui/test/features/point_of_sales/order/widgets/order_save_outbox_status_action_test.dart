import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_freshness.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_save_outbox_status_action.dart';

void main() {
  testWidgets('outbox status action stays hidden for quiet queues', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxStatusAction(
            summary: POSOrderSaveOutboxSummary.empty(),
          ),
        ),
      ),
    );

    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('outbox status action opens the queue for stale work', (
    tester,
  ) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderSaveOutboxStatusAction(
              summary: const POSOrderSaveOutboxSummary(
                health: POSOrderSaveOutboxHealth.queued,
                pendingCount: 1,
                sendingCount: 0,
                failedCount: 0,
                sentCount: 0,
                totalCount: 1,
              ),
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
              onPressed: () => opened = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.schedule_send_outlined), findsOneWidget);
    expect(
      find.byTooltip(
        'Order sync queue: 1 order waiting to sync. Tap to review. Freshness: 1 queued save waited for 15 min. Run Sync now when ready.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.schedule_send_outlined));

    expect(opened, isTrue);
  });

  testWidgets('outbox status action stays available while sync is running', (
    tester,
  ) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OrderSaveOutboxStatusAction(
              summary: const POSOrderSaveOutboxSummary(
                health: POSOrderSaveOutboxHealth.queued,
                pendingCount: 1,
                sendingCount: 0,
                failedCount: 0,
                sentCount: 0,
                totalCount: 1,
              ),
              syncState: POSOrderSaveOutboxSyncState.running(
                startedAt: DateTime(2026, 5, 31, 9),
              ),
              onPressed: () => opened = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.sync_outlined), findsOneWidget);
    expect(
      find.byTooltip('Syncing queued orders. Tap to review.'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.sync_outlined));

    expect(opened, isTrue);
  });
}
