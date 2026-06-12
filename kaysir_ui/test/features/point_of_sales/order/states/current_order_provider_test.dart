import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_cart_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/services/api_services.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/terminal_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/repositories/order_save_outbox_repository_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/order_save_outbox_provider.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_save_outbox.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/point_of_sales/promotion/models/promotion.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'completeOrder returns completed order and clears active order',
    () async {
      final apiService = _FakeApiService();
      final container = _container(apiService);
      addTearDown(container.dispose);

      final terminal = Terminal(
        id: 'terminal_1',
        name: 'Terminal 1',
        location: 'Front counter',
        isActive: true,
      );
      final product = Product(id: 'coffee', name: 'Coffee', price: 25000);

      final notifier = container.read(currentOrderProvider.notifier);
      notifier.createNewOrder(terminal);
      notifier.addItem(product, 2);
      notifier.addPayment(
        Payment(
          id: 'payment_1',
          amount: 50000,
          method: 'Cash',
          timestamp: DateTime(2026, 5, 30, 10, 30),
          reference: 'REF1',
          isComplete: true,
        ),
      );

      final completedOrder = await notifier.completeOrder();

      expect(completedOrder, isNotNull);
      expect(completedOrder!.status, 'completed');
      expect(completedOrder.total, 50000);
      expect(apiService.savedOrder, completedOrder);
      final outbox = container.read(posOrderSaveOutboxProvider);
      expect(outbox.entries, hasLength(1));
      expect(outbox.entries.single.status, POSOrderSaveOutboxStatus.sent);
      expect(outbox.entries.single.attempts, 1);
      expect(container.read(currentOrderProvider), isNull);
    },
  );

  test(
    'completeOrder preserves fulfillment snapshot for saved order',
    () async {
      final apiService = _FakeApiService();
      final container = _container(apiService);
      addTearDown(container.dispose);

      final terminal = Terminal(
        id: 'terminal_1',
        name: 'Terminal 1',
        location: 'Front counter',
        isActive: true,
      );
      final product = Product(id: 'coffee', name: 'Coffee', price: 25000);
      const fulfillment = OrderFulfillmentSnapshot(
        commerceChannelId: 'delivery_app',
        commerceChannelLabel: 'Delivery app',
        fulfillmentModeKey: 'delivery',
        fulfillmentModeLabel: 'Delivery',
        destination: 'Jl. Merdeka 10',
        statusLabel: 'Delivery ready',
        summaryLabel: 'Jl. Merdeka 10',
      );

      final notifier = container.read(currentOrderProvider.notifier);
      notifier.createNewOrder(terminal);
      notifier.addItem(product, 2);
      notifier.setFulfillment(fulfillment);
      notifier.addPayment(
        Payment(
          id: 'payment_1',
          amount: 50000,
          method: 'Cash',
          timestamp: DateTime(2026, 5, 30, 10, 30),
          reference: 'REF1',
          isComplete: true,
        ),
      );

      final completedOrder = await notifier.completeOrder();

      expect(completedOrder?.fulfillment, fulfillment);
      expect(
        apiService.savedOrder?.fulfillment?.commerceChannelId,
        'delivery_app',
      );
      expect(apiService.savedOrder?.fulfillment?.detailLabel, 'Jl. Merdeka 10');
    },
  );

  test(
    'completeOrder records failed saves and retries the same order',
    () async {
      final apiService = _ToggleFailApiService(failNextSave: true);
      final container = _container(apiService);
      addTearDown(container.dispose);

      final terminal = Terminal(
        id: 'terminal_1',
        name: 'Terminal 1',
        location: 'Front counter',
        isActive: true,
      );
      final product = Product(id: 'coffee', name: 'Coffee', price: 25000);

      final notifier = container.read(currentOrderProvider.notifier);
      notifier.createNewOrder(terminal);
      notifier.addItem(product, 2);
      notifier.addPayment(
        Payment(
          id: 'payment_1',
          amount: 50000,
          method: 'Cash',
          timestamp: DateTime(2026, 5, 30, 10, 30),
          reference: 'REF1',
          isComplete: true,
        ),
      );

      final failedOrder = await notifier.completeOrder();
      var outbox = container.read(posOrderSaveOutboxProvider);

      expect(failedOrder, isNull);
      expect(container.read(currentOrderProvider), isNotNull);
      expect(outbox.entries.single.status, POSOrderSaveOutboxStatus.failed);
      expect(outbox.entries.single.attempts, 1);
      expect(outbox.entries.single.lastError, contains('offline'));

      apiService.failNextSave = false;
      final completedOrder = await notifier.completeOrder();
      outbox = container.read(posOrderSaveOutboxProvider);

      expect(completedOrder, isNotNull);
      expect(container.read(currentOrderProvider), isNull);
      expect(outbox.entries.single.status, POSOrderSaveOutboxStatus.sent);
      expect(outbox.entries.single.attempts, 2);
    },
  );

  test('applyPromotion ignores duplicate promotion ids', () {
    final container = _container(_FakeApiService());
    addTearDown(container.dispose);

    final terminal = Terminal(
      id: 'terminal_1',
      name: 'Terminal 1',
      location: 'Front counter',
      isActive: true,
    );
    final promotion = Promotion(
      id: 'promo_1',
      name: 'Welcome',
      code: 'WELCOME',
      discountPercentage: 10,
      discountAmount: 0,
      isActive: true,
      validUntil: DateTime(2026, 6, 30),
    );

    final notifier = container.read(currentOrderProvider.notifier);
    notifier.createNewOrder(terminal);
    notifier.applyPromotion(promotion);
    notifier.applyPromotion(promotion);

    expect(container.read(currentOrderProvider)!.appliedPromotions, [
      promotion,
    ]);
  });

  test('addItem can keep repeated service selections as separate lines', () {
    final container = _container(_FakeApiService());
    addTearDown(container.dispose);

    final terminal = Terminal(
      id: 'terminal_1',
      name: 'Terminal 1',
      location: 'Front counter',
      isActive: true,
    );
    final product = Product(
      id: 'consultation',
      name: 'Consultation',
      price: 50000,
    );

    final notifier = container.read(currentOrderProvider.notifier);
    notifier.createNewOrder(terminal);
    notifier.addItem(product, 1, cartBehavior: POSCartBehavior.assistedService);
    notifier.addItem(product, 1, cartBehavior: POSCartBehavior.assistedService);

    final order = container.read(currentOrderProvider)!;
    expect(order.items, hasLength(2));
    expect(order.items.map((item) => item.quantity), [1, 1]);
  });

  test('cart behavior caps added and updated quantities', () {
    final container = _container(_FakeApiService());
    addTearDown(container.dispose);

    const stockLimitedCart = POSCartBehavior(
      limitQuantityToAvailableStock: true,
    );
    final terminal = Terminal(
      id: 'terminal_1',
      name: 'Terminal 1',
      location: 'Front counter',
      isActive: true,
    );
    final product = Product(
      id: 'rice',
      name: 'Rice',
      price: 75000,
      stockQuantity: 2,
    );

    final notifier = container.read(currentOrderProvider.notifier);
    notifier.createNewOrder(terminal);
    notifier.addItem(product, 5, cartBehavior: stockLimitedCart);

    var order = container.read(currentOrderProvider)!;
    expect(order.items.single.quantity, 2);

    notifier.updateItemQuantity(
      order.items.single.id,
      9,
      cartBehavior: stockLimitedCart,
    );

    order = container.read(currentOrderProvider)!;
    expect(order.items.single.quantity, 2);
  });
}

ProviderContainer _container(ApiService apiService) {
  return ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(apiService),
      posOrderSaveOutboxRepositoryProvider.overrideWithValue(
        POSOrderSaveOutboxRepository(
          store: MemoryPOSOrderSaveOutboxSnapshotStore(),
        ),
      ),
    ],
  );
}

class _FakeApiService extends ApiService {
  Order? savedOrder;

  @override
  Future<void> saveOrder(Order order) async {
    savedOrder = order;
  }
}

class _ToggleFailApiService extends ApiService {
  bool failNextSave;

  _ToggleFailApiService({required this.failNextSave});

  @override
  Future<void> saveOrder(Order order) async {
    if (failNextSave) {
      throw StateError('offline');
    }
  }
}
