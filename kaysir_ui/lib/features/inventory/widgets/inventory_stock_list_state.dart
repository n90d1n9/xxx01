import '../models/inventory_stock_record.dart';

int inventoryStockListAttentionCount(Iterable<InventoryStockRecord> records) {
  return records.where((record) => record.needsAttention).length;
}

String inventoryStockListSubtitle({
  required int visibleCount,
  required int totalCount,
}) {
  return '$visibleCount of $totalCount stock lines shown';
}

String inventoryStockListAttentionLabel(int count) {
  if (count == 1) return '1 needs attention';
  return '$count need attention';
}
