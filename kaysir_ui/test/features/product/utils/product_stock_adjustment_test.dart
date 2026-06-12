import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_stock_adjustment.dart';

void main() {
  test(
    'calculates stock deltas for inbound and outbound movement families',
    () {
      expect(productStockDeltaForMovement(MovementType.inbound, 4), 4);
      expect(productStockDeltaForMovement(MovementType.purchase, 4), 4);
      expect(productStockDeltaForMovement(MovementType.receipt, 4), 4);
      expect(productStockDeltaForMovement(MovementType.outbound, 4), -4);
      expect(productStockDeltaForMovement(MovementType.sale, 4), -4);
      expect(productStockDeltaForMovement(MovementType.issue, 4), -4);
      expect(productStockDeltaForMovement(MovementType.adjustment, 4), 0);
    },
  );

  test('applies stock movement without allowing negative visible stock', () {
    final product = Product(
      id: 'p1',
      name: 'Coffee',
      price: 10000,
      currentStock: 3,
      stockQuantity: 3,
    );

    final restocked = applyProductStockMovement(
      product: product,
      type: MovementType.inbound,
      quantity: 4,
      notes: 'Restock',
      checkedAt: DateTime(2026, 6, 2),
    );
    final soldOut = applyProductStockMovement(
      product: restocked,
      type: MovementType.outbound,
      quantity: 12,
    );

    expect(restocked.currentStock, 7);
    expect(restocked.stockQuantity, 7);
    expect(restocked.notes, 'Restock');
    expect(restocked.lastChecked, DateTime(2026, 6, 2));
    expect(soldOut.currentStock, 0);
    expect(soldOut.stockQuantity, 0);
  });
}
