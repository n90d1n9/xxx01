import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/held_order_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('held orders can be held, taken, and removed', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final order = _order();
    final heldOrder = container
        .read(heldOrdersProvider.notifier)
        .hold(order, note: 'Window pickup');

    expect(container.read(heldOrderCountProvider), 1);
    expect(heldOrder.order, order);
    expect(heldOrder.itemCount, 2);
    expect(heldOrder.note, 'Window pickup');
    expect(heldOrder.shortOrderId, '456789');

    final takenOrder = container
        .read(heldOrdersProvider.notifier)
        .take(heldOrder.id);

    expect(takenOrder, heldOrder);
    expect(container.read(heldOrdersProvider), isEmpty);

    final disposableHold = container
        .read(heldOrdersProvider.notifier)
        .hold(order, note: ' ');
    expect(disposableHold.note, isNull);

    container.read(heldOrdersProvider.notifier).remove(disposableHold.id);
    expect(container.read(heldOrderCountProvider), 0);
  });
}

Order _order() {
  final product = Product(
    id: 'coffee',
    name: 'Coffee Beans',
    category: 'Grocery',
    price: 120000,
    barcode: '8990001',
  );

  return Order(
    id: 'temp_123456789',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: const [],
    terminal: Terminal(
      id: 'terminal_1',
      name: 'Terminal 1',
      location: 'Front counter',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 10, 15),
    status: 'pending',
  );
}
