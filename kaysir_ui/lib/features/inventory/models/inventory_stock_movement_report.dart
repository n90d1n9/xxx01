import '../../product/models/product.dart';
import 'inventory_branch_filter.dart';
import 'inventory_movement.dart';
import 'inventory_movement_record.dart';
import 'movement_type.dart';
import 'warehouse.dart';

class InventoryStockMovementReportLine {
  const InventoryStockMovementReportLine({required this.record});

  final InventoryMovementRecord record;

  InventoryMovement get movement => record.movement;

  String get id => movement.id;

  String get productId => record.product.id;

  String get productName => record.productName;

  String get skuLabel => record.skuLabel;

  String get sourceWarehouseId => record.sourceWarehouse.id;

  String get sourceWarehouseName => record.sourceLabel;

  String get sourceBranchLabel => record.sourceBranchLabel;

  String? get sourceBranchId => record.sourceBranchId;

  String? get destinationWarehouseId => record.destinationWarehouse?.id;

  String get destinationWarehouseName => record.destinationLabel;

  String? get destinationBranchLabel => record.destinationBranchLabel;

  String? get destinationBranchId => record.destinationBranchId;

  String get routeLabel => record.routeLabel;

  MovementType get movementType => movement.type;

  String get typeLabel => inventoryStockMovementReportTypeLabel(movement.type);

  InventoryMovementDirection get direction => record.direction;

  DateTime get movementDate => movement.date;

  int get quantity => movement.quantity;

  int get signedQuantity => record.signedQuantity;

  String get referenceLabel => record.referenceLabel;

  String get notesLabel => record.notesLabel;

  double get unitPrice => record.product.price;

  double get movementValue => unitPrice * quantity.abs();

  bool matchesDateRange(DateTime startDate, DateTime endDate) {
    final date = _dateOnly(movementDate);
    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);

    return !date.isBefore(start) && !date.isAfter(end);
  }

  bool matchesProduct(String? selectedProductId) {
    return selectedProductId == null || productId == selectedProductId;
  }

  bool matchesMovementType(MovementType? selectedMovementType) {
    return selectedMovementType == null || movementType == selectedMovementType;
  }

  bool matchesWarehouse(String? selectedWarehouseId) {
    if (selectedWarehouseId == null) return true;
    return sourceWarehouseId == selectedWarehouseId ||
        destinationWarehouseId == selectedWarehouseId;
  }

  bool matchesBranch(String? selectedBranch) {
    if (selectedBranch == null) return true;
    return inventoryBranchFilterMatches(
          branchId: sourceBranchId,
          branchLabel: sourceBranchLabel,
          selectedBranch: selectedBranch,
        ) ||
        (destinationBranchLabel != null &&
            inventoryBranchFilterMatches(
              branchId: destinationBranchId,
              branchLabel: destinationBranchLabel!,
              selectedBranch: selectedBranch,
            ));
  }
}

class InventoryStockMovementReportSummary {
  const InventoryStockMovementReportSummary({
    required this.movementCount,
    required this.inboundQuantity,
    required this.outboundQuantity,
    required this.netQuantityChange,
    required this.transferCount,
    required this.adjustmentCount,
    required this.auditCount,
    required this.totalMovementValue,
    required this.productCount,
    required this.warehouseCount,
  });

  final int movementCount;
  final int inboundQuantity;
  final int outboundQuantity;
  final int netQuantityChange;
  final int transferCount;
  final int adjustmentCount;
  final int auditCount;
  final double totalMovementValue;
  final int productCount;
  final int warehouseCount;
}

List<InventoryStockMovementReportLine> buildInventoryStockMovementReportLines({
  required List<Product> products,
  required List<InventoryMovement> movements,
  required List<Warehouse> warehouses,
}) {
  return [
    for (final record in buildInventoryMovementRecords(
      products: products,
      movements: movements,
      warehouses: warehouses,
    ))
      InventoryStockMovementReportLine(record: record),
  ];
}

List<InventoryStockMovementReportLine> filterInventoryStockMovementReportLines({
  required List<InventoryStockMovementReportLine> lines,
  required DateTime startDate,
  required DateTime endDate,
  String? productId,
  MovementType? movementType,
  String? warehouseId,
  String? branchName,
}) {
  return [
    for (final line in lines)
      if (line.matchesDateRange(startDate, endDate) &&
          line.matchesProduct(productId) &&
          line.matchesMovementType(movementType) &&
          line.matchesWarehouse(warehouseId) &&
          line.matchesBranch(branchName))
        line,
  ];
}

InventoryStockMovementReportSummary summarizeInventoryStockMovementReportLines(
  List<InventoryStockMovementReportLine> lines, {
  String? warehouseId,
}) {
  var inboundQuantity = 0;
  var outboundQuantity = 0;
  var netQuantityChange = 0;
  var transferCount = 0;
  var adjustmentCount = 0;
  var auditCount = 0;
  var totalMovementValue = 0.0;
  final productIds = <String>{};
  final warehouseIds = <String>{};

  for (final line in lines) {
    productIds.add(line.productId);
    warehouseIds.add(line.sourceWarehouseId);
    if (line.destinationWarehouseId != null) {
      warehouseIds.add(line.destinationWarehouseId!);
    }
    totalMovementValue += line.movementValue;

    switch (line.direction) {
      case InventoryMovementDirection.inbound:
        inboundQuantity += line.quantity.abs();
        netQuantityChange += line.quantity.abs();
      case InventoryMovementDirection.outbound:
        outboundQuantity += line.quantity.abs();
        netQuantityChange -= line.quantity.abs();
      case InventoryMovementDirection.transfer:
        transferCount += 1;
        netQuantityChange += _transferNetQuantity(line, warehouseId);
      case InventoryMovementDirection.adjustment:
        adjustmentCount += 1;
        netQuantityChange += line.signedQuantity;
      case InventoryMovementDirection.audit:
        auditCount += 1;
    }
  }

  return InventoryStockMovementReportSummary(
    movementCount: lines.length,
    inboundQuantity: inboundQuantity,
    outboundQuantity: outboundQuantity,
    netQuantityChange: netQuantityChange,
    transferCount: transferCount,
    adjustmentCount: adjustmentCount,
    auditCount: auditCount,
    totalMovementValue: totalMovementValue,
    productCount: productIds.length,
    warehouseCount: warehouseIds.length,
  );
}

int _transferNetQuantity(
  InventoryStockMovementReportLine line,
  String? warehouseId,
) {
  if (warehouseId == null) return 0;
  if (line.sourceWarehouseId == warehouseId &&
      line.destinationWarehouseId != warehouseId) {
    return -line.quantity.abs();
  }
  if (line.destinationWarehouseId == warehouseId &&
      line.sourceWarehouseId != warehouseId) {
    return line.quantity.abs();
  }
  return 0;
}

String inventoryStockMovementReportTypeLabel(MovementType type) {
  switch (type) {
    case MovementType.receipt:
      return 'Receipt';
    case MovementType.issue:
      return 'Issue';
    case MovementType.transfer:
      return 'Transfer';
    case MovementType.adjustment:
      return 'Adjustment';
    case MovementType.stockOpname:
      return 'Stock Opname';
    case MovementType.purchase:
      return 'Purchase';
    case MovementType.sale:
      return 'Sale';
    case MovementType.inbound:
      return 'Inbound';
    case MovementType.outbound:
      return 'Outbound';
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
