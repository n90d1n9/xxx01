import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_error_copy.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';

void main() {
  test('operator message reports successful sync results', () {
    final state = POSOrderSaveOutboxSyncState.completed(
      result: const POSOrderSaveOutboxSyncResult(
        submitted: 2,
        sent: 2,
        failed: 0,
        skipped: 0,
        remainingPending: 0,
        remainingFailed: 0,
      ),
      startedAt: _startedAt,
      finishedAt: _finishedAt,
    );

    expect(state.operatorMessage, '2 orders synced');
    expect(state.hasFailures, isFalse);
  });

  test('operator message reports failed sync results', () {
    final state = POSOrderSaveOutboxSyncState.completed(
      result: const POSOrderSaveOutboxSyncResult(
        submitted: 2,
        sent: 1,
        failed: 1,
        skipped: 0,
        remainingPending: 0,
        remainingFailed: 1,
      ),
      startedAt: _startedAt,
      finishedAt: _finishedAt,
    );

    expect(state.operatorMessage, 'Order sync needs attention: 1 failed');
    expect(state.hasFailures, isTrue);
  });

  test('operator message reports thrown sync failures', () {
    final state = POSOrderSaveOutboxSyncState.failed(
      error: StateError('offline'),
      startedAt: _startedAt,
      finishedAt: _finishedAt,
    );

    expect(
      state.operatorMessage,
      contains('Unable to sync queued orders: Bad state: offline'),
    );
    expect(state.hasFailures, isTrue);
  });

  test('operator message hides raw Dio sync failures', () {
    final state = POSOrderSaveOutboxSyncState.failed(
      error: DioException(
        requestOptions: RequestOptions(path: '/orders/sync'),
        type: DioExceptionType.connectionError,
      ),
      startedAt: _startedAt,
      finishedAt: _finishedAt,
    );

    expect(state.lastError, posOrderSyncFailureMessage);
    expect(state.operatorMessage, contains(posOrderSyncFailureMessage));
    expect(state.operatorMessage, isNot(contains('DioException')));
    expect(state.operatorMessage, isNot(contains('API server')));
  });
}

final _startedAt = DateTime(2026, 5, 31, 8);
final _finishedAt = DateTime(2026, 5, 31, 8, 1);
