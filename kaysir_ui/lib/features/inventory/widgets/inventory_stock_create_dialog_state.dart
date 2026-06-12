import '../../product/models/product.dart';
import '../models/inventory_stock_create_draft.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';
import '../utils/inventory_form_utils.dart';

class InventoryStockCreateLocationSelection {
  const InventoryStockCreateLocationSelection({
    required this.productId,
    required this.warehouseId,
  });

  final String productId;
  final String warehouseId;
}

bool canCreateInventoryStockLine({
  required List<Product> products,
  required List<Warehouse> warehouses,
  required List<InventoryStockRecord> existingRecords,
}) {
  if (products.isEmpty || warehouses.isEmpty) return false;

  return products.any(
    (product) => warehouses.any(
      (warehouse) =>
          !inventoryStockLocationExists(
            existingRecords,
            productId: product.id,
            warehouseId: warehouse.id,
          ),
    ),
  );
}

InventoryStockCreateLocationSelection? firstAvailableInventoryStockLocation({
  required List<Product> products,
  required List<Warehouse> warehouses,
  required List<InventoryStockRecord> existingRecords,
}) {
  for (final product in products) {
    for (final warehouse in warehouses) {
      if (!inventoryStockLocationExists(
        existingRecords,
        productId: product.id,
        warehouseId: warehouse.id,
      )) {
        return InventoryStockCreateLocationSelection(
          productId: product.id,
          warehouseId: warehouse.id,
        );
      }
    }
  }
  return null;
}

InventoryStockCreateDraft? inventoryStockCreateDraftFromInput({
  required String? productId,
  required String? warehouseId,
  required String quantityText,
  required String reorderPointText,
  required String reorderQuantityText,
}) {
  final quantity = parseInventoryInteger(quantityText);
  final reorderPoint = parseInventoryInteger(reorderPointText);
  final reorderQuantity = parseInventoryInteger(reorderQuantityText);
  if (productId == null ||
      warehouseId == null ||
      quantity == null ||
      reorderPoint == null ||
      reorderQuantity == null) {
    return null;
  }

  return InventoryStockCreateDraft(
    productId: productId,
    warehouseId: warehouseId,
    currentQuantity: quantity,
    reorderPoint: reorderPoint,
    reorderQuantity: reorderQuantity,
  );
}
