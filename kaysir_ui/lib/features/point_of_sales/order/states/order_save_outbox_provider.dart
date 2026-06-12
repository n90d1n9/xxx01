import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cashier/states/terminal_provider.dart';
import '../repositories/order_save_outbox_repository_provider.dart';
import '../utils/order_payload_envelope.dart';
import '../utils/order_save_outbox.dart';
import '../utils/order_save_outbox_summary.dart';
import '../utils/order_save_outbox_sync.dart';

final posOrderSaveOutboxProvider =
    StateNotifierProvider<POSOrderSaveOutboxNotifier, POSOrderSaveOutbox>((
      ref,
    ) {
      final repository = ref.watch(posOrderSaveOutboxRepositoryProvider);
      return POSOrderSaveOutboxNotifier(repository: repository);
    });

final posOrderSaveOutboxHydrationProvider = FutureProvider<void>((ref) {
  return ref.read(posOrderSaveOutboxProvider.notifier).hydrate();
});

final posOrderSaveOutboxHasWorkProvider = Provider<bool>((ref) {
  return ref.watch(posOrderSaveOutboxProvider).hasUnsentWork;
});

final posOrderSaveOutboxSummaryProvider = Provider<POSOrderSaveOutboxSummary>((
  ref,
) {
  return POSOrderSaveOutboxSummary.fromOutbox(
    ref.watch(posOrderSaveOutboxProvider),
  );
});

final posOrderSaveOutboxSyncControllerProvider =
    Provider<POSOrderSaveOutboxSyncController>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      final outbox = ref.read(posOrderSaveOutboxProvider.notifier);

      return POSOrderSaveOutboxSyncController(
        outbox: outbox,
        sender: apiService.saveOrderEnvelope,
      );
    });

class POSOrderSaveOutboxNotifier extends StateNotifier<POSOrderSaveOutbox>
    implements POSOrderSaveOutboxSyncPort {
  final POSOrderSaveOutboxRepository? _repository;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  var _hasLocalMutations = false;

  POSOrderSaveOutboxNotifier({POSOrderSaveOutboxRepository? repository})
    : _repository = repository,
      super(const POSOrderSaveOutbox.empty());

  @override
  POSOrderSaveOutbox get snapshot => state;

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromRepository();
  }

  Future<void> flushPersistence() {
    return _persistFuture ?? Future<void>.value();
  }

  void enqueue(POSOrderPayloadEnvelope envelope, {DateTime? queuedAt}) {
    _setAndPersist(state.enqueue(envelope, queuedAt: queuedAt));
  }

  @override
  void markSending(String idempotencyKey, {DateTime? attemptedAt}) {
    _setAndPersist(state.markSending(idempotencyKey, attemptedAt: attemptedAt));
  }

  @override
  void markSent(String idempotencyKey, {DateTime? sentAt}) {
    _setAndPersist(state.markSent(idempotencyKey, sentAt: sentAt));
  }

  @override
  void markFailed(String idempotencyKey, Object error, {DateTime? failedAt}) {
    _setAndPersist(state.markFailed(idempotencyKey, error, failedAt: failedAt));
  }

  @override
  void retryFailed(String idempotencyKey) {
    _setAndPersist(state.retryFailed(idempotencyKey));
  }

  void retryFailedEntries(Iterable<String> idempotencyKeys) {
    _setAndPersist(state.retryFailedEntries(idempotencyKeys));
  }

  void retryAllFailed() {
    _setAndPersist(state.retryAllFailed());
  }

  void remove(String idempotencyKey) {
    _setAndPersist(state.remove(idempotencyKey));
  }

  void clearSent() {
    _setAndPersist(state.clearSent());
  }

  Future<void> _hydrateFromRepository() async {
    final repository = _repository;
    if (repository == null) return;

    final restored = await repository.load();
    if (_hasLocalMutations) {
      await _queuePersist();
      return;
    }

    state = restored;
  }

  void _setAndPersist(POSOrderSaveOutbox nextState) {
    if (identical(nextState, state)) return;

    state = nextState;
    _hasLocalMutations = true;
    unawaited(_queuePersist());
  }

  Future<void> _queuePersist() {
    final repository = _repository;
    if (repository == null) return Future<void>.value();

    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    final snapshot = state;
    return _persistFuture = pending.then((_) => repository.save(snapshot));
  }
}
