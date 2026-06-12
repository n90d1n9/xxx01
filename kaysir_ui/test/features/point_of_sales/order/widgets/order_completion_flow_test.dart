import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_checkout_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/services/api_services.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/terminal_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/repositories/order_save_outbox_repository_provider.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/order_completion_flow.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('completion flow presents fulfillment failures', (tester) async {
    final apiService = _FakeApiService();
    final container = _container(apiService);
    addTearDown(container.dispose);
    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'delivery_app';
    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(payments: [_payment()]));

    await _pumpCompletionButton(tester, container);
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();

    expect(
      find.text('Add a delivery destination before closing.'),
      findsOneWidget,
    );
    expect(apiService.savedOrder, isNull);
    expect(container.read(currentOrderProvider)?.fulfillment, isNull);
  });

  testWidgets('completion flow can start a new order and show success', (
    tester,
  ) async {
    final apiService = _FakeApiService();
    final container = _container(apiService, quickCheckout: true);
    addTearDown(container.dispose);
    container
        .read(currentOrderProvider.notifier)
        .restoreOrder(_order(payments: [_payment()]));

    await _pumpCompletionButton(
      tester,
      container,
      successMessage: 'Quick checkout completed.',
    );
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();

    final activeOrder = container.read(currentOrderProvider);

    expect(apiService.savedOrder?.status, 'completed');
    expect(apiService.savedOrder?.fulfillment?.commerceChannelId, 'in_store');
    expect(activeOrder, isNotNull);
    expect(activeOrder!.items, isEmpty);
    expect(activeOrder.id, startsWith('temp_'));
    expect(find.text('Quick checkout completed.'), findsOneWidget);
  });
}

Future<void> _pumpCompletionButton(
  WidgetTester tester,
  ProviderContainer container, {
  String? successMessage,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder:
                (context, ref, _) => FilledButton(
                  onPressed:
                      () => completeAndPresentPOSOrder(
                        context: context,
                        ref: ref,
                        successMessage: successMessage,
                      ),
                  child: const Text('Complete'),
                ),
          ),
        ),
      ),
    ),
  );
}

ProviderContainer _container(
  ApiService apiService, {
  bool quickCheckout = false,
}) {
  final overrides = [
    apiServiceProvider.overrideWithValue(apiService),
    posOrderSaveOutboxRepositoryProvider.overrideWithValue(
      POSOrderSaveOutboxRepository(
        store: MemoryPOSOrderSaveOutboxSnapshotStore(),
      ),
    ),
    if (quickCheckout)
      posCheckoutBehaviorProvider.overrideWithValue(
        POSCheckoutBehavior.quickCheckout,
      ),
  ];

  return ProviderContainer(overrides: overrides);
}

Order _order({List<Payment> payments = const []}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
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

  @override
  Future<void> saveOrder(Order order) async {
    savedOrder = order;
  }
}
