import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_activity.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_activity_display.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_error_copy.dart';

void main() {
  test('activity display formats order lifecycle events', () {
    final display = POSOrderSaveOutboxActivityDisplay.fromActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.failed,
        occurredAt: DateTime(2026, 5, 31, 9, 5),
        orderId: 'order_123456',
        message: 'Network down',
      ),
    );

    expect(display.title, 'Order #123456 failed');
    expect(display.detail, 'Network down');
    expect(display.timeLabel, '09:05');
  });

  test('latest activity returns newest events first with a limit', () {
    final oldest = POSOrderSaveOutboxActivity(
      type: POSOrderSaveOutboxActivityType.queued,
      occurredAt: DateTime(2026, 5, 31, 9),
    );
    final newest = POSOrderSaveOutboxActivity(
      type: POSOrderSaveOutboxActivityType.sent,
      occurredAt: DateTime(2026, 5, 31, 9, 2),
    );
    final middle = POSOrderSaveOutboxActivity(
      type: POSOrderSaveOutboxActivityType.sending,
      occurredAt: DateTime(2026, 5, 31, 9, 1),
    );

    final latest = latestPOSOrderSaveOutboxActivity([
      oldest,
      newest,
      middle,
    ], limit: 2);

    expect(latest, [newest, middle]);
  });

  test('activity display sanitizes legacy raw network errors', () {
    final display = POSOrderSaveOutboxActivityDisplay.fromActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.failed,
        occurredAt: DateTime(2026, 5, 31, 9, 5),
        orderId: 'order_123456',
        message:
            'DioException [connection error]: Failed host lookup: api.local',
      ),
    );

    expect(display.detail, posOrderSaveFailureMessage);
    expect(display.detail, isNot(contains('DioException')));
  });
}
