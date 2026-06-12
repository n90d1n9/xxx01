import '../models/inventory_stock_record.dart';
import '../models/inventory_stock_transfer_draft.dart';
import '../models/warehouse.dart';
import '../utils/inventory_form_utils.dart';

List<Warehouse> inventoryStockTransferDestinationWarehouses({
  required InventoryStockRecord record,
  required Iterable<Warehouse> warehouses,
}) {
  return [
    for (final warehouse in warehouses)
      if (warehouse.id != record.warehouse.id) warehouse,
  ];
}

String? initialInventoryStockTransferDestinationId(
  List<Warehouse> destinationWarehouses,
) {
  return destinationWarehouses.isEmpty ? null : destinationWarehouses.first.id;
}

InventoryStockRecord? inventoryStockTransferDestinationRecord({
  required InventoryStockRecord record,
  required String? destinationWarehouseId,
  required Iterable<InventoryStockRecord> existingRecords,
}) {
  if (destinationWarehouseId == null) return null;

  for (final existingRecord in existingRecords) {
    if (existingRecord.product.id == record.product.id &&
        existingRecord.warehouse.id == destinationWarehouseId) {
      return existingRecord;
    }
  }
  return null;
}

InventoryStockTransferDraft? inventoryStockTransferDraftFromInput({
  required String? destinationWarehouseId,
  required String quantityText,
  required String notes,
}) {
  final quantity = parseInventoryInteger(quantityText);
  if (destinationWarehouseId == null || quantity == null) return null;

  return InventoryStockTransferDraft(
    destinationWarehouseId: destinationWarehouseId,
    quantity: quantity,
    notes: notes.trim(),
  );
}
