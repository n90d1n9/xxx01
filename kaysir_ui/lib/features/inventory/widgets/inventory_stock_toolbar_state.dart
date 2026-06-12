import '../models/inventory_stock_record.dart';

class InventoryStockToolbarCounts {
  const InventoryStockToolbarCounts({
    required this.total,
    required this.needsAttention,
    required this.inStock,
  });

  final int total;
  final int needsAttention;
  final int inStock;
}

InventoryStockToolbarCounts inventoryStockToolbarCounts(
  Iterable<InventoryStockRecord> records,
) {
  var total = 0;
  var needsAttention = 0;
  var inStock = 0;

  for (final record in records) {
    total += 1;
    if (record.needsAttention) {
      needsAttention += 1;
    }
    if (record.status == InventoryStockStatus.inStock) {
      inStock += 1;
    }
  }

  return InventoryStockToolbarCounts(
    total: total,
    needsAttention: needsAttention,
    inStock: inStock,
  );
}
