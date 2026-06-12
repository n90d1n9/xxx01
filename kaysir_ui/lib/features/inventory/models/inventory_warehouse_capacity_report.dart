import '../utils/inventory_label_utils.dart';
import 'inventory_branch_filter.dart';
import 'inventory_item.dart';
import 'warehouse.dart';

enum InventoryWarehouseCapacityStatus {
  untracked,
  low,
  moderate,
  high,
  critical,
}

class InventoryWarehouseCapacityLine {
  const InventoryWarehouseCapacityLine({
    required this.warehouseId,
    required this.warehouseName,
    this.branchId,
    this.branchLabel = inventoryDefaultWarehouseBranchName,
    required this.locationLabel,
    required this.usedUnits,
    required this.productCount,
    this.capacity,
  });

  final String warehouseId;
  final String warehouseName;
  final String? branchId;
  final String branchLabel;
  final String locationLabel;
  final int usedUnits;
  final int productCount;
  final num? capacity;

  bool get hasTrackedCapacity => capacity != null && capacity! > 0;

  num? get availableUnits {
    final capacity = this.capacity;
    if (capacity == null) return null;
    return capacity - usedUnits;
  }

  double get utilizationPercent {
    final capacity = this.capacity;
    if (capacity == null || capacity <= 0) return 0;
    return (usedUnits / capacity * 100).clamp(0, 999).toDouble();
  }

  bool get isOverCapacity {
    final available = availableUnits;
    return available != null && available < 0;
  }

  InventoryWarehouseCapacityStatus get status {
    if (!hasTrackedCapacity) return InventoryWarehouseCapacityStatus.untracked;

    final utilization = utilizationPercent;
    if (utilization >= 90) return InventoryWarehouseCapacityStatus.critical;
    if (utilization >= 75) return InventoryWarehouseCapacityStatus.high;
    if (utilization >= 50) return InventoryWarehouseCapacityStatus.moderate;
    return InventoryWarehouseCapacityStatus.low;
  }

  bool matchesBranch(String? branchName) {
    return inventoryBranchFilterMatches(
      branchId: branchId,
      branchLabel: branchLabel,
      selectedBranch: branchName,
    );
  }
}

class InventoryWarehouseCapacitySummary {
  const InventoryWarehouseCapacitySummary({
    required this.warehouseCount,
    required this.trackedWarehouseCount,
    required this.totalCapacity,
    required this.usedUnits,
    required this.availableUnits,
    required this.productCount,
    required this.criticalWarehouseCount,
  });

  final int warehouseCount;
  final int trackedWarehouseCount;
  final num totalCapacity;
  final int usedUnits;
  final num availableUnits;
  final int productCount;
  final int criticalWarehouseCount;

  double get utilizationPercent {
    if (totalCapacity <= 0) return 0;
    return (usedUnits / totalCapacity * 100).clamp(0, 999).toDouble();
  }
}

List<InventoryWarehouseCapacityLine> buildInventoryWarehouseCapacityLines({
  required List<Warehouse> warehouses,
  required List<InventoryItem> inventoryItems,
}) {
  final productIdsByWarehouse = <String, Set<String>>{
    for (final warehouse in warehouses) warehouse.id: <String>{},
  };
  final usedUnitsByWarehouse = <String, int>{
    for (final warehouse in warehouses) warehouse.id: 0,
  };

  for (final item in inventoryItems) {
    if (!usedUnitsByWarehouse.containsKey(item.warehouseId)) continue;
    usedUnitsByWarehouse[item.warehouseId] =
        usedUnitsByWarehouse[item.warehouseId]! + item.currentQuantity;
    productIdsByWarehouse[item.warehouseId]!.add(item.productId);
  }

  return [
    for (final warehouse in warehouses)
      InventoryWarehouseCapacityLine(
        warehouseId: warehouse.id,
        warehouseName: inventoryWarehouseNameLabel(warehouse.name),
        branchId: warehouse.branchId,
        branchLabel: warehouse.branchLabel,
        locationLabel: inventoryLocationLabel(warehouse.location),
        usedUnits: usedUnitsByWarehouse[warehouse.id] ?? 0,
        productCount: productIdsByWarehouse[warehouse.id]?.length ?? 0,
        capacity: warehouse.capacity,
      ),
  ]..sort(_compareCapacityLines);
}

InventoryWarehouseCapacitySummary summarizeInventoryWarehouseCapacityLines(
  List<InventoryWarehouseCapacityLine> lines,
) {
  var trackedWarehouseCount = 0;
  var totalCapacity = 0.0;
  var usedUnits = 0;
  var availableUnits = 0.0;
  var criticalWarehouseCount = 0;
  var productCount = 0;

  for (final line in lines) {
    usedUnits += line.usedUnits;
    productCount += line.productCount;
    if (!line.hasTrackedCapacity) continue;

    trackedWarehouseCount += 1;
    totalCapacity += line.capacity!.toDouble();
    availableUnits += line.availableUnits!.toDouble();
    if (line.status == InventoryWarehouseCapacityStatus.critical) {
      criticalWarehouseCount += 1;
    }
  }

  return InventoryWarehouseCapacitySummary(
    warehouseCount: lines.length,
    trackedWarehouseCount: trackedWarehouseCount,
    totalCapacity: totalCapacity,
    usedUnits: usedUnits,
    availableUnits: availableUnits,
    productCount: productCount,
    criticalWarehouseCount: criticalWarehouseCount,
  );
}

List<InventoryWarehouseCapacityLine> filterInventoryWarehouseCapacityLines(
  List<InventoryWarehouseCapacityLine> lines, {
  String? branchName,
  String? warehouseId,
}) {
  return [
    for (final line in lines)
      if (line.matchesBranch(branchName) &&
          (warehouseId == null || line.warehouseId == warehouseId))
        line,
  ];
}

String inventoryWarehouseCapacityStatusLabel(
  InventoryWarehouseCapacityStatus status,
) {
  switch (status) {
    case InventoryWarehouseCapacityStatus.untracked:
      return 'Untracked';
    case InventoryWarehouseCapacityStatus.low:
      return 'Low';
    case InventoryWarehouseCapacityStatus.moderate:
      return 'Moderate';
    case InventoryWarehouseCapacityStatus.high:
      return 'High';
    case InventoryWarehouseCapacityStatus.critical:
      return 'Critical';
  }
}

int _compareCapacityLines(
  InventoryWarehouseCapacityLine first,
  InventoryWarehouseCapacityLine second,
) {
  final statusRank = _statusRank(
    first.status,
  ).compareTo(_statusRank(second.status));
  if (statusRank != 0) return statusRank;

  final utilizationRank = second.utilizationPercent.compareTo(
    first.utilizationPercent,
  );
  if (utilizationRank != 0) return utilizationRank;

  return first.warehouseName.compareTo(second.warehouseName);
}

int _statusRank(InventoryWarehouseCapacityStatus status) {
  switch (status) {
    case InventoryWarehouseCapacityStatus.critical:
      return 0;
    case InventoryWarehouseCapacityStatus.high:
      return 1;
    case InventoryWarehouseCapacityStatus.moderate:
      return 2;
    case InventoryWarehouseCapacityStatus.low:
      return 3;
    case InventoryWarehouseCapacityStatus.untracked:
      return 4;
  }
}
