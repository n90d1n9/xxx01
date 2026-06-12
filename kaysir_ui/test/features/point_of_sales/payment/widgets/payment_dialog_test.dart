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
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/point_of_sales/payment/widgets/payment_dialog.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('PaymentDialog auto-complete respects fulfillment readiness', (
    tester,
  ) async {
    final apiService = _FakeApiService();
    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(apiService),
        posCheckoutBehaviorProvider.overrideWithValue(
          POSCheckoutBehavior.quickCheckout,
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(selectedPOSCommerceChannelIdProvider.notifier).state =
        'delivery_app';
    container.read(currentOrderProvider.notifier).restoreOrder(_order());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => FilledButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const PaymentDialog(),
                      );
                    },
                    child: const Text('Open payment'),
                  ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open payment'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Pay and complete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay and complete'));
    await tester.pumpAndSettle();

    final activeOrder = container.read(currentOrderProvider);

    expect(apiService.savedOrder, isNull);
    expect(activeOrder, isNotNull);
    expect(activeOrder!.isPaid, isTrue);
    expect(activeOrder.fulfillment, isNull);
    expect(
      find.text('Add a delivery destination before closing.'),
      findsOneWidget,
    );
  });
}

Order _order() {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'temp_order',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: const [],
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

class _FakeApiService extends ApiService {
  Order? savedOrder;

  @override
  Future<void> saveOrder(Order order) async {
    savedOrder = order;
  }
}
