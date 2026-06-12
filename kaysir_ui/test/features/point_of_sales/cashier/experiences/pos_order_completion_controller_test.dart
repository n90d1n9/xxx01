import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_completion_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/services/api_services.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/terminal_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/repositories/order_save_outbox_repository_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/order_save_outbox_auto_sync_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/order_save_outbox_provider.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_envelope.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('completion controller reports missing active order', () async {
    final container = _container();
    addTearDown(container.dispose);

    final result =
        await container
            .read(posOrderCompletionControllerProvider)
            .completeCurrentOrder();

    expect(result.status, POSOrderCompletionStatus.noActiveOrder);
    expect(result.operatorMessage, 'No active order to complete.');
  });

  test('completion controller requires payment before closeout', () async {
    final apiService = _FakeApiService();
    final container = _container(apiService);
    addTearDown(container.dispose);
    container.read(currentOrderProvider.notifier).restoreOrder(_order());

    final result =
        await container
            .read(posOrderCompletionControllerProvider)
            .completeCurrentOrder();

    expect(result.status, POSOrderCompletionStatus.paymentRequired);
    expect(apiService.savedOrder, isNull);
    expect(container.read(currentOrderProvider), isNotNull);
  });

  test('completion controller blocks incomplete channel fulfillment', () async {
    final apiService = _FakeApiService();
    final container = _container(apiService);
    addTearDown(container.dispose);
    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'delivery_app';
    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(payments: [_payment()]));

    final result =
        await container
            .read(posOrderCompletionControllerProvider)
            .completeCurrentOrder();

    expect(result.status, POSOrderCompletionStatus.fulfillmentBlocked);
    expect(
      result.operatorMessage,
      'Add a delivery destination before closing.',
    );
    expect(apiService.savedOrder, isNull);
    expect(container.read(currentOrderProvider)?.isPaid, isTrue);
    expect(container.read(currentOrderProvider)?.fulfillment, isNull);
  });

  test('completion controller snapshots fulfillment and saves order', () async {
    final apiService = _FakeApiService();
    final container = _container(apiService);
    addTearDown(container.dispose);
    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'delivery_app';
    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(payments: [_payment()]));
    container
        .read(posOrderFulfillmentControllerProvider)
        .setDestination('Jl. Merdeka 10');

    final result =
        await container
            .read(posOrderCompletionControllerProvider)
            .completeCurrentOrder();

    expect(result.status, POSOrderCompletionStatus.completed);
    expect(result.order?.status, 'completed');
    expect(apiService.savedOrder, result.order);
    expect(
      apiService.savedOrder?.fulfillment?.commerceChannelId,
      'delivery_app',
    );
    expect(apiService.savedOrder?.fulfillment?.detailLabel, 'Jl. Merdeka 10');
    expect(container.read(currentOrderProvider), isNull);
  });

  test(
    'completion controller auto-syncs queued work for opted-in modes',
    () async {
      final apiService = _FakeApiService();
      final container = _container(apiService);
      addTearDown(container.dispose);
      final queuedEnvelope = buildPOSOrderPayloadEnvelope(
        _order(id: 'queued_order', payments: [_payment()]),
        preparedAt: DateTime(2026, 5, 30, 8),
      );

      container.read(selectedPOSExperienceIdProvider.notifier).state =
          quickCheckoutPOSExperience.id;
      container
          .read(posOrderSaveOutboxProvider.notifier)
          .enqueue(queuedEnvelope);
      container
          .read(currentOrderProvider.notifier)
          .restoreOrder(_order(id: 'current_order', payments: [_payment()]));

      final result =
          await container
              .read(posOrderCompletionControllerProvider)
              .completeCurrentOrder();
      await container
          .read(posOrderSaveOutboxAutoSyncControllerProvider)
          .lastAutoSyncFuture;

      expect(result.status, POSOrderCompletionStatus.completed);
      expect(apiService.savedEnvelopeKeys, [queuedEnvelope.idempotencyKey]);
      expect(
        container
            .read(posOrderSaveOutboxProvider)
            .entryFor(queuedEnvelope.idempotencyKey)!
            .status,
        POSOrderSaveOutboxStatus.sent,
      );
    },
  );
}

ProviderContainer _container([ApiService? apiService]) {
  return ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(apiService ?? _FakeApiService()),
      posOrderSaveOutboxRepositoryProvider.overrideWithValue(
        POSOrderSaveOutboxRepository(
          store: MemoryPOSOrderSaveOutboxSnapshotStore(),
        ),
      ),
    ],
  );
}

Order _order({String id = 'order_1', List<Payment> payments = const []}) {
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
    payments: payments,
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}

Payment _payment() {
  return Payment(
    id: 'payment_1',
    amount: 50000,
    method: 'Cash',
    timestamp: DateTime(2026, 5, 30, 9, 15),
    reference: 'REF1',
    isComplete: true,
  );
}

class _FakeApiService extends ApiService {
  Order? savedOrder;
  final savedEnvelopeKeys = <String>[];

  @override
  Future<void> saveOrder(Order order) async {
    savedOrder = order;
  }

  @override
  Future<void> saveOrderEnvelope(POSOrderPayloadEnvelope envelope) async {
    savedEnvelopeKeys.add(envelope.idempotencyKey);
  }
}
