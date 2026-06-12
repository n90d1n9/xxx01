import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/states/order_save_outbox_auto_sync_provider.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_auto_sync_state.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'auto sync controller drains when the active behavior opts in',
    () async {
      final envelope = _envelope('order_1');
      final outbox = POSOrderSaveOutbox().enqueue(envelope);
      int? capturedLimit;
      bool? capturedRetryFailed;
      bool? capturedContinueOnError;

      final controller = POSOrderSaveOutboxAutoSyncController(
        readOutbox: () => outbox,
        readSyncState: () => const POSOrderSaveOutboxSyncState.idle(),
        readSyncBehavior: () => POSOrderSaveOutboxSyncBehavior.quickCheckout,
        drain: ({limit, retryFailed, continueOnError}) async {
          capturedLimit = limit;
          capturedRetryFailed = retryFailed;
          capturedContinueOnError = continueOnError;
          return POSOrderSaveOutboxSyncResult.empty(outbox);
        },
        clock: () => DateTime(2026, 5, 31, 9),
      );

      final future = controller.maybeSyncAfterCompletion();
      expect(controller.state.phase, POSOrderSaveOutboxAutoSyncPhase.running);
      await future;

      expect(future, isNotNull);
      expect(capturedLimit, 12);
      expect(capturedRetryFailed, isFalse);
      expect(capturedContinueOnError, isTrue);
      expect(controller.lastAutoSyncAt, DateTime(2026, 5, 31, 9));
      expect(controller.lastAutoSyncFuture, same(future));
      expect(controller.state.phase, POSOrderSaveOutboxAutoSyncPhase.completed);
      expect(controller.state.result?.submitted, 0);
    },
  );

  test('auto sync controller skips manual modes and active drains', () {
    final envelope = _envelope('order_1');
    final outbox = POSOrderSaveOutbox().enqueue(envelope);
    var drainCount = 0;

    final manual = POSOrderSaveOutboxAutoSyncController(
      readOutbox: () => outbox,
      readSyncState: () => const POSOrderSaveOutboxSyncState.idle(),
      readSyncBehavior: () => POSOrderSaveOutboxSyncBehavior.standard,
      drain: ({limit, retryFailed, continueOnError}) async {
        drainCount++;
        return POSOrderSaveOutboxSyncResult.empty(outbox);
      },
    );

    expect(manual.maybeSyncAfterCompletion(), isNull);
    expect(
      manual.state.skipReason,
      POSOrderSaveOutboxAutoSyncSkipReason.disabled,
    );

    final running = POSOrderSaveOutboxAutoSyncController(
      readOutbox: () => outbox,
      readSyncState:
          () => POSOrderSaveOutboxSyncState.running(
            startedAt: DateTime(2026, 5, 31, 9),
          ),
      readSyncBehavior: () => POSOrderSaveOutboxSyncBehavior.quickCheckout,
      drain: ({limit, retryFailed, continueOnError}) async {
        drainCount++;
        return POSOrderSaveOutboxSyncResult.empty(outbox);
      },
    );

    expect(running.maybeSyncAfterCompletion(), isNull);
    expect(
      running.state.skipReason,
      POSOrderSaveOutboxAutoSyncSkipReason.syncRunning,
    );
    expect(drainCount, 0);
  });

  test('auto sync controller enforces behavior cooldowns', () async {
    final envelope = _envelope('order_1');
    final outbox = POSOrderSaveOutbox().enqueue(envelope);
    var now = DateTime(2026, 5, 31, 9);
    var drainCount = 0;
    final behavior = POSOrderSaveOutboxSyncBehavior.standard.copyWith(
      autoSyncAfterCompletion: true,
      autoSyncCooldown: const Duration(seconds: 30),
    );

    final controller = POSOrderSaveOutboxAutoSyncController(
      readOutbox: () => outbox,
      readSyncState: () => const POSOrderSaveOutboxSyncState.idle(),
      readSyncBehavior: () => behavior,
      drain: ({limit, retryFailed, continueOnError}) async {
        drainCount++;
        return POSOrderSaveOutboxSyncResult.empty(outbox);
      },
      clock: () => now,
    );

    await controller.maybeSyncAfterCompletion();
    now = DateTime(2026, 5, 31, 9, 0, 10);
    expect(controller.maybeSyncAfterCompletion(), isNull);
    expect(
      controller.state.skipReason,
      POSOrderSaveOutboxAutoSyncSkipReason.cooldown,
    );
    now = DateTime(2026, 5, 31, 9, 0, 31);
    await controller.maybeSyncAfterCompletion();

    expect(drainCount, 2);
  });
}

POSOrderPayloadEnvelope _envelope(String id) {
  return buildPOSOrderPayloadEnvelope(
    _order(id),
    preparedAt: DateTime(2026, 5, 31, 8, 45),
  );
}

Order _order(String id) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: id,
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: [
      Payment(
        id: 'payment_1',
        amount: 50000,
        method: 'Cash',
        timestamp: DateTime(2026, 5, 31, 8, 15),
        reference: 'REF1',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: 'terminal_1',
      name: 'Terminal 1',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime.utc(2026, 5, 31, 1),
    status: 'completed',
  );
}
