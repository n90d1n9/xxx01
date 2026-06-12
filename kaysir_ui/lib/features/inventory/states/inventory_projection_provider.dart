import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_movement_record.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_item_provider.dart';
import 'inventory_movement_provider.dart';
import 'product_provider.dart';
import 'warehouse_provider.dart';

final inventoryStockRecordsProvider = Provider<List<InventoryStockRecord>>((
  ref,
) {
  return buildInventoryStockRecords(
    inventoryItems: ref.watch(inventoryItemsProvider),
    products: ref.watch(productsProvider),
    warehouses: ref.watch(warehousesProvider),
  );
});

final inventoryMovementRecordsProvider =
    Provider<List<InventoryMovementRecord>>((ref) {
      return buildInventoryMovementRecords(
        movements: ref.watch(inventoryMovementsProvider),
        products: ref.watch(productsProvider),
        warehouses: ref.watch(warehousesProvider),
      );
    });

final inventoryReplenishmentPlansProvider =
    Provider<List<InventoryReplenishmentPlan>>((ref) {
      return buildInventoryReplenishmentPlans(
        ref.watch(inventoryStockRecordsProvider),
      );
    });
