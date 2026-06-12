import 'inventory_item.dart';
import 'inventory_movement_record.dart';
import 'inventory_replenishment_plan.dart';
import 'inventory_stock_record.dart';
import 'inventory_warehouse_capacity_report.dart';
import 'warehouse.dart';

class InventoryWarehouseDetail {
  const InventoryWarehouseDetail({
    required this.warehouse,
    required this.capacityLine,
    required this.stockRecords,
    required this.movementRecords,
  });

  final Warehouse warehouse;
  final InventoryWarehouseCapacityLine capacityLine;
  final List<InventoryStockRecord> stockRecords;
  final List<InventoryMovementRecord> movementRecords;

  String get branchFilterValue {
    final branchId = warehouse.branchId?.trim();
    if (branchId != null && branchId.isNotEmpty) return branchId;
    return warehouse.branchLabel;
  }

  List<InventoryStockRecord> get attentionStockRecords {
    return [
      for (final record in stockRecords)
        if (record.needsAttention) record,
    ];
  }

  List<InventoryStockRecord> get focusStockRecords {
    final attentionRecords = attentionStockRecords;
    if (attentionRecords.isNotEmpty) return attentionRecords;
    return stockRecords
        .take(_inventoryWarehouseStockPreviewLimit)
        .toList(growable: false);
  }

  int get hiddenFocusStockRecordCount {
    final hiddenCount = stockLineCount - focusStockRecords.length;
    return hiddenCount <= 0 ? 0 : hiddenCount;
  }

  List<InventoryMovementRecord> get recentMovementRecords {
    return movementRecords
        .take(_inventoryWarehouseMovementPreviewLimit)
        .toList(growable: false);
  }

  int get hiddenRecentMovementRecordCount {
    final hiddenCount = movementRecords.length - recentMovementRecords.length;
    return hiddenCount <= 0 ? 0 : hiddenCount;
  }

  int get stockLineCount => stockRecords.length;

  int get totalUnits {
    return stockRecords.fold(0, (total, record) => total + record.quantity);
  }

  double get stockValue {
    return stockRecords.fold(
      0,
      (total, record) => total + record.inventoryValue,
    );
  }

  int get inboundUnits {
    return movementRecords
        .where(
          (record) => record.direction == InventoryMovementDirection.inbound,
        )
        .fold(0, (total, record) => total + record.movement.quantity);
  }

  int get outboundUnits {
    return movementRecords
        .where(
          (record) => record.direction == InventoryMovementDirection.outbound,
        )
        .fold(0, (total, record) => total + record.movement.quantity);
  }

  int get transferCount {
    return movementRecords
        .where(
          (record) => record.direction == InventoryMovementDirection.transfer,
        )
        .length;
  }

  List<InventoryWarehouseCategoryMixLine> get categoryMixLines {
    final accumulators = <String, _InventoryWarehouseCategoryAccumulator>{};
    for (final record in stockRecords) {
      final category = record.categoryLabel;
      accumulators
          .putIfAbsent(
            category,
            () => _InventoryWarehouseCategoryAccumulator(category),
          )
          .add(record);
    }

    return [for (final accumulator in accumulators.values) accumulator.toLine()]
      ..sort(_compareCategoryMixLines);
  }

  int get categoryCount => categoryMixLines.length;

  int get attentionCategoryCount {
    return categoryMixLines.where((line) => line.hasAttention).length;
  }

  List<InventoryWarehouseStockHealthLine> get stockHealthLines {
    final accumulators = {
      for (final status in InventoryStockStatus.values)
        status: _InventoryWarehouseStockHealthAccumulator(status),
    };

    for (final record in stockRecords) {
      accumulators[record.status]!.add(record);
    }

    return [
      for (final status in InventoryStockStatus.values)
        accumulators[status]!.toLine(),
    ];
  }

  InventoryWarehouseStockHealthLine stockHealthLineFor(
    InventoryStockStatus status,
  ) {
    return stockHealthLines.firstWhere((line) => line.status == status);
  }

  int get healthyStockLineCount {
    return stockHealthLineFor(InventoryStockStatus.inStock).stockLineCount;
  }

  int get lowStockLineCount {
    return stockHealthLineFor(InventoryStockStatus.lowStock).stockLineCount;
  }

  int get outOfStockLineCount {
    return stockHealthLineFor(InventoryStockStatus.outOfStock).stockLineCount;
  }

  List<InventoryReplenishmentPlan> get replenishmentPlans {
    return buildInventoryReplenishmentPlans(stockRecords);
  }

  int get criticalReplenishmentCount {
    return replenishmentPlans
        .where(
          (plan) => plan.severity == InventoryReplenishmentSeverity.critical,
        )
        .length;
  }

  int get replenishmentSuggestedUnits {
    return replenishmentPlans.fold(
      0,
      (total, plan) => total + plan.suggestedQuantity,
    );
  }

  double get replenishmentEstimatedCost {
    return replenishmentPlans.fold(
      0,
      (total, plan) => total + plan.estimatedCost,
    );
  }

  List<InventoryWarehouseMovementFlowLine> get movementFlowLines {
    final accumulators = {
      for (final direction in InventoryMovementDirection.values)
        direction: _InventoryWarehouseMovementFlowAccumulator(
          direction: direction,
          warehouseId: warehouse.id,
        ),
    };

    for (final record in movementRecords) {
      accumulators[record.direction]!.add(record);
    }

    return [
      for (final direction in InventoryMovementDirection.values)
        accumulators[direction]!.toLine(),
    ];
  }

  List<InventoryWarehouseMovementFlowLine> get activeMovementFlowLines {
    return [
      for (final line in movementFlowLines)
        if (line.isActive) line,
    ];
  }

  int get movementActivityUnits {
    return movementFlowLines.fold(0, (total, line) => total + line.totalUnits);
  }

  int get movementNetUnits {
    return movementFlowLines.fold(0, (total, line) => total + line.netUnits);
  }
}

const _inventoryWarehouseStockPreviewLimit = 6;
const _inventoryWarehouseMovementPreviewLimit = 6;

class InventoryWarehouseStockHealthLine {
  const InventoryWarehouseStockHealthLine({
    required this.status,
    required this.stockLineCount,
    required this.totalUnits,
    required this.stockValue,
  });

  final InventoryStockStatus status;
  final int stockLineCount;
  final int totalUnits;
  final double stockValue;

  bool get hasStock => stockLineCount > 0;

  double lineShare(int totalStockLines) {
    if (totalStockLines <= 0 || stockLineCount <= 0) return 0;
    return stockLineCount / totalStockLines;
  }

  double unitShare(int totalWarehouseUnits) {
    if (totalWarehouseUnits <= 0 || totalUnits <= 0) return 0;
    return totalUnits / totalWarehouseUnits;
  }

  double valueShare(num totalWarehouseValue) {
    if (totalWarehouseValue <= 0 || stockValue <= 0) return 0;
    return stockValue / totalWarehouseValue;
  }
}

class InventoryWarehouseMovementFlowLine {
  const InventoryWarehouseMovementFlowLine({
    required this.direction,
    required this.movementCount,
    required this.totalUnits,
    required this.netUnits,
    required this.latestMovementAt,
  });

  final InventoryMovementDirection direction;
  final int movementCount;
  final int totalUnits;
  final int netUnits;
  final DateTime? latestMovementAt;

  bool get isActive => movementCount > 0;

  InventoryMovementFilter get movementFilter {
    switch (direction) {
      case InventoryMovementDirection.inbound:
        return InventoryMovementFilter.inbound;
      case InventoryMovementDirection.outbound:
        return InventoryMovementFilter.outbound;
      case InventoryMovementDirection.transfer:
        return InventoryMovementFilter.transfer;
      case InventoryMovementDirection.adjustment:
        return InventoryMovementFilter.adjustment;
      case InventoryMovementDirection.audit:
        return InventoryMovementFilter.stockOpname;
    }
  }

  double movementShare(int totalMovementCount) {
    if (totalMovementCount <= 0 || movementCount <= 0) return 0;
    return movementCount / totalMovementCount;
  }

  double unitShare(int totalActivityUnits) {
    if (totalActivityUnits <= 0 || totalUnits <= 0) return 0;
    return totalUnits / totalActivityUnits;
  }
}

class InventoryWarehouseCategoryMixLine {
  const InventoryWarehouseCategoryMixLine({
    required this.category,
    required this.productCount,
    required this.stockLineCount,
    required this.totalUnits,
    required this.stockValue,
    required this.attentionCount,
  });

  final String category;
  final int productCount;
  final int stockLineCount;
  final int totalUnits;
  final double stockValue;
  final int attentionCount;

  bool get hasAttention => attentionCount > 0;

  double unitShare(int totalWarehouseUnits) {
    if (totalWarehouseUnits <= 0 || totalUnits <= 0) return 0;
    return totalUnits / totalWarehouseUnits;
  }

  double valueShare(num totalWarehouseValue) {
    if (totalWarehouseValue <= 0 || stockValue <= 0) return 0;
    return stockValue / totalWarehouseValue;
  }
}

class _InventoryWarehouseMovementFlowAccumulator {
  _InventoryWarehouseMovementFlowAccumulator({
    required this.direction,
    required this.warehouseId,
  });

  final InventoryMovementDirection direction;
  final String warehouseId;
  int movementCount = 0;
  int totalUnits = 0;
  int netUnits = 0;
  DateTime? latestMovementAt;

  void add(InventoryMovementRecord record) {
    movementCount += 1;
    totalUnits += record.movement.quantity.abs();
    netUnits += _warehouseSignedMovementUnits(record, warehouseId);

    final date = record.movement.date;
    final latest = latestMovementAt;
    if (latest == null || date.isAfter(latest)) {
      latestMovementAt = date;
    }
  }

  InventoryWarehouseMovementFlowLine toLine() {
    return InventoryWarehouseMovementFlowLine(
      direction: direction,
      movementCount: movementCount,
      totalUnits: totalUnits,
      netUnits: netUnits,
      latestMovementAt: latestMovementAt,
    );
  }
}

class _InventoryWarehouseStockHealthAccumulator {
  _InventoryWarehouseStockHealthAccumulator(this.status);

  final InventoryStockStatus status;
  int stockLineCount = 0;
  int totalUnits = 0;
  double stockValue = 0;

  void add(InventoryStockRecord record) {
    stockLineCount += 1;
    totalUnits += record.quantity;
    stockValue += record.inventoryValue;
  }

  InventoryWarehouseStockHealthLine toLine() {
    return InventoryWarehouseStockHealthLine(
      status: status,
      stockLineCount: stockLineCount,
      totalUnits: totalUnits,
      stockValue: stockValue,
    );
  }
}

int _warehouseSignedMovementUnits(
  InventoryMovementRecord record,
  String warehouseId,
) {
  final quantity = record.movement.quantity;
  switch (record.direction) {
    case InventoryMovementDirection.inbound:
      return record.sourceWarehouse.id == warehouseId ? quantity : 0;
    case InventoryMovementDirection.outbound:
      return record.sourceWarehouse.id == warehouseId ? -quantity.abs() : 0;
    case InventoryMovementDirection.transfer:
      final isSource = record.sourceWarehouse.id == warehouseId;
      final isDestination = record.destinationWarehouse?.id == warehouseId;
      if (isDestination && !isSource) return quantity.abs();
      if (isSource && !isDestination) return -quantity.abs();
      return 0;
    case InventoryMovementDirection.adjustment:
    case InventoryMovementDirection.audit:
      return record.sourceWarehouse.id == warehouseId ? quantity : 0;
  }
}

class _InventoryWarehouseCategoryAccumulator {
  _InventoryWarehouseCategoryAccumulator(this.category);

  final String category;
  final Set<String> productIds = {};
  int stockLineCount = 0;
  int totalUnits = 0;
  double stockValue = 0;
  int attentionCount = 0;

  void add(InventoryStockRecord record) {
    productIds.add(record.product.id);
    stockLineCount += 1;
    totalUnits += record.quantity;
    stockValue += record.inventoryValue;
    if (record.needsAttention) attentionCount += 1;
  }

  InventoryWarehouseCategoryMixLine toLine() {
    return InventoryWarehouseCategoryMixLine(
      category: category,
      productCount: productIds.length,
      stockLineCount: stockLineCount,
      totalUnits: totalUnits,
      stockValue: stockValue,
      attentionCount: attentionCount,
    );
  }
}

int _compareCategoryMixLines(
  InventoryWarehouseCategoryMixLine first,
  InventoryWarehouseCategoryMixLine second,
) {
  final attentionRank = second.attentionCount.compareTo(first.attentionCount);
  if (attentionRank != 0) return attentionRank;

  final valueRank = second.stockValue.compareTo(first.stockValue);
  if (valueRank != 0) return valueRank;

  return first.category.compareTo(second.category);
}

InventoryWarehouseDetail? buildInventoryWarehouseDetail({
  String? warehouseId,
  required List<Warehouse> warehouses,
  required List<InventoryItem> inventoryItems,
  required List<InventoryStockRecord> stockRecords,
  required List<InventoryMovementRecord> movementRecords,
}) {
  final warehouse = inventoryWarehouseForKey(warehouses, warehouseId);
  if (warehouse == null) return null;

  final capacityLine =
      buildInventoryWarehouseCapacityLines(
        warehouses: [warehouse],
        inventoryItems: inventoryItems,
      ).first;
  final scopedStockRecords = [
    for (final record in stockRecords)
      if (record.warehouse.id == warehouse.id) record,
  ];
  final scopedMovementRecords = [
    for (final record in movementRecords)
      if (record.matchesWarehouse(warehouse.id)) record,
  ];

  return InventoryWarehouseDetail(
    warehouse: warehouse,
    capacityLine: capacityLine,
    stockRecords: scopedStockRecords,
    movementRecords: scopedMovementRecords,
  );
}

Warehouse? inventoryWarehouseForKey(
  List<Warehouse> warehouses,
  String? warehouseId,
) {
  if (warehouses.isEmpty) return null;

  final normalized = warehouseId?.trim();
  if (normalized == null || normalized.isEmpty) return warehouses.first;

  for (final warehouse in warehouses) {
    if (warehouse.id == normalized) return warehouse;
  }

  final normalizedName = normalized.toLowerCase();
  for (final warehouse in warehouses) {
    if (warehouse.name.trim().toLowerCase() == normalizedName) {
      return warehouse;
    }
  }

  return null;
}
