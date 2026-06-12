import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_display.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('shortPOSOrderId strips temp prefix and keeps the last six digits', () {
    expect(shortPOSOrderId('temp_123456789'), '456789');
    expect(shortPOSOrderId('A123'), 'A123');
  });

  test('totalPOSOrderItems sums item quantities', () {
    final order = _order(
      items: [_item(id: 'one', quantity: 2), _item(id: 'two', quantity: 3)],
    );

    expect(totalPOSOrderItems(order), 5);
  });

  test('posOrderSwitchSummary formats line count, item count, and total', () {
    final order = _order(
      items: [_item(id: 'one', quantity: 2), _item(id: 'two', quantity: 3)],
    );

    expect(posOrderSwitchSummary(order), '2 lines, 5 items, Rp 125.000');
  });

  test('resolvePOSOrderReadiness reports empty, due, and closable states', () {
    expect(resolvePOSOrderReadiness(_order()), POSOrderReadiness.empty);

    expect(
      resolvePOSOrderReadiness(_order(items: [_item()])),
      POSOrderReadiness.needsPayment,
    );

    expect(
      resolvePOSOrderReadiness(
        _order(
          items: [_item()],
          payments: [
            Payment(
              id: 'payment',
              amount: 25000,
              method: 'Cash',
              timestamp: DateTime(2026, 5, 30, 9),
              reference: 'REF',
              isComplete: true,
            ),
          ],
        ),
      ),
      POSOrderReadiness.readyToComplete,
    );
  });
}

Order _order({
  List<OrderItem> items = const [],
  List<Payment> payments = const [],
}) {
  return Order(
    id: 'temp_123456789',
    items: items,
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

OrderItem _item({String id = 'item', int quantity = 1}) {
  return OrderItem(
    id: id,
    product: Product(id: 'product_$id', name: 'Coffee', price: 25000),
    quantity: quantity,
    unitPrice: 25000,
    discount: 0,
  );
}
