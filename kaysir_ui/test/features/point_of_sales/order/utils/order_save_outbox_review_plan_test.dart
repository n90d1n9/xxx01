import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_review_plan.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';

void main() {
  test('review plan prioritizes failed saves before queued work', () {
    final plan = POSOrderSaveOutboxReviewPlan.resolve(
      summary: const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.failed,
        pendingCount: 1,
        sendingCount: 0,
        failedCount: 2,
        sentCount: 0,
        totalCount: 3,
      ),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.standard,
    );

    expect(plan.title, 'Review failed saves first');
    expect(plan.guidanceMessage, contains('2 orders failed'));
    expect(plan.guidanceMessage, contains('1 order queued'));
    expect(plan.guidanceMessage, contains('Retry failed saves first'));
    expect(plan.retryNoticeMessage, contains('Queued saves stay ready'));
  });

  test('review plan keeps failed-only queues concise', () {
    final plan = POSOrderSaveOutboxReviewPlan.resolve(
      summary: const POSOrderSaveOutboxSummary(
        health: POSOrderSaveOutboxHealth.failed,
        pendingCount: 0,
        sendingCount: 0,
        failedCount: 1,
        sentCount: 0,
        totalCount: 1,
      ),
      syncBehavior: POSOrderSaveOutboxSyncBehavior.quickCheckout,
    );

    expect(plan.title, 'Retry failed saves');
    expect(plan.guidanceMessage, contains('1 order failed'));
    expect(plan.retryNoticeMessage, contains('failed saves currently shown'));
  });
}
