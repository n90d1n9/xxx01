import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';
import 'inventory_movement.dart';
import 'movement_type.dart';

/// Recent movement line shown in branch drill-down analytics.
class InventoryAnalyticsBranchMovement {
  const InventoryAnalyticsBranchMovement({
    required this.productName,
    required this.type,
    required this.quantity,
    required this.referenceLabel,
    required this.routeLabel,
    required this.date,
  });

  final String productName;
  final MovementType type;
  final int quantity;
  final String referenceLabel;
  final String routeLabel;
  final DateTime date;
}

/// Builds branch drill-down movement copy from raw movement source data.
InventoryAnalyticsBranchMovement buildInventoryAnalyticsBranchMovement({
  required InventoryMovement movement,
  required Product? product,
  required String sourceWarehouseName,
  required String? destinationWarehouseName,
}) {
  return InventoryAnalyticsBranchMovement(
    productName: inventoryProductNameLabel(product?.name),
    type: movement.type,
    quantity: inventoryAnalyticsBranchMovementQuantity(movement),
    referenceLabel: inventoryReferenceLabel(movement.reference),
    routeLabel: inventoryAnalyticsBranchMovementRouteLabel(
      movement,
      sourceWarehouseName: sourceWarehouseName,
      destinationWarehouseName: destinationWarehouseName,
    ),
    date: movement.date,
  );
}

/// Returns branch-facing signed movement quantity.
int inventoryAnalyticsBranchMovementQuantity(InventoryMovement movement) {
  switch (movement.type) {
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return -movement.quantity.abs();
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
    case MovementType.transfer:
    case MovementType.adjustment:
    case MovementType.stockOpname:
      return movement.quantity;
  }
}

/// Returns branch drill-down route copy for a movement.
String inventoryAnalyticsBranchMovementRouteLabel(
  InventoryMovement movement, {
  required String sourceWarehouseName,
  required String? destinationWarehouseName,
}) {
  switch (movement.type) {
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
      return 'Inbound to $sourceWarehouseName';
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return 'Outbound from $sourceWarehouseName';
    case MovementType.transfer:
      return '$sourceWarehouseName -> ${destinationWarehouseName ?? inventoryNoDestinationLabel}';
    case MovementType.adjustment:
    case MovementType.stockOpname:
      return sourceWarehouseName;
  }
}
