import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_freshness.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_save_outbox_freshness_notice.dart';

void main() {
  testWidgets('freshness notice hides healthy queues', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxFreshnessNotice(
            freshnessState: POSOrderSaveOutboxFreshnessState(
              level: POSOrderSaveOutboxFreshnessLevel.fresh,
              stalePendingCount: 0,
              staleFailedCount: 0,
              agingPendingCount: 0,
              agingFailedCount: 0,
              oldestPendingAge: null,
              oldestFailedAge: null,
              syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Queue wait time healthy'), findsNothing);
  });

  testWidgets('freshness notice surfaces stale failed saves', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSaveOutboxFreshnessNotice(
            freshnessState: POSOrderSaveOutboxFreshnessState(
              level: POSOrderSaveOutboxFreshnessLevel.stale,
              stalePendingCount: 0,
              staleFailedCount: 1,
              agingPendingCount: 0,
              agingFailedCount: 0,
              oldestPendingAge: null,
              oldestFailedAge: Duration(minutes: 6),
              syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Failed saves are stale'), findsOneWidget);
    expect(
      find.text(
        '1 failed save waited for 6 min. Retry before closing this register.',
      ),
      findsOneWidget,
    );
  });
}
