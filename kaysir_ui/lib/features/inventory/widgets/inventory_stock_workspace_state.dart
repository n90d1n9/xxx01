import '../../product/models/product.dart';
import '../models/inventory_branch_filter.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_movement_record.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';

class InventoryStockWorkspaceFilterState {
  const InventoryStockWorkspaceFilterState({
    this.query = '',
    this.branch,
    this.warehouseId,
    this.filter = InventoryStockFilter.all,
  });

  factory InventoryStockWorkspaceFilterState.initial({
    String? branch,
    String? warehouseId,
    String query = '',
    InventoryStockFilter filter = InventoryStockFilter.all,
  }) {
    return InventoryStockWorkspaceFilterState(
      query: query.trim(),
      branch: branch,
      warehouseId: warehouseId,
      filter: filter,
    );
  }

  final String query;
  final String? branch;
  final String? warehouseId;
  final InventoryStockFilter filter;

  InventoryStockWorkspaceFilterState withQuery(String value) {
    return InventoryStockWorkspaceFilterState(
      query: value,
      branch: branch,
      warehouseId: warehouseId,
      filter: filter,
    );
  }

  InventoryStockWorkspaceFilterState withBranch(String? value) {
    return InventoryStockWorkspaceFilterState(
      query: query,
      branch: value,
      warehouseId: null,
      filter: filter,
    );
  }

  InventoryStockWorkspaceFilterState withWarehouse(String? value) {
    return InventoryStockWorkspaceFilterState(
      query: query,
      branch: branch,
      warehouseId: value,
      filter: filter,
    );
  }

  InventoryStockWorkspaceFilterState withFilter(InventoryStockFilter value) {
    return InventoryStockWorkspaceFilterState(
      query: query,
      branch: branch,
      warehouseId: warehouseId,
      filter: value,
    );
  }

  InventoryStockWorkspaceFilterState reset() {
    return const InventoryStockWorkspaceFilterState();
  }

  String deepLink(InventoryStockWorkspaceSelection selection) {
    return inventoryStockDeepLink(
      branch: selection.selectedBranch,
      warehouseId: selection.selectedWarehouseId,
      query: query,
      filter: filter,
    );
  }
}

class InventoryStockWorkspaceSelection {
  const InventoryStockWorkspaceSelection({
    required this.branchOptions,
    required this.branchLabels,
    required this.warehouseOptions,
    required this.selectedBranch,
    required this.selectedWarehouseId,
  });

  final List<InventoryBranchFilterOption> branchOptions;
  final List<String> branchLabels;
  final List<Warehouse> warehouseOptions;
  final String? selectedBranch;
  final String? selectedWarehouseId;
}

InventoryStockWorkspaceSelection resolveInventoryStockWorkspaceSelection({
  required List<Warehouse> warehouses,
  required InventoryStockWorkspaceFilterState filters,
}) {
  final branchOptions = inventoryBranchOptionsForWarehouses(warehouses);
  final selectedBranch = inventoryValidBranchFilterValue(
    filters.branch,
    branchOptions,
  );
  final warehouseOptions = filterInventoryWarehousesByBranch(
    warehouses,
    selectedBranch: selectedBranch,
  );
  final selectedWarehouseId =
      warehouseOptions.any((warehouse) => warehouse.id == filters.warehouseId)
          ? filters.warehouseId
          : null;

  return InventoryStockWorkspaceSelection(
    branchOptions: branchOptions,
    branchLabels: [for (final option in branchOptions) option.label],
    warehouseOptions: warehouseOptions,
    selectedBranch: selectedBranch,
    selectedWarehouseId: selectedWarehouseId,
  );
}

List<InventoryStockRecord> filterInventoryStockWorkspaceRecords({
  required List<InventoryStockRecord> records,
  required InventoryStockWorkspaceFilterState filters,
  required InventoryStockWorkspaceSelection selection,
}) {
  return filterInventoryStockRecords(
    records,
    query: filters.query,
    warehouseId: selection.selectedWarehouseId,
    branchName: selection.selectedBranch,
    filter: filters.filter,
  );
}

List<InventoryMovementRecord> inventoryStockWorkspaceRelatedMovements({
  required InventoryStockRecord record,
  required List<InventoryMovementRecord> movementRecords,
}) {
  return [
    for (final movementRecord in movementRecords)
      if (movementRecord.movement.productId == record.product.id &&
          (movementRecord.sourceWarehouse.id == record.warehouse.id ||
              movementRecord.destinationWarehouse?.id == record.warehouse.id))
        movementRecord,
  ];
}

String inventoryStockWorkspaceProductName(
  List<Product> products,
  String productId,
) {
  for (final product in products) {
    if (product.id == productId) return product.name;
  }
  return 'Product';
}

String inventoryStockWorkspaceWarehouseName(
  List<Warehouse> warehouses,
  String warehouseId,
) {
  for (final warehouse in warehouses) {
    if (warehouse.id == warehouseId) return warehouse.name;
  }
  return 'warehouse';
}
