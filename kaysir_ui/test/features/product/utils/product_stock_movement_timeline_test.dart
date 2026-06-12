import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/models/stock_movement.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/utils/product_stock_movement_timeline.dart';

void main() {
  test('timeline sorts newest first and summarizes stock impact', () {
    final timeline = buildProductStockMovementTimeline(
      movements: _movements,
      products: _products,
    );

    expect(timeline.entries.map((entry) => entry.movement.id), [
      'adjust',
      'sale',
      'purchase',
    ]);
    expect(timeline.summary.totalMovements, 3);
    expect(timeline.summary.inboundUnits, 8);
    expect(timeline.summary.outboundUnits, 2);
    expect(timeline.summary.neutralMovements, 1);
    expect(timeline.summary.latestMovementAt, DateTime(2026, 6, 3));
  });

  test('timeline filters by query and movement type', () {
    final byQuery = buildProductStockMovementTimeline(
      movements: _movements,
      products: _products,
      query: 'sku-2',
    );
    final byType = buildProductStockMovementTimeline(
      movements: _movements,
      products: _products,
      type: MovementType.sale,
    );

    expect(byQuery.entries.single.productName, 'Tea');
    expect(byType.entries.single.referenceLabel, 'SALE-1');
  });

  test('timeline provides safe labels for unknown products and references', () {
    final timeline = buildProductStockMovementTimeline(
      movements: [
        StockMovement(
          id: 'unknown',
          productId: 'missing',
          quantity: 1,
          type: MovementType.transfer,
          date: DateTime(2026, 6, 4),
          reference: ' ',
        ),
      ],
      products: const [],
    );

    final entry = timeline.entries.single;
    expect(entry.productName, 'Unknown product');
    expect(entry.skuLabel, 'No SKU');
    expect(entry.categoryLabel, 'Uncategorized');
    expect(entry.referenceLabel, 'No reference');
    expect(timeline.summary.neutralMovements, 1);
  });
}

final _products = [
  Product(id: 'p1', name: 'Coffee', sku: 'SKU-1', category: 'Beverage'),
  Product(id: 'p2', name: 'Tea', sku: 'SKU-2', category: 'Beverage'),
];

final _movements = [
  StockMovement(
    id: 'purchase',
    productId: 'p1',
    quantity: 8,
    type: MovementType.purchase,
    date: DateTime(2026, 6, 1),
    reference: 'PO-1',
  ),
  StockMovement(
    id: 'sale',
    productId: 'p2',
    quantity: 2,
    type: MovementType.sale,
    date: DateTime(2026, 6, 2),
    reference: 'SALE-1',
  ),
  StockMovement(
    id: 'adjust',
    productId: 'p1',
    quantity: 1,
    type: MovementType.adjustment,
    date: DateTime(2026, 6, 3),
    reference: 'COUNT-1',
  ),
];
