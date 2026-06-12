import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/experiences/pos_experience_provider.dart';
import '../utils/order_save_outbox.dart';
import '../utils/order_save_outbox_auto_sync_state.dart';
import '../utils/order_save_outbox_sync.dart';
import '../utils/order_save_outbox_sync_behavior.dart';
import '../utils/order_save_outbox_sync_state.dart';
import 'order_save_outbox_provider.dart';
import 'order_save_outbox_sync_provider.dart';

typedef POSOrderSaveOutboxAutoSyncDrain =
    Future<POSOrderSaveOutboxSyncResult> Function({
      int? limit,
      bool? retryFailed,
      bool? continueOnError,
    });

final posOrderSaveOutboxAutoSyncStateProvider = StateNotifierProvider<
  POSOrderSaveOutboxAutoSyncController,
  POSOrderSaveOutboxAutoSyncState
>((ref) {
  final syncNotifier = ref.read(posOrderSaveOutboxSyncStateProvider.notifier);

  return POSOrderSaveOutboxAutoSyncController(
    readOutbox: () => ref.read(posOrderSaveOutboxProvider),
    readSyncState: () => ref.read(posOrderSaveOutboxSyncStateProvider),
    readSyncBehavior: () => ref.read(posOrderSaveOutboxSyncBehaviorProvider),
    drain: syncNotifier.drain,
  );
});

final posOrderSaveOutboxAutoSyncControllerProvider =
    Provider<POSOrderSaveOutboxAutoSyncController>((ref) {
      return ref.read(posOrderSaveOutboxAutoSyncStateProvider.notifier);
    });

class POSOrderSaveOutboxAutoSyncController
    extends StateNotifier<POSOrderSaveOutboxAutoSyncState> {
  final POSOrderSaveOutbox Function() readOutbox;
  final POSOrderSaveOutboxSyncState Function() readSyncState;
  final POSOrderSaveOutboxSyncBehavior Function() readSyncBehavior;
  final POSOrderSaveOutboxAutoSyncDrain drain;
  final DateTime Function() _clock;
  DateTime? _lastAutoSyncAt;
  Future<POSOrderSaveOutboxSyncResult>? _lastAutoSyncFuture;

  POSOrderSaveOutboxAutoSyncController({
    required this.readOutbox,
    required this.readSyncState,
    required this.readSyncBehavior,
    required this.drain,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const POSOrderSaveOutboxAutoSyncState.idle());

  DateTime? get lastAutoSyncAt => _lastAutoSyncAt;

  Future<POSOrderSaveOutboxSyncResult>? get lastAutoSyncFuture {
    return _lastAutoSyncFuture;
  }

  Future<POSOrderSaveOutboxSyncResult>? maybeSyncAfterCompletion({
    DateTime? now,
  }) {
    final timestamp = now ?? _clock();
    final syncState = readSyncState();
    if (syncState.isRunning) {
      state = POSOrderSaveOutboxAutoSyncState.skipped(
        reason: POSOrderSaveOutboxAutoSyncSkipReason.syncRunning,
        finishedAt: timestamp,
      );
      return null;
    }

    final behavior = readSyncBehavior();
    final outbox = readOutbox();
    final workCount = behavior.autoSyncWorkCount(
      pendingCount: outbox.pendingCount,
      failedCount: outbox.failedCount,
    );

    final skipReason = _skipReason(
      behavior: behavior,
      workCount: workCount,
      now: timestamp,
    );
    if (skipReason != null) {
      state = POSOrderSaveOutboxAutoSyncState.skipped(
        reason: skipReason,
        finishedAt: timestamp,
        workCount: workCount,
      );
      return null;
    }

    _lastAutoSyncAt = timestamp;
    state = POSOrderSaveOutboxAutoSyncState.running(
      startedAt: timestamp,
      workCount: workCount,
    );
    final future = drain(
      limit: behavior.drainLimit,
      retryFailed: behavior.retryFailedByDefault,
      continueOnError: behavior.continueOnError,
    );
    _lastAutoSyncFuture = future;
    unawaited(
      _observeDrain(future, startedAt: timestamp, workCount: workCount),
    );
    return future;
  }

  POSOrderSaveOutboxAutoSyncSkipReason? _skipReason({
    required POSOrderSaveOutboxSyncBehavior behavior,
    required int workCount,
    required DateTime now,
  }) {
    if (!behavior.autoSyncAfterCompletion) {
      return POSOrderSaveOutboxAutoSyncSkipReason.disabled;
    }
    if (workCount < behavior.autoSyncMinWorkCount) {
      return POSOrderSaveOutboxAutoSyncSkipReason.belowThreshold;
    }
    final lastAutoSyncAt = _lastAutoSyncAt;
    if (lastAutoSyncAt == null || behavior.autoSyncCooldown == Duration.zero) {
      return null;
    }
    if (now.difference(lastAutoSyncAt) < behavior.autoSyncCooldown) {
      return POSOrderSaveOutboxAutoSyncSkipReason.cooldown;
    }
    return null;
  }

  Future<void> _observeDrain(
    Future<POSOrderSaveOutboxSyncResult> future, {
    required DateTime startedAt,
    required int workCount,
  }) async {
    try {
      final result = await future;
      state = POSOrderSaveOutboxAutoSyncState.completed(
        result: result,
        startedAt: startedAt,
        finishedAt: _clock(),
        workCount: workCount,
      );
    } catch (error) {
      state = POSOrderSaveOutboxAutoSyncState.failed(
        error: error,
        startedAt: startedAt,
        finishedAt: _clock(),
        workCount: workCount,
      );
    }
  }
}
