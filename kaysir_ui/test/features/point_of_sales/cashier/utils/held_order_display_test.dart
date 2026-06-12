import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/held_order_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/held_order_display.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('sortHeldOrdersForPOS returns newest held order first', () {
    final older = _heldOrder(id: 'older', heldAt: DateTime(2026, 5, 30, 9));
    final newer = _heldOrder(id: 'newer', heldAt: DateTime(2026, 5, 30, 10));

    final sorted = sortHeldOrdersForPOS([older, newer]);

    expect(sorted.map((heldOrder) => heldOrder.id), ['newer', 'older']);
  });

  test('held order labels format time, age, and summary', () {
    final heldOrder = _heldOrder(
      heldAt: DateTime(2026, 5, 30, 10, 5),
      quantity: 2,
    );

    expect(heldOrderTimeLabel(heldOrder.heldAt), '10:05');
    expect(
      heldOrderAgeLabel(heldOrder.heldAt, DateTime(2026, 5, 30, 10, 17)),
      '12 min ago',
    );
    expect(heldOrderSummaryLabel(heldOrder), '2 items | Rp 240.000');
  });
}

HeldOrder _heldOrder({
  String id = 'hold',
  required DateTime heldAt,
  int quantity = 1,
}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 120000);
  return HeldOrder(
    id: id,
    heldAt: heldAt,
    note: 'Pickup later',
    order: Order(
      id: 'temp_123456789',
      items: [
        OrderItem(
          id: 'line',
          product: product,
          quantity: quantity,
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
    ),
  );
}
