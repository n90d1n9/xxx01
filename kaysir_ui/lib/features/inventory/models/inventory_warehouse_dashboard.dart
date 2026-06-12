import '../../product/models/product.dart';
import 'inventory_branch.dart';
import 'inventory_item.dart';
import 'inventory_stock_record.dart';
import 'inventory_warehouse_capacity_report.dart';
import 'warehouse.dart';

enum InventoryWarehouseDashboardStatus { healthy, watch, attention, setup }

class InventoryWarehouseDashboardSnapshot {
  const InventoryWarehouseDashboardSnapshot({
    required this.branchSummaries,
    required this.branchCount,
    required this.activeBranchCount,
    required this.warehouseCount,
    required this.trackedWarehouseCount,
    required this.totalCapacity,
    required this.usedUnits,
    required this.availableUnits,
    required this.lowStockItemCount,
    required this.criticalWarehouseCount,
    required this.untrackedWarehouseCount,
  });

  final List<InventoryWarehouseBranchSummary> branchSummaries;
  final int branchCount;
  final int activeBranchCount;
  final int warehouseCount;
  final int trackedWarehouseCount;
  final num totalCapacity;
  final int usedUnits;
  final num availableUnits;
  final int lowStockItemCount;
  final int criticalWarehouseCount;
  final int untrackedWarehouseCount;

  int get attentionBranchCount {
    return branchSummaries
        .where(
          (summary) =>
              summary.status == InventoryWarehouseDashboardStatus.attention ||
              summary.status == InventoryWarehouseDashboardStatus.setup,
        )
        .length;
  }

  double get utilizationPercent {
    if (totalCapacity <= 0) return 0;
    return (usedUnits / totalCapacity * 100).clamp(0, 999).toDouble();
  }

  double get capacityTrackingPercent {
    if (warehouseCount == 0) return 0;
    return (trackedWarehouseCount / warehouseCount * 100)
        .clamp(0, 100)
        .toDouble();
  }
}

class InventoryWarehouseBranchSummary {
  const InventoryWarehouseBranchSummary({
    required this.branchKey,
    required this.branchName,
    required this.cityLabel,
    this.branchStatus,
    required this.warehouseCount,
    required this.trackedWarehouseCount,
    required this.totalCapacity,
    required this.usedUnits,
    required this.productCount,
    required this.lowStockItemCount,
    required this.criticalWarehouseCount,
    required this.untrackedWarehouseCount,
  });

  final String branchKey;
  final String branchName;
  final String cityLabel;
  final InventoryBranchStatus? branchStatus;
  final int warehouseCount;
  final int trackedWarehouseCount;
  final num totalCapacity;
  final int usedUnits;
  final int productCount;
  final int lowStockItemCount;
  final int criticalWarehouseCount;
  final int untrackedWarehouseCount;

  num get availableUnits => totalCapacity <= 0 ? 0 : totalCapacity - usedUnits;

  double get utilizationPercent {
    if (totalCapacity <= 0) return 0;
    return (usedUnits / totalCapacity * 100).clamp(0, 999).toDouble();
  }

  InventoryWarehouseDashboardStatus get status {
    if (warehouseCount == 0) return InventoryWarehouseDashboardStatus.setup;
    if (criticalWarehouseCount > 0 || lowStockItemCount > 0) {
      return InventoryWarehouseDashboardStatus.attention;
    }
    if (untrackedWarehouseCount > 0 || utilizationPercent >= 75) {
      return InventoryWarehouseDashboardStatus.watch;
    }
    return InventoryWarehouseDashboardStatus.healthy;
  }
}

class InventoryWarehouseBranchDetail {
  const InventoryWarehouseBranchDetail({
    required this.summary,
    required this.warehouses,
    required this.capacityLines,
    required this.stockRecords,
  });

  final InventoryWarehouseBranchSummary summary;
  final List<Warehouse> warehouses;
  final List<InventoryWarehouseCapacityLine> capacityLines;
  final List<InventoryStockRecord> stockRecords;

  String get branchFilterValue {
    return summary.branchKey.startsWith('warehouse-branch:')
        ? summary.branchName
        : summary.branchKey;
  }

  List<InventoryStockRecord> get attentionStockRecords {
    return [
      for (final record in stockRecords)
        if (record.needsAttention) record,
    ];
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

  List<InventoryWarehouseOperationSummary> get warehouseOperations {
    final capacityLineByWarehouse = {
      for (final line in capacityLines) line.warehouseId: line,
    };
    final stockRecordsByWarehouse = <String, List<InventoryStockRecord>>{};
    for (final record in stockRecords) {
      stockRecordsByWarehouse
          .putIfAbsent(record.warehouse.id, () => [])
          .add(record);
    }

    final operations = [
      for (final warehouse in warehouses)
        InventoryWarehouseOperationSummary(
          warehouse: warehouse,
          capacityLine:
              capacityLineByWarehouse[warehouse.id] ??
              InventoryWarehouseCapacityLine(
                warehouseId: warehouse.id,
                warehouseName: warehouse.name,
                branchId: warehouse.branchId,
                branchLabel: warehouse.branchLabel,
                locationLabel: warehouse.location,
                usedUnits: 0,
                productCount: 0,
                capacity: warehouse.capacity,
              ),
          stockRecords: stockRecordsByWarehouse[warehouse.id] ?? const [],
        ),
    ]..sort(_compareWarehouseOperations);

    return operations;
  }
}

class InventoryWarehouseOperationSummary {
  const InventoryWarehouseOperationSummary({
    required this.warehouse,
    required this.capacityLine,
    required this.stockRecords,
  });

  final Warehouse warehouse;
  final InventoryWarehouseCapacityLine capacityLine;
  final List<InventoryStockRecord> stockRecords;

  String get warehouseId => warehouse.id;

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

  int get attentionStockCount {
    return stockRecords.where((record) => record.needsAttention).length;
  }

  bool get needsAttention {
    return attentionStockCount > 0 ||
        capacityLine.status == InventoryWarehouseCapacityStatus.critical ||
        capacityLine.status == InventoryWarehouseCapacityStatus.untracked;
  }
}

InventoryWarehouseDashboardSnapshot buildInventoryWarehouseDashboardSnapshot({
  required List<InventoryBranch> branches,
  required List<Warehouse> warehouses,
  required List<InventoryItem> inventoryItems,
}) {
  final capacityLines = buildInventoryWarehouseCapacityLines(
    warehouses: warehouses,
    inventoryItems: inventoryItems,
  );
  final capacityLineByWarehouse = {
    for (final line in capacityLines) line.warehouseId: line,
  };
  final branchesById = {for (final branch in branches) branch.id: branch};
  final branchesByName = {
    for (final branch in branches) _normalizedKey(branch.name): branch,
  };
  final lowStockByWarehouse = <String, int>{};

  for (final item in inventoryItems) {
    if (!item.needsReorder) continue;
    lowStockByWarehouse[item.warehouseId] =
        (lowStockByWarehouse[item.warehouseId] ?? 0) + 1;
  }

  final accumulators = <String, _WarehouseBranchAccumulator>{};

  for (final branch in branches) {
    accumulators[branch.id] = _WarehouseBranchAccumulator.fromBranch(branch);
  }

  for (final warehouse in warehouses) {
    final branch = _branchForWarehouse(
      warehouse,
      branchesById: branchesById,
      branchesByName: branchesByName,
    );
    final branchKey = branch?.id ?? _branchKeyForWarehouse(warehouse);
    final accumulator =
        accumulators[branchKey] ??= _WarehouseBranchAccumulator.fromWarehouse(
          warehouse,
          branch,
        );
    final line = capacityLineByWarehouse[warehouse.id];

    accumulator.addWarehouse(
      line: line,
      lowStockItemCount: lowStockByWarehouse[warehouse.id] ?? 0,
    );
  }

  final branchSummaries =
      accumulators.values.map((accumulator) => accumulator.toSummary()).toList()
        ..sort(_compareBranchSummaries);

  var warehouseCount = 0;
  var trackedWarehouseCount = 0;
  var totalCapacity = 0.0;
  var usedUnits = 0;
  var availableUnits = 0.0;
  var lowStockItemCount = 0;
  var criticalWarehouseCount = 0;
  var untrackedWarehouseCount = 0;

  for (final summary in branchSummaries) {
    warehouseCount += summary.warehouseCount;
    trackedWarehouseCount += summary.trackedWarehouseCount;
    totalCapacity += summary.totalCapacity.toDouble();
    usedUnits += summary.usedUnits;
    availableUnits += summary.availableUnits.toDouble();
    lowStockItemCount += summary.lowStockItemCount;
    criticalWarehouseCount += summary.criticalWarehouseCount;
    untrackedWarehouseCount += summary.untrackedWarehouseCount;
  }

  return InventoryWarehouseDashboardSnapshot(
    branchSummaries: branchSummaries,
    branchCount: branchSummaries.length,
    activeBranchCount:
        branchSummaries
            .where(
              (summary) =>
                  summary.branchStatus == null ||
                  summary.branchStatus == InventoryBranchStatus.active,
            )
            .length,
    warehouseCount: warehouseCount,
    trackedWarehouseCount: trackedWarehouseCount,
    totalCapacity: totalCapacity,
    usedUnits: usedUnits,
    availableUnits: availableUnits,
    lowStockItemCount: lowStockItemCount,
    criticalWarehouseCount: criticalWarehouseCount,
    untrackedWarehouseCount: untrackedWarehouseCount,
  );
}

InventoryWarehouseBranchDetail? buildInventoryWarehouseBranchDetail({
  String? branchKey,
  required List<InventoryBranch> branches,
  required List<Warehouse> warehouses,
  required List<InventoryItem> inventoryItems,
  required List<Product> products,
}) {
  final snapshot = buildInventoryWarehouseDashboardSnapshot(
    branches: branches,
    warehouses: warehouses,
    inventoryItems: inventoryItems,
  );
  final summary = inventoryWarehouseBranchSummaryForKey(
    snapshot.branchSummaries,
    branchKey,
  );
  if (summary == null) return null;

  final branchWarehouses = [
    for (final warehouse in warehouses)
      if (inventoryWarehouseBranchKeyForWarehouse(warehouse, branches) ==
          summary.branchKey)
        warehouse,
  ]..sort((first, second) => first.name.compareTo(second.name));
  final warehouseIds = {for (final warehouse in branchWarehouses) warehouse.id};
  final capacityLines = [
    for (final line in buildInventoryWarehouseCapacityLines(
      warehouses: branchWarehouses,
      inventoryItems: inventoryItems,
    ))
      if (warehouseIds.contains(line.warehouseId)) line,
  ];
  final stockRecords = [
    for (final record in buildInventoryStockRecords(
      inventoryItems: inventoryItems,
      products: products,
      warehouses: warehouses,
    ))
      if (warehouseIds.contains(record.warehouse.id)) record,
  ];

  return InventoryWarehouseBranchDetail(
    summary: summary,
    warehouses: branchWarehouses,
    capacityLines: capacityLines,
    stockRecords: stockRecords,
  );
}

InventoryWarehouseBranchSummary? inventoryWarehouseBranchSummaryForKey(
  List<InventoryWarehouseBranchSummary> summaries,
  String? branchKey,
) {
  if (summaries.isEmpty) return null;

  final normalized = branchKey?.trim();
  if (normalized == null || normalized.isEmpty) return summaries.first;

  for (final summary in summaries) {
    if (summary.branchKey == normalized) return summary;
  }

  final normalizedName = _normalizedKey(normalized);
  for (final summary in summaries) {
    if (_normalizedKey(summary.branchName) == normalizedName) return summary;
  }

  return null;
}

String inventoryWarehouseBranchKeyForWarehouse(
  Warehouse warehouse,
  List<InventoryBranch> branches,
) {
  final branchesById = {for (final branch in branches) branch.id: branch};
  final branchesByName = {
    for (final branch in branches) _normalizedKey(branch.name): branch,
  };
  final branch = _branchForWarehouse(
    warehouse,
    branchesById: branchesById,
    branchesByName: branchesByName,
  );
  return branch?.id ?? _branchKeyForWarehouse(warehouse);
}

String inventoryWarehouseDashboardStatusLabel(
  InventoryWarehouseDashboardStatus status,
) {
  switch (status) {
    case InventoryWarehouseDashboardStatus.healthy:
      return 'Healthy';
    case InventoryWarehouseDashboardStatus.watch:
      return 'Watch';
    case InventoryWarehouseDashboardStatus.attention:
      return 'Attention';
    case InventoryWarehouseDashboardStatus.setup:
      return 'Setup';
  }
}

class _WarehouseBranchAccumulator {
  _WarehouseBranchAccumulator({
    required this.branchKey,
    required this.branchName,
    required this.cityLabel,
    this.branchStatus,
  });

  factory _WarehouseBranchAccumulator.fromBranch(InventoryBranch branch) {
    return _WarehouseBranchAccumulator(
      branchKey: branch.id,
      branchName: branch.nameLabel,
      cityLabel: branch.cityLabel,
      branchStatus: branch.status,
    );
  }

  factory _WarehouseBranchAccumulator.fromWarehouse(
    Warehouse warehouse,
    InventoryBranch? branch,
  ) {
    return _WarehouseBranchAccumulator(
      branchKey: branch?.id ?? _branchKeyForWarehouse(warehouse),
      branchName: branch?.nameLabel ?? warehouse.branchLabel,
      cityLabel: branch?.cityLabel ?? warehouse.location,
      branchStatus: branch?.status,
    );
  }

  final String branchKey;
  final String branchName;
  final String cityLabel;
  final InventoryBranchStatus? branchStatus;

  var warehouseCount = 0;
  var trackedWarehouseCount = 0;
  var totalCapacity = 0.0;
  var usedUnits = 0;
  var productCount = 0;
  var lowStockItemCount = 0;
  var criticalWarehouseCount = 0;
  var untrackedWarehouseCount = 0;

  void addWarehouse({
    required InventoryWarehouseCapacityLine? line,
    required int lowStockItemCount,
  }) {
    warehouseCount += 1;
    this.lowStockItemCount += lowStockItemCount;

    if (line == null) return;

    usedUnits += line.usedUnits;
    productCount += line.productCount;
    if (line.hasTrackedCapacity) {
      trackedWarehouseCount += 1;
      totalCapacity += line.capacity!.toDouble();
      if (line.status == InventoryWarehouseCapacityStatus.critical) {
        criticalWarehouseCount += 1;
      }
    } else {
      untrackedWarehouseCount += 1;
    }
  }

  InventoryWarehouseBranchSummary toSummary() {
    return InventoryWarehouseBranchSummary(
      branchKey: branchKey,
      branchName: branchName,
      cityLabel: cityLabel,
      branchStatus: branchStatus,
      warehouseCount: warehouseCount,
      trackedWarehouseCount: trackedWarehouseCount,
      totalCapacity: totalCapacity,
      usedUnits: usedUnits,
      productCount: productCount,
      lowStockItemCount: lowStockItemCount,
      criticalWarehouseCount: criticalWarehouseCount,
      untrackedWarehouseCount: untrackedWarehouseCount,
    );
  }
}

String _branchKeyForWarehouse(Warehouse warehouse) {
  final branchId = warehouse.branchId?.trim();
  if (branchId != null && branchId.isNotEmpty) return branchId;
  return 'warehouse-branch:${_normalizedKey(warehouse.branchLabel)}';
}

InventoryBranch? _branchForWarehouse(
  Warehouse warehouse, {
  required Map<String, InventoryBranch> branchesById,
  required Map<String, InventoryBranch> branchesByName,
}) {
  final branchId = warehouse.branchId?.trim();
  if (branchId != null && branchId.isNotEmpty) {
    return branchesById[branchId];
  }
  return branchesByName[_normalizedKey(warehouse.branchName)];
}

String _normalizedKey(String value) {
  return value.trim().toLowerCase();
}

int _compareBranchSummaries(
  InventoryWarehouseBranchSummary first,
  InventoryWarehouseBranchSummary second,
) {
  final statusRank = _statusRank(
    first.status,
  ).compareTo(_statusRank(second.status));
  if (statusRank != 0) return statusRank;

  final warehouseRank = second.warehouseCount.compareTo(first.warehouseCount);
  if (warehouseRank != 0) return warehouseRank;

  return first.branchName.compareTo(second.branchName);
}

int _compareWarehouseOperations(
  InventoryWarehouseOperationSummary first,
  InventoryWarehouseOperationSummary second,
) {
  final statusRank = _operationStatusRank(
    first.capacityLine.status,
  ).compareTo(_operationStatusRank(second.capacityLine.status));
  if (statusRank != 0) return statusRank;

  final attentionRank = second.attentionStockCount.compareTo(
    first.attentionStockCount,
  );
  if (attentionRank != 0) return attentionRank;

  final unitsRank = second.totalUnits.compareTo(first.totalUnits);
  if (unitsRank != 0) return unitsRank;

  return first.capacityLine.warehouseName.compareTo(
    second.capacityLine.warehouseName,
  );
}

int _operationStatusRank(InventoryWarehouseCapacityStatus status) {
  switch (status) {
    case InventoryWarehouseCapacityStatus.critical:
      return 0;
    case InventoryWarehouseCapacityStatus.untracked:
      return 1;
    case InventoryWarehouseCapacityStatus.high:
      return 2;
    case InventoryWarehouseCapacityStatus.moderate:
      return 3;
    case InventoryWarehouseCapacityStatus.low:
      return 4;
  }
}

int _statusRank(InventoryWarehouseDashboardStatus status) {
  switch (status) {
    case InventoryWarehouseDashboardStatus.attention:
      return 0;
    case InventoryWarehouseDashboardStatus.setup:
      return 1;
    case InventoryWarehouseDashboardStatus.watch:
      return 2;
    case InventoryWarehouseDashboardStatus.healthy:
      return 3;
  }
}
