import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_behavior.dart';

void main() {
  test('standard sync behavior preserves current outbox drain defaults', () {
    const behavior = POSOrderSaveOutboxSyncBehavior.standard;

    expect(behavior.queueTitle, 'Order sync queue');
    expect(behavior.syncActionLabel, 'Sync now');
    expect(behavior.drainLimit, 20);
    expect(behavior.retryFailedByDefault, isTrue);
    expect(behavior.continueOnError, isTrue);
    expect(behavior.stalePendingAfter, const Duration(minutes: 10));
    expect(behavior.staleFailedAfter, const Duration(minutes: 5));
    expect(behavior.policyLabels, [
      'Batch 20',
      'Retries failed',
      'Keeps syncing',
      'Manual sync',
    ]);
    expect(
      behavior.shouldAutoSyncAfterOrderCompletion(
        pendingCount: 1,
        failedCount: 0,
        now: DateTime(2026, 5, 31, 9),
      ),
      isFalse,
    );
  });

  test('mode sync behaviors can specialize queue strategy and copy safely', () {
    const quickCheckout = POSOrderSaveOutboxSyncBehavior.quickCheckout;
    final kiosk = quickCheckout.copyWith(drainLimit: 4);

    expect(quickCheckout.queueTitle, 'Quick sale sync queue');
    expect(quickCheckout.retryFailedByDefault, isFalse);
    expect(quickCheckout.stalePendingAfter, const Duration(minutes: 2));
    expect(quickCheckout.staleFailedAfter, const Duration(minutes: 1));
    expect(quickCheckout.policyLabels, contains('Queued first'));
    expect(quickCheckout.policyLabels, contains('Auto after close'));
    expect(
      quickCheckout.shouldAutoSyncAfterOrderCompletion(
        pendingCount: 1,
        failedCount: 5,
        now: DateTime(2026, 5, 31, 9),
      ),
      isTrue,
    );
    expect(
      quickCheckout.shouldAutoSyncAfterOrderCompletion(
        pendingCount: 0,
        failedCount: 5,
        now: DateTime(2026, 5, 31, 9),
      ),
      isFalse,
    );
    expect(kiosk.drainLimit, 4);
    expect(kiosk.continueOnError, quickCheckout.continueOnError);
    expect(kiosk.stalePendingAfter, quickCheckout.stalePendingAfter);
  });

  test('auto sync behavior respects thresholds and cooldowns', () {
    final behavior = POSOrderSaveOutboxSyncBehavior.standard.copyWith(
      autoSyncAfterCompletion: true,
      autoSyncMinWorkCount: 2,
      autoSyncCooldown: const Duration(seconds: 30),
    );

    expect(
      behavior.shouldAutoSyncAfterOrderCompletion(
        pendingCount: 1,
        failedCount: 0,
        now: DateTime(2026, 5, 31, 9),
      ),
      isFalse,
    );
    expect(
      behavior.shouldAutoSyncAfterOrderCompletion(
        pendingCount: 2,
        failedCount: 0,
        now: DateTime(2026, 5, 31, 9, 0, 20),
        lastAutoSyncAt: DateTime(2026, 5, 31, 9),
      ),
      isFalse,
    );
    expect(
      behavior.shouldAutoSyncAfterOrderCompletion(
        pendingCount: 2,
        failedCount: 0,
        now: DateTime(2026, 5, 31, 9, 0, 31),
        lastAutoSyncAt: DateTime(2026, 5, 31, 9),
      ),
      isTrue,
    );
  });
}
