import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_stock_opname_warehouse_selection.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import 'inventory_projection_provider.dart';
import 'warehouse_provider.dart';

/// Provider-backed data required by the stock opname route.
///
/// The page consumes this snapshot instead of rebuilding stock records inside
/// the widget, keeping route composition separate from inventory projections.
final stockOpnamePageDataProvider = Provider<InventoryStockOpnamePageData>((
  ref,
) {
  return InventoryStockOpnamePageData(
    warehouses: ref.watch(warehousesProvider),
    stockRecords: ref.watch(inventoryStockRecordsProvider),
  );
});

/// Immutable stock opname route snapshot derived from inventory providers.
class InventoryStockOpnamePageData {
  const InventoryStockOpnamePageData({
    required this.warehouses,
    required this.stockRecords,
  });

  final List<Warehouse> warehouses;
  final List<InventoryStockRecord> stockRecords;

  int get totalInventoryLines => stockRecords.length;

  Warehouse? selectedWarehouse(String? warehouseId) {
    return selectedInventoryStockOpnameWarehouse(
      warehouseId: warehouseId,
      warehouses: warehouses,
    );
  }
}
