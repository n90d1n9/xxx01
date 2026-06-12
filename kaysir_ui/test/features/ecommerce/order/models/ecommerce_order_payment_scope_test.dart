import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('payment scope classifies internal, external, and unpaid orders', () {
    final internal = _order(id: 'internal', method: 'Card');
    final external = _order(id: 'external', method: 'Marketplace settlement');
    final unpaid = _order(id: 'unpaid', paid: false);

    expect(
      matchesOrderPaymentScope(internal, OrderPaymentScope.internalPaid),
      isTrue,
    );
    expect(
      matchesOrderPaymentScope(external, OrderPaymentScope.externalSettlement),
      isTrue,
    );
    expect(matchesOrderPaymentScope(unpaid, OrderPaymentScope.unpaid), isTrue);
    expect(ecommerceOrderUsesExternalSettlement(external), isTrue);
    expect(ecommerceOrderUsesExternalSettlement(internal), isFalse);
  });
}

Order _order({required String id, String method = 'Card', bool paid = true}) {
  final product = Product(id: '$id-product', name: 'Coffee', price: 50000);
  final createdAt = DateTime(2026, 5, 31, 9);

  return Order(
    id: id,
    items: [
      OrderItem(
        id: '$id-line',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments:
        paid
            ? [
              Payment(
                id: '$id-payment',
                amount: product.price,
                method: method,
                timestamp: createdAt,
                reference: '$id-ref',
                isComplete: true,
              ),
            ]
            : const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: createdAt,
    status: 'completed',
  );
}
