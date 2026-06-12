import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/experiences/pos_experience_provider.dart';
import '../utils/order_save_outbox_sync.dart';
import '../utils/order_save_outbox_sync_behavior.dart';
import '../utils/order_save_outbox_sync_state.dart';
import 'order_save_outbox_provider.dart';

final posOrderSaveOutboxSyncStateProvider = StateNotifierProvider<
  POSOrderSaveOutboxSyncNotifier,
  POSOrderSaveOutboxSyncState
>((ref) {
  return POSOrderSaveOutboxSyncNotifier(
    controller: ref.watch(posOrderSaveOutboxSyncControllerProvider),
    outbox: ref.read(posOrderSaveOutboxProvider.notifier),
    syncBehavior: ref.watch(posOrderSaveOutboxSyncBehaviorProvider),
  );
});

class POSOrderSaveOutboxSyncNotifier
    extends StateNotifier<POSOrderSaveOutboxSyncState> {
  final POSOrderSaveOutboxSyncController _controller;
  final POSOrderSaveOutboxNotifier _outbox;
  final POSOrderSaveOutboxSyncBehavior _syncBehavior;
  final DateTime Function() _clock;
  Future<POSOrderSaveOutboxSyncResult>? _activeDrain;

  POSOrderSaveOutboxSyncNotifier({
    required POSOrderSaveOutboxSyncController controller,
    required POSOrderSaveOutboxNotifier outbox,
    POSOrderSaveOutboxSyncBehavior syncBehavior =
        POSOrderSaveOutboxSyncBehavior.standard,
    DateTime Function()? clock,
  }) : _controller = controller,
       _outbox = outbox,
       _syncBehavior = syncBehavior,
       _clock = clock ?? DateTime.now,
       super(const POSOrderSaveOutboxSyncState.idle());

  Future<POSOrderSaveOutboxSyncResult> drain({
    int? limit,
    bool? retryFailed,
    bool? continueOnError,
  }) {
    final activeDrain = _activeDrain;
    if (activeDrain != null) return activeDrain;

    final startedAt = _clock();
    final resolvedLimit = limit ?? _syncBehavior.drainLimit;
    final resolvedRetryFailed =
        retryFailed ?? _syncBehavior.retryFailedByDefault;
    final resolvedContinueOnError =
        continueOnError ?? _syncBehavior.continueOnError;
    state = POSOrderSaveOutboxSyncState.running(startedAt: startedAt);

    final drain = _drain(
      startedAt: startedAt,
      limit: resolvedLimit,
      retryFailed: resolvedRetryFailed,
      continueOnError: resolvedContinueOnError,
    );
    _activeDrain = drain;
    drain.whenComplete(() {
      if (identical(_activeDrain, drain)) {
        _activeDrain = null;
      }
    });
    return drain;
  }

  Future<POSOrderSaveOutboxSyncResult> _drain({
    required DateTime startedAt,
    required int limit,
    required bool retryFailed,
    required bool continueOnError,
  }) async {
    try {
      final result = await _controller.drain(
        limit: limit,
        retryFailed: retryFailed,
        continueOnError: continueOnError,
      );
      await _outbox.flushPersistence();
      state = POSOrderSaveOutboxSyncState.completed(
        result: result,
        startedAt: startedAt,
        finishedAt: _clock(),
      );
      return result;
    } catch (error, stackTrace) {
      state = POSOrderSaveOutboxSyncState.failed(
        error: error,
        startedAt: startedAt,
        finishedAt: _clock(),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
