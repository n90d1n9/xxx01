import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';
import 'inventory_analytics_branch_models.dart';
import 'inventory_analytics_branch_movements.dart';
import 'inventory_branch_filter.dart';
import 'inventory_item.dart';
import 'inventory_movement.dart';
import 'warehouse.dart';

export 'inventory_analytics_branch_models.dart';
export 'inventory_analytics_branch_movements.dart';

/// Builds branch value and branch drill-down analytics from stock source data.
InventoryAnalyticsBranchBreakdowns buildInventoryAnalyticsBranchBreakdowns({
  required List<Product> products,
  required List<InventoryItem> inventoryItems,
  required List<InventoryMovement> movements,
  required List<Warehouse> warehouses,
}) {
  final productsById = {for (final product in products) product.id: product};
  final warehousesById = {
    for (final warehouse in warehouses) warehouse.id: warehouse,
  };
  final branchBuilders = <String, _BranchDetailBuilder>{};

  for (final warehouse in warehouses) {
    final branchId = inventoryBranchFilterValueForWarehouse(warehouse);
    branchBuilders
        .putIfAbsent(
          branchId,
          () => _BranchDetailBuilder(branchId, warehouse.branchLabel),
        )
        .addWarehouse(
          warehouseId: warehouse.id,
          warehouseName: inventoryWarehouseNameLabel(warehouse.name),
          locationLabel: inventoryLocationLabel(warehouse.location),
        );
  }

  for (final item in inventoryItems) {
    final product = productsById[item.productId];
    final unitPrice = product?.price ?? 0;
    final lineValue = unitPrice * item.currentQuantity;
    final warehouse = warehousesById[item.warehouseId];
    final warehouseName = inventoryFirstWarehouseNameLabel([
      warehouse?.name,
      item.warehouseId,
    ]);
    final warehouseLocation = inventoryLocationLabel(warehouse?.location);
    final branchId =
        warehouse == null
            ? inventoryDefaultWarehouseBranchName
            : inventoryBranchFilterValueForWarehouse(warehouse);
    final branchName =
        warehouse?.branchLabel ?? inventoryDefaultWarehouseBranchName;

    branchBuilders
        .putIfAbsent(branchId, () => _BranchDetailBuilder(branchId, branchName))
        .addStock(
          productId: item.productId,
          warehouseId: item.warehouseId,
          warehouseName: warehouseName,
          locationLabel: warehouseLocation,
          lineQuantity: item.currentQuantity,
          lineValue: lineValue,
          isLowStock: item.needsReorder,
        );
  }

  _addMovementsToBranchDetails(
    branchBuilders: branchBuilders,
    movements: movements,
    productsById: productsById,
    warehousesById: warehousesById,
  );

  final branchDetails = _sortedBranchDetails(branchBuilders.values);

  return InventoryAnalyticsBranchBreakdowns(
    branchValues: _branchValuesFromDetails(branchDetails),
    branchDetails: branchDetails,
  );
}

void _addMovementsToBranchDetails({
  required Map<String, _BranchDetailBuilder> branchBuilders,
  required List<InventoryMovement> movements,
  required Map<String, Product> productsById,
  required Map<String, Warehouse> warehousesById,
}) {
  for (final movement in movements) {
    final destinationWarehouseId = movement.destinationWarehouseId;
    final sourceWarehouse = warehousesById[movement.sourceWarehouseId];
    final destinationWarehouse =
        destinationWarehouseId == null
            ? null
            : warehousesById[destinationWarehouseId];
    final sourceWarehouseName = inventoryFirstWarehouseNameLabel([
      sourceWarehouse?.name,
      movement.sourceWarehouseId,
    ]);
    final destinationWarehouseName =
        destinationWarehouseId == null
            ? null
            : inventoryFirstWarehouseNameLabel([
              destinationWarehouse?.name,
              destinationWarehouseId,
            ]);
    final movementDetail = buildInventoryAnalyticsBranchMovement(
      movement: movement,
      product: productsById[movement.productId],
      sourceWarehouseName: sourceWarehouseName,
      destinationWarehouseName: destinationWarehouseName,
    );
    final visitedBranchIds = <String>{};

    void addToBranch(Warehouse? warehouse) {
      final branchId =
          warehouse == null
              ? inventoryDefaultWarehouseBranchName
              : inventoryBranchFilterValueForWarehouse(warehouse);
      if (!visitedBranchIds.add(branchId)) return;

      final branchName =
          warehouse?.branchLabel ?? inventoryDefaultWarehouseBranchName;
      branchBuilders
          .putIfAbsent(
            branchId,
            () => _BranchDetailBuilder(branchId, branchName),
          )
          .addMovement(movementDetail);
    }

    addToBranch(sourceWarehouse);
    if (destinationWarehouseId != null) {
      addToBranch(destinationWarehouse);
    }
  }
}

List<InventoryAnalyticsBranchDetail> _sortedBranchDetails(
  Iterable<_BranchDetailBuilder> builders,
) {
  return [for (final builder in builders) builder.toDetail()]..sort(
    (first, second) => _compareValueThenLabel(
      first.value,
      second.value,
      first.branchName,
      second.branchName,
    ),
  );
}

List<InventoryAnalyticsBranchValue> _branchValuesFromDetails(
  List<InventoryAnalyticsBranchDetail> details,
) {
  return [
    for (final detail in details)
      InventoryAnalyticsBranchValue(
        branchId: detail.branchId,
        branchName: detail.branchName,
        value: detail.value,
        quantity: detail.quantity,
        warehouseCount: detail.warehouseCount,
        productCount: detail.productCount,
      ),
  ];
}

int _compareValueThenLabel(
  double firstValue,
  double secondValue,
  String firstLabel,
  String secondLabel,
) {
  final valueComparison = secondValue.compareTo(firstValue);
  if (valueComparison != 0) return valueComparison;
  return firstLabel.compareTo(secondLabel);
}

class _BranchDetailBuilder {
  _BranchDetailBuilder(this.branchId, this.branchName);

  final String branchId;
  final String branchName;
  final productIds = <String>{};
  final warehouseIds = <String>{};
  final warehouseBuilders = <String, _BranchWarehouseDetailBuilder>{};
  final movements = <InventoryAnalyticsBranchMovement>[];
  var quantity = 0;
  var value = 0.0;
  var lowStockCount = 0;

  void addWarehouse({
    required String warehouseId,
    required String warehouseName,
    required String locationLabel,
  }) {
    warehouseIds.add(warehouseId);
    warehouseBuilders.putIfAbsent(
      warehouseId,
      () => _BranchWarehouseDetailBuilder(
        warehouseId: warehouseId,
        warehouseName: warehouseName,
        locationLabel: locationLabel,
      ),
    );
  }

  void addStock({
    required String productId,
    required String warehouseId,
    required String warehouseName,
    required String locationLabel,
    required int lineQuantity,
    required double lineValue,
    required bool isLowStock,
  }) {
    addWarehouse(
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      locationLabel: locationLabel,
    );
    productIds.add(productId);
    quantity += lineQuantity;
    value += lineValue;
    if (isLowStock) lowStockCount += 1;
    warehouseBuilders[warehouseId]!.addStock(
      productId: productId,
      lineQuantity: lineQuantity,
      lineValue: lineValue,
      isLowStock: isLowStock,
    );
  }

  void addMovement(InventoryAnalyticsBranchMovement movement) {
    movements.add(movement);
  }

  InventoryAnalyticsBranchDetail toDetail() {
    final branchWarehouses = [
      for (final builder in warehouseBuilders.values) builder.toWarehouse(),
    ]..sort(
      (first, second) => _compareValueThenLabel(
        first.value,
        second.value,
        first.warehouseName,
        second.warehouseName,
      ),
    );
    final recentMovements = [...movements]..sort((first, second) {
      final dateComparison = second.date.compareTo(first.date);
      if (dateComparison != 0) return dateComparison;
      return first.productName.compareTo(second.productName);
    });

    return InventoryAnalyticsBranchDetail(
      branchId: branchId,
      branchName: branchName,
      value: value,
      quantity: quantity,
      lowStockCount: lowStockCount,
      warehouseCount: warehouseIds.length,
      productCount: productIds.length,
      movementCount: movements.length,
      warehouses: branchWarehouses,
      recentMovements:
          recentMovements.length <= 5
              ? recentMovements
              : recentMovements.sublist(0, 5),
    );
  }
}

class _BranchWarehouseDetailBuilder {
  _BranchWarehouseDetailBuilder({
    required this.warehouseId,
    required this.warehouseName,
    required this.locationLabel,
  });

  final String warehouseId;
  final String warehouseName;
  final String locationLabel;
  final productIds = <String>{};
  var quantity = 0;
  var value = 0.0;
  var lowStockCount = 0;

  void addStock({
    required String productId,
    required int lineQuantity,
    required double lineValue,
    required bool isLowStock,
  }) {
    productIds.add(productId);
    quantity += lineQuantity;
    value += lineValue;
    if (isLowStock) lowStockCount += 1;
  }

  InventoryAnalyticsBranchWarehouse toWarehouse() {
    return InventoryAnalyticsBranchWarehouse(
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      locationLabel: locationLabel,
      value: value,
      quantity: quantity,
      lowStockCount: lowStockCount,
      productCount: productIds.length,
    );
  }
}
