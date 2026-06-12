import '../models/inventory_stock_record.dart';

const inventoryStockListItemCompactBreakpoint = 860.0;

bool inventoryStockListItemIsCompact(double width) {
  return width < inventoryStockListItemCompactBreakpoint;
}

String inventoryStockProductSummarySubtitle(InventoryStockRecord record) {
  return '${record.skuLabel} | ${record.categoryLabel} | '
      '${record.warehouseName} - ${record.warehouseLocation}';
}
