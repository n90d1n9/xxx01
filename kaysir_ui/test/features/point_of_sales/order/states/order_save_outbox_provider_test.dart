import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/services/api_services.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/terminal_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/repositories/order_save_outbox_repository_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/order_save_outbox_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/order_save_outbox_sync_provider.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_summary.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox_sync_state.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('provider exposes queue lifecycle and work summary', () async {
    final container = _container();
    addTearDown(container.dispose);

    final envelope = _envelope();

    expect(container.read(posOrderSaveOutboxHasWorkProvider), isFalse);

    final notifier = container.read(posOrderSaveOutboxProvider.notifier);
    notifier.enqueue(envelope, queuedAt: DateTime(2026, 5, 30, 11));
    notifier.markSending(
      envelope.idempotencyKey,
      attemptedAt: DateTime(2026, 5, 30, 11, 1),
    );
    notifier.markFailed(
      envelope.idempotencyKey,
      'No network',
      failedAt: DateTime(2026, 5, 30, 11, 2),
    );

    var outbox = container.read(posOrderSaveOutboxProvider);
    expect(container.read(posOrderSaveOutboxHasWorkProvider), isTrue);
    expect(outbox.failedCount, 1);
    expect(outbox.entries.single.lastError, 'No network');
    expect(
      container.read(posOrderSaveOutboxSummaryProvider).health,
      POSOrderSaveOutboxHealth.failed,
    );

    notifier.retryFailed(envelope.idempotencyKey);
    outbox = container.read(posOrderSaveOutboxProvider);
    expect(outbox.entries.single.status, POSOrderSaveOutboxStatus.pending);
    expect(
      container.read(posOrderSaveOutboxSummaryProvider).health,
      POSOrderSaveOutboxHealth.queued,
    );

    notifier.markSending(envelope.idempotencyKey);
    notifier.markSent(envelope.idempotencyKey);
    expect(container.read(posOrderSaveOutboxHasWorkProvider), isFalse);

    notifier.clearSent();
    await notifier.flushPersistence();
    expect(container.read(posOrderSaveOutboxProvider).entries, isEmpty);
  });

  test('provider batch retries failed saves and persists once', () async {
    final store = MemoryPOSOrderSaveOutboxSnapshotStore();
    final repository = POSOrderSaveOutboxRepository(store: store);
    final container = _container(repository: repository);
    addTearDown(container.dispose);
    final failed = _envelope('order_failed');
    final otherFailed = _envelope('order_other_failed');

    final notifier = container.read(posOrderSaveOutboxProvider.notifier);
    notifier.enqueue(failed);
    notifier.markSending(failed.idempotencyKey);
    notifier.markFailed(failed.idempotencyKey, 'offline');
    notifier.enqueue(otherFailed);
    notifier.markSending(otherFailed.idempotencyKey);
    notifier.markFailed(otherFailed.idempotencyKey, 'timeout');

    notifier.retryFailedEntries([failed.idempotencyKey]);
    await notifier.flushPersistence();

    final outbox = container.read(posOrderSaveOutboxProvider);
    expect(
      outbox.entryFor(failed.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.pending,
    );
    expect(
      outbox.entryFor(otherFailed.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.failed,
    );

    final restored = await repository.load();
    expect(
      restored.entryFor(failed.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.pending,
    );
    expect(
      restored.entryFor(otherFailed.idempotencyKey)!.status,
      POSOrderSaveOutboxStatus.failed,
    );
  });

  test('provider hydrates a persisted outbox snapshot', () async {
    final store = MemoryPOSOrderSaveOutboxSnapshotStore();
    final repository = POSOrderSaveOutboxRepository(store: store);
    final envelope = _envelope();

    await repository.save(
      POSOrderSaveOutbox().enqueue(
        envelope,
        queuedAt: DateTime(2026, 5, 30, 11),
      ),
    );

    final container = _container(repository: repository);
    addTearDown(container.dispose);

    await container.read(posOrderSaveOutboxProvider.notifier).hydrate();

    final outbox = container.read(posOrderSaveOutboxProvider);
    expect(outbox.entries, hasLength(1));
    expect(
      outbox.entries.single.envelope.idempotencyKey,
      envelope.idempotencyKey,
    );
  });

  test('provider persists queue mutations through the repository', () async {
    final store = MemoryPOSOrderSaveOutboxSnapshotStore();
    final repository = POSOrderSaveOutboxRepository(store: store);
    final container = _container(repository: repository);
    addTearDown(container.dispose);
    final envelope = _envelope();

    final notifier = container.read(posOrderSaveOutboxProvider.notifier);
    notifier.enqueue(envelope, queuedAt: DateTime(2026, 5, 30, 11));
    notifier.markSending(
      envelope.idempotencyKey,
      attemptedAt: DateTime(2026, 5, 30, 11, 1),
    );
    await notifier.flushPersistence();

    final restored = await repository.load();
    expect(restored.entries, hasLength(1));
    expect(restored.entries.single.status, POSOrderSaveOutboxStatus.pending);
    expect(restored.entries.single.attempts, 1);
    expect(restored.activity.map((event) => event.type.name), [
      'queued',
      'sending',
    ]);
  });

  test(
    'sync controller provider submits queued envelopes through ApiService',
    () async {
      final apiService = _FakeApiService();
      final container = _container(apiService: apiService);
      addTearDown(container.dispose);

      final envelope = _envelope();

      container.read(posOrderSaveOutboxProvider.notifier).enqueue(envelope);

      final result =
          await container
              .read(posOrderSaveOutboxSyncControllerProvider)
              .drain();

      expect(result.sent, 1);
      expect(apiService.savedEnvelopeKeys, [envelope.idempotencyKey]);
      expect(
        container.read(posOrderSaveOutboxProvider).entries.single.status,
        POSOrderSaveOutboxStatus.sent,
      );
    },
  );

  test('sync state provider prevents concurrent outbox drains', () async {
    final apiService = _BlockingApiService();
    final container = _container(apiService: apiService);
    addTearDown(container.dispose);

    final envelope = _envelope();
    container.read(posOrderSaveOutboxProvider.notifier).enqueue(envelope);

    final notifier = container.read(
      posOrderSaveOutboxSyncStateProvider.notifier,
    );
    final firstDrain = notifier.drain();
    final secondDrain = notifier.drain();

    expect(container.read(posOrderSaveOutboxSyncStateProvider).isRunning, true);
    await apiService.waitForStart();
    expect(apiService.startedCount, 1);

    apiService.complete();
    final results = await Future.wait([firstDrain, secondDrain]);

    expect(results.first.sent, 1);
    expect(results.last.sent, 1);
    expect(apiService.savedEnvelopeKeys, [envelope.idempotencyKey]);
    expect(
      container.read(posOrderSaveOutboxSyncStateProvider).phase,
      POSOrderSaveOutboxSyncPhase.completed,
    );
  });

  test('sync state provider records failed drain results', () async {
    final apiService = _FailingApiService();
    final container = _container(apiService: apiService);
    addTearDown(container.dispose);

    final envelope = _envelope();
    container.read(posOrderSaveOutboxProvider.notifier).enqueue(envelope);

    final result =
        await container
            .read(posOrderSaveOutboxSyncStateProvider.notifier)
            .drain();
    final state = container.read(posOrderSaveOutboxSyncStateProvider);

    expect(result.failed, 1);
    expect(state.phase, POSOrderSaveOutboxSyncPhase.completed);
    expect(state.hasFailures, true);
    expect(state.lastResult, result);
  });

  test(
    'sync state provider applies the selected POS mode sync behavior',
    () async {
      final apiService = _FakeApiService();
      final container = _container(apiService: apiService);
      addTearDown(container.dispose);

      container.read(selectedPOSExperienceIdProvider.notifier).state =
          quickCheckoutPOSExperience.id;

      final failed = _envelope('order_failed');
      final queued = _envelope('order_queued');
      final outbox = container.read(posOrderSaveOutboxProvider.notifier);
      outbox.enqueue(failed);
      outbox.markSending(failed.idempotencyKey);
      outbox.markFailed(failed.idempotencyKey, 'offline');
      outbox.enqueue(queued);

      final result =
          await container
              .read(posOrderSaveOutboxSyncStateProvider.notifier)
              .drain();

      expect(apiService.savedEnvelopeKeys, [queued.idempotencyKey]);
      expect(result.sent, 1);
      expect(result.remainingFailed, 1);
      expect(
        container
            .read(posOrderSaveOutboxProvider)
            .entryFor(failed.idempotencyKey)!
            .status,
        POSOrderSaveOutboxStatus.failed,
      );
    },
  );
}

ProviderContainer _container({
  ApiService? apiService,
  POSOrderSaveOutboxRepository? repository,
}) {
  return ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(apiService ?? _FakeApiService()),
      posOrderSaveOutboxRepositoryProvider.overrideWithValue(
        repository ??
            POSOrderSaveOutboxRepository(
              store: MemoryPOSOrderSaveOutboxSnapshotStore(),
            ),
      ),
    ],
  );
}

POSOrderPayloadEnvelope _envelope([String orderId = 'order_1']) {
  return buildPOSOrderPayloadEnvelope(
    _order(orderId),
    preparedAt: DateTime(2026, 5, 30, 10, 45),
  );
}

class _FakeApiService extends ApiService {
  final savedEnvelopeKeys = <String>[];

  @override
  Future<void> saveOrderEnvelope(POSOrderPayloadEnvelope envelope) async {
    savedEnvelopeKeys.add(envelope.idempotencyKey);
  }
}

class _BlockingApiService extends _FakeApiService {
  final Completer<void> _started = Completer<void>();
  final Completer<void> _release = Completer<void>();
  int startedCount = 0;

  Future<void> waitForStart() => _started.future;

  void complete() {
    if (!_release.isCompleted) _release.complete();
  }

  @override
  Future<void> saveOrderEnvelope(POSOrderPayloadEnvelope envelope) async {
    startedCount++;
    if (!_started.isCompleted) _started.complete();
    await _release.future;
    await super.saveOrderEnvelope(envelope);
  }
}

class _FailingApiService extends ApiService {
  @override
  Future<void> saveOrderEnvelope(POSOrderPayloadEnvelope envelope) async {
    throw StateError('offline');
  }
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
        timestamp: DateTime(2026, 5, 30, 9, 15),
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
    createdAt: DateTime.utc(2026, 5, 30, 2),
    status: 'completed',
  );
}
