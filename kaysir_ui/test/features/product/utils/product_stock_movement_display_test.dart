import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/product/utils/product_stock_movement_display.dart';

void main() {
  test('stock movement display covers every movement type', () {
    for (final type in MovementType.values) {
      final display = ProductStockMovementDisplay.fromMovement(
        StockMovement(
          id: type.name,
          productId: 'p1',
          quantity: 3,
          type: type,
          date: DateTime(2026, 6, 2),
          reference: 'REF',
        ),
      );

      expect(display.typeLabel, isNotEmpty);
      expect(display.quantityLabel, contains('3 units'));
    }
  });

  test('stock movement display marks outbound style movement as negative', () {
    final sale = ProductStockMovementDisplay.fromMovement(
      StockMovement(
        id: 'm1',
        productId: 'p1',
        quantity: 2,
        type: MovementType.sale,
        date: DateTime(2026, 6, 2),
        reference: 'SALE',
      ),
    );
    final purchase = ProductStockMovementDisplay.fromMovement(
      StockMovement(
        id: 'm2',
        productId: 'p1',
        quantity: 5,
        type: MovementType.purchase,
        date: DateTime(2026, 6, 2),
        reference: 'PO',
      ),
    );

    expect(sale.typeLabel, 'Sale');
    expect(sale.quantityLabel, '-2 units');
    expect(purchase.typeLabel, 'Purchase');
    expect(purchase.quantityLabel, '+5 units');
  });
}
