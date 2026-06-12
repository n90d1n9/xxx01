import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_catalog_behavior.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('standard POS catalog behavior allows ordinary product selection', () {
    final action = POSCatalogBehavior.standard.resolveProductAction(
      Product(name: 'Coffee', price: 0),
    );

    expect(action.canAdd, isTrue);
    expect(action.actionLabel, 'Add');
    expect(action.disabledReason, isNull);
  });

  test('quick checkout catalog behavior requires positive prices', () {
    final action = POSCatalogBehavior.quickCheckout.resolveProductAction(
      Product(name: 'Unpriced item', price: 0),
    );

    expect(action.canAdd, isFalse);
    expect(action.actionLabel, 'Quick add');
    expect(action.disabledReason, 'Price required before checkout');
  });

  test('catalog behavior can require stock on hand', () {
    const behavior = POSCatalogBehavior(requireStockOnHand: true);

    final action = behavior.resolveProductAction(
      Product(name: 'Empty shelf', price: 12000, currentStock: 0),
    );

    expect(action.canAdd, isFalse);
    expect(action.disabledReason, 'No stock available');
  });
}
