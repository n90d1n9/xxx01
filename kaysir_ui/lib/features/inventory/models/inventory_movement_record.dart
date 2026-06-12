import '../../product/models/product.dart';
import 'inventory_branch_filter.dart';
import '../utils/inventory_label_utils.dart';
import '../utils/inventory_search_utils.dart';
import 'inventory_movement.dart';
import 'movement_type.dart';
import 'warehouse.dart';

enum InventoryMovementDirection {
  inbound,
  outbound,
  transfer,
  adjustment,
  audit,
}

enum InventoryMovementFilter {
  all,
  inbound,
  outbound,
  transfer,
  adjustment,
  stockOpname,
}

class InventoryMovementRecord {
  const InventoryMovementRecord({
    required this.movement,
    required this.product,
    required this.sourceWarehouse,
    this.destinationWarehouse,
  });

  final InventoryMovement movement;
  final Product product;
  final Warehouse sourceWarehouse;
  final Warehouse? destinationWarehouse;

  String get productName => inventoryProductNameLabel(product.name);

  String get skuLabel => inventorySkuLabel(product.sku);

  String get referenceLabel => inventoryReferenceLabel(movement.reference);

  String get notesLabel => inventoryNotesLabel(movement.notes);

  String get sourceLabel => inventoryWarehouseNameLabel(sourceWarehouse.name);

  String get sourceBranchLabel => sourceWarehouse.branchLabel;

  String? get sourceBranchId => sourceWarehouse.branchId;

  String get destinationLabel => inventoryWarehouseNameLabel(
    destinationWarehouse?.name,
    fallback: inventoryNoDestinationLabel,
  );

  String? get destinationBranchLabel => destinationWarehouse?.branchLabel;

  String? get destinationBranchId => destinationWarehouse?.branchId;

  String get routeLabel {
    if (direction == InventoryMovementDirection.transfer) {
      return '$sourceLabel -> $destinationLabel';
    }
    if (direction == InventoryMovementDirection.inbound) {
      return 'Inbound to $sourceLabel';
    }
    if (direction == InventoryMovementDirection.outbound) {
      return 'Outbound from $sourceLabel';
    }
    return sourceLabel;
  }

  InventoryMovementDirection get direction =>
      inventoryMovementDirection(movement.type);

  String get typeLabel => inventoryMovementTypeLabel(movement.type);

  int get signedQuantity {
    switch (direction) {
      case InventoryMovementDirection.inbound:
        return movement.quantity;
      case InventoryMovementDirection.outbound:
        return -movement.quantity.abs();
      case InventoryMovementDirection.transfer:
      case InventoryMovementDirection.adjustment:
      case InventoryMovementDirection.audit:
        return movement.quantity;
    }
  }

  bool matchesQuery(String query) {
    return inventorySearchMatchesAny(query, [
      productName,
      skuLabel,
      referenceLabel,
      notesLabel,
      sourceLabel,
      sourceBranchLabel,
      destinationLabel,
      destinationBranchLabel,
      typeLabel,
    ]);
  }

  bool matchesWarehouse(String? warehouseId) {
    if (warehouseId == null) return true;
    return sourceWarehouse.id == warehouseId ||
        destinationWarehouse?.id == warehouseId;
  }

  bool matchesBranch(String? branchName) {
    if (branchName == null) return true;
    return inventoryBranchFilterMatches(
          branchId: sourceBranchId,
          branchLabel: sourceBranchLabel,
          selectedBranch: branchName,
        ) ||
        (destinationBranchLabel != null &&
            inventoryBranchFilterMatches(
              branchId: destinationBranchId,
              branchLabel: destinationBranchLabel!,
              selectedBranch: branchName,
            ));
  }

  bool matchesFilter(InventoryMovementFilter filter) {
    switch (filter) {
      case InventoryMovementFilter.all:
        return true;
      case InventoryMovementFilter.inbound:
        return direction == InventoryMovementDirection.inbound;
      case InventoryMovementFilter.outbound:
        return direction == InventoryMovementDirection.outbound;
      case InventoryMovementFilter.transfer:
        return direction == InventoryMovementDirection.transfer;
      case InventoryMovementFilter.adjustment:
        return direction == InventoryMovementDirection.adjustment;
      case InventoryMovementFilter.stockOpname:
        return direction == InventoryMovementDirection.audit;
    }
  }
}

List<InventoryMovementRecord> buildInventoryMovementRecords({
  required List<InventoryMovement> movements,
  required List<Product> products,
  required List<Warehouse> warehouses,
}) {
  final productsById = {for (final product in products) product.id: product};
  final warehousesById = {
    for (final warehouse in warehouses) warehouse.id: warehouse,
  };

  return [
    for (final movement in movements)
      InventoryMovementRecord(
        movement: movement,
        product: productsById[movement.productId] ?? _unknownProduct(movement),
        sourceWarehouse:
            warehousesById[movement.sourceWarehouseId] ??
            _unknownWarehouse(movement.sourceWarehouseId),
        destinationWarehouse:
            movement.destinationWarehouseId == null
                ? null
                : warehousesById[movement.destinationWarehouseId] ??
                    _unknownWarehouse(movement.destinationWarehouseId!),
      ),
  ]..sort(
    (first, second) => second.movement.date.compareTo(first.movement.date),
  );
}

List<InventoryMovementRecord> filterInventoryMovementRecords(
  List<InventoryMovementRecord> records, {
  String query = '',
  String? warehouseId,
  String? branchName,
  InventoryMovementFilter filter = InventoryMovementFilter.all,
}) {
  return [
    for (final record in records)
      if (record.matchesWarehouse(warehouseId) &&
          record.matchesBranch(branchName) &&
          record.matchesFilter(filter) &&
          record.matchesQuery(query))
        record,
  ];
}

InventoryMovementDirection inventoryMovementDirection(MovementType type) {
  switch (type) {
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
      return InventoryMovementDirection.inbound;
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return InventoryMovementDirection.outbound;
    case MovementType.transfer:
      return InventoryMovementDirection.transfer;
    case MovementType.adjustment:
      return InventoryMovementDirection.adjustment;
    case MovementType.stockOpname:
      return InventoryMovementDirection.audit;
  }
}

String inventoryMovementTypeLabel(MovementType type) {
  switch (type) {
    case MovementType.purchase:
    case MovementType.receipt:
    case MovementType.inbound:
      return 'Inbound';
    case MovementType.sale:
    case MovementType.issue:
    case MovementType.outbound:
      return 'Outbound';
    case MovementType.transfer:
      return 'Transfer';
    case MovementType.adjustment:
      return 'Adjustment';
    case MovementType.stockOpname:
      return 'Stock Opname';
  }
}

Product _unknownProduct(InventoryMovement movement) {
  return Product(
    id: movement.productId,
    name: inventoryUnknownProductLabel,
    sku: 'Unknown',
    category: inventoryUncategorizedLabel,
    price: 0,
  );
}

Warehouse _unknownWarehouse(String id) {
  return Warehouse(id: id, name: inventoryUnknownWarehouseLabel, location: '');
}
