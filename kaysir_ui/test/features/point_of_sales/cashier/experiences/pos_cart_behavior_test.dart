import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_cart_behavior.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('standard cart behavior merges matching product lines', () {
    const behavior = POSCartBehavior.standard;
    final product = Product(id: 'coffee', name: 'Coffee', price: 25000);
    final item = OrderItem(
      id: 'item_1',
      product: product,
      quantity: 1,
      unitPrice: product.price,
      discount: 0,
    );

    expect(behavior.shouldMerge(item, product), isTrue);
    expect(behavior.quantityStep, 1);
    expect(
      behavior
          .resolveQuantityChange(product: product, requestedQuantity: 2)
          .quantity,
      2,
    );
  });

  test('assisted service behavior keeps repeated selections as new lines', () {
    const behavior = POSCartBehavior.assistedService;
    final product = Product(id: 'consult', name: 'Consultation', price: 50000);
    final item = OrderItem(
      id: 'item_1',
      product: product,
      quantity: 1,
      unitPrice: product.price,
      discount: 0,
    );

    expect(behavior.shouldMerge(item, product), isFalse);
    expect(behavior.emptyCartTitle, 'Start a service order');
  });

  test('cart behavior can cap quantities by available stock', () {
    const behavior = POSCartBehavior(limitQuantityToAvailableStock: true);
    final product = Product(
      id: 'rice',
      name: 'Rice',
      price: 75000,
      stockQuantity: 3,
    );

    final change = behavior.resolveQuantityChange(
      product: product,
      requestedQuantity: 8,
    );

    expect(change.quantity, 3);
    expect(change.wasAdjusted, isTrue);
    expect(change.message, 'Maximum quantity reached');
  });
}
