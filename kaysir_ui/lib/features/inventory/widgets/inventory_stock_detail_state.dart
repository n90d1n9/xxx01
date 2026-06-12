import '../models/inventory_movement_record.dart';

const inventoryStockDetailRecentMovementLimit = 6;

List<InventoryMovementRecord> inventoryStockDetailRecentMovements(
  Iterable<InventoryMovementRecord> movements, {
  int limit = inventoryStockDetailRecentMovementLimit,
}) {
  return movements.take(limit).toList();
}

String inventoryStockDetailMovementSubtitle(int count) {
  if (count == 1) return '1 related stock event';
  return '$count related stock events';
}
