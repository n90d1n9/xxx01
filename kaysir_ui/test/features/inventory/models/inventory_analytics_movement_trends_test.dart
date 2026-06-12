import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_movement_trends.dart';
import 'package:kaysir/features/inventory/models/inventory_movement.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';

void main() {
  test('buildInventoryAnalyticsMovementTrends creates seven empty days', () {
    final trends = buildInventoryAnalyticsMovementTrends(
      const [],
      asOfDate: DateTime(2026, 6, 7, 18),
    );

    expect(trends, hasLength(7));
    expect(trends.first.date, DateTime(2026, 6, 1));
    expect(trends.last.date, DateTime(2026, 6, 7));
    expect(trends.every((trend) => trend.inboundQuantity == 0), isTrue);
    expect(trends.every((trend) => trend.outboundQuantity == 0), isTrue);
  });

  test(
    'buildInventoryAnalyticsMovementTrends classifies movement quantities',
    () {
      final trends = buildInventoryAnalyticsMovementTrends([
        _movement('purchase', 4, MovementType.purchase),
        _movement('inbound-adjustment', 5, MovementType.adjustment),
        _movement('sale', 3, MovementType.sale),
        _movement('outbound-adjustment', -2, MovementType.adjustment),
        _movement('transfer', 99, MovementType.transfer),
        _movement('opname', 99, MovementType.stockOpname),
        _movement('old', 99, MovementType.receipt, date: DateTime(2026, 5, 31)),
      ], asOfDate: DateTime(2026, 6, 7, 18));

      final latestTrend = trends.last;

      expect(latestTrend.inboundQuantity, 9);
      expect(latestTrend.outboundQuantity, 5);
      expect(latestTrend.netQuantityChange, 4);
    },
  );
}

InventoryMovement _movement(
  String id,
  int quantity,
  MovementType type, {
  DateTime? date,
}) {
  return InventoryMovement(
    id: id,
    productId: 'product-1',
    sourceWarehouseId: 'warehouse-1',
    quantity: quantity,
    type: type,
    date: date ?? DateTime(2026, 6, 7, 12),
    reference: id.toUpperCase(),
  );
}
