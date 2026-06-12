import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_browser_state.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_display.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('initial browser filter prioritizes failed work', () {
    expect(
      initialPOSOrderSaveOutboxBrowserFilter(
        const POSOrderSaveOutboxSummary.empty(),
      ),
      POSOrderSaveOutboxViewFilter.all,
    );
    expect(
      initialPOSOrderSaveOutboxBrowserFilter(
        const POSOrderSaveOutboxSummary(
          health: POSOrderSaveOutboxHealth.failed,
          pendingCount: 1,
          sendingCount: 0,
          failedCount: 1,
          sentCount: 0,
          totalCount: 2,
        ),
      ),
      POSOrderSaveOutboxViewFilter.attention,
    );
  });

  test('browser state resolves sorted entries, counts, and retryable rows', () {
    final failed = _envelope('order_123456');
    final queued = _envelope('order_222222');
    final sent = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(sent, queuedAt: DateTime(2026, 5, 31, 9, 5))
        .markSending(sent.idempotencyKey)
        .markSent(sent.idempotencyKey)
        .enqueue(queued, queuedAt: DateTime(2026, 5, 31, 9, 1))
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down');

    final state = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.all,
    );

    expect(state.sortedEntries.map((entry) => entry.idempotencyKey), [
      failed.idempotencyKey,
      queued.idempotencyKey,
      sent.idempotencyKey,
    ]);
    expect(state.countFor(POSOrderSaveOutboxViewFilter.attention), 1);
    expect(state.countFor(POSOrderSaveOutboxViewFilter.queued), 1);
    expect(state.countFor(POSOrderSaveOutboxViewFilter.synced), 1);
    expect(state.retryableEntries.map((entry) => entry.idempotencyKey), [
      failed.idempotencyKey,
    ]);
    expect(state.labelFor(POSOrderSaveOutboxViewFilter.all), 'All (3)');
  });

  test('browser state applies query and empty copy', () {
    final failed = _envelope('order_123456');
    final sent = _envelope('order_654321');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down')
        .enqueue(sent, queuedAt: DateTime(2026, 5, 31, 9, 5))
        .markSending(sent.idempotencyKey)
        .markSent(sent.idempotencyKey);

    final matchingState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.attention,
      query: 'network',
    );
    final crossFilterMatchState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.attention,
      query: '654321',
    );
    final emptySearchState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.attention,
      query: 'missing',
    );
    final emptyFilterState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.queued,
    );

    expect(matchingState.entries, hasLength(1));
    expect(matchingState.countFor(POSOrderSaveOutboxViewFilter.attention), 1);
    expect(matchingState.countFor(POSOrderSaveOutboxViewFilter.synced), 0);
    expect(matchingState.labelFor(POSOrderSaveOutboxViewFilter.all), 'All (1)');
    expect(matchingState.shouldShowSearchSummary, isTrue);
    expect(matchingState.searchSummaryTitle, '1 matching save');
    expect(
      matchingState.searchSummaryMessage,
      'Searching "network" in Attention. Clear search to return to 1 save.',
    );
    expect(matchingState.searchSummaryActionLabel, 'Clear');
    expect(crossFilterMatchState.entries, isEmpty);
    expect(
      crossFilterMatchState.searchRecoveryFilter,
      POSOrderSaveOutboxViewFilter.synced,
    );
    expect(crossFilterMatchState.hasSearchRecoveryAction, isTrue);
    expect(crossFilterMatchState.searchRecoveryActionLabel, 'Show Synced');
    expect(
      crossFilterMatchState.searchSummaryMessage,
      'No results in Attention. 1 matching save available in Synced.',
    );
    expect(emptySearchState.entries, isEmpty);
    expect(emptySearchState.searchRecoveryFilter, isNull);
    expect(emptySearchState.hasSearchRecoveryAction, isFalse);
    expect(emptySearchState.searchSummaryTitle, 'No matching saves');
    expect(
      emptySearchState.searchSummaryMessage,
      'Searching "missing" in Attention. Clear search to return to 1 save.',
    );
    expect(emptySearchState.emptyTitle, 'No matching order saves');
    expect(
      emptySearchState.emptyMessage,
      'Try a different order, terminal, status, or error term.',
    );
    expect(emptyFilterState.shouldShowSearchSummary, isFalse);
    expect(emptyFilterState.emptyTitle, 'No queued order saves');
    expect(
      emptyFilterState.emptyMessage,
      'Completed orders waiting to sync will appear here.',
    );
  });

  test('browser state reports failed saves hidden by filter or search', () {
    final failed = _envelope('order_123456');
    final otherFailed = _envelope('order_999999');
    final queued = _envelope('order_222222');
    final outbox = POSOrderSaveOutbox()
        .enqueue(failed, queuedAt: DateTime(2026, 5, 31, 9))
        .markSending(failed.idempotencyKey)
        .markFailed(failed.idempotencyKey, 'Network down')
        .enqueue(otherFailed, queuedAt: DateTime(2026, 5, 31, 9, 1))
        .markSending(otherFailed.idempotencyKey)
        .markFailed(otherFailed.idempotencyKey, 'Timeout')
        .enqueue(queued, queuedAt: DateTime(2026, 5, 31, 9, 2));

    final queuedState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.queued,
    );
    final searchedQueuedState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.queued,
      query: 'network',
    );
    final searchedAttentionState = POSOrderSaveOutboxBrowserState.resolve(
      outbox: outbox,
      filter: POSOrderSaveOutboxViewFilter.attention,
      query: '123456',
    );

    expect(queuedState.hiddenRetryableCount, 2);
    expect(queuedState.hiddenRetryableTitle, '2 failed saves hidden');
    expect(queuedState.hiddenRetryableMessage, contains('Switch to Attention'));
    expect(queuedState.hiddenRetryableActionLabel, 'Show failed');
    expect(queuedState.shouldPreserveSearchForHiddenRetryableAction, isFalse);
    expect(searchedQueuedState.hiddenRetryableCount, 2);
    expect(searchedQueuedState.matchingHiddenRetryableCount, 1);
    expect(
      searchedQueuedState.hiddenRetryableTitle,
      '1 matching failed save hidden',
    );
    expect(
      searchedQueuedState.hiddenRetryableMessage,
      'Switch to Attention to see failed saves matching this search.',
    );
    expect(
      searchedQueuedState.hiddenRetryableActionLabel,
      'Show matching failed',
    );
    expect(
      searchedQueuedState.shouldPreserveSearchForHiddenRetryableAction,
      isTrue,
    );
    expect(searchedAttentionState.hiddenRetryableCount, 1);
    expect(searchedAttentionState.matchingHiddenRetryableCount, 0);
    expect(
      searchedAttentionState.hiddenRetryableMessage,
      'Clear or change the search to see all failed saves.',
    );
    expect(searchedAttentionState.hiddenRetryableActionLabel, 'Clear search');
    expect(
      searchedAttentionState.shouldPreserveSearchForHiddenRetryableAction,
      isFalse,
    );
  });
}

POSOrderPayloadEnvelope _envelope(String orderId) {
  return buildPOSOrderPayloadEnvelope(
    _order(orderId),
    preparedAt: DateTime(2026, 5, 31, 8, 45),
  );
}

Order _order(String orderId) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: orderId,
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
      name: 'Front Desk',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime.utc(2026, 5, 31, 1),
    status: 'completed',
  );
}
