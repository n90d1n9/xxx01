import '../inventory_routes.dart';
import '../models/inventory_filter_deep_link.dart';
import '../models/inventory_warehouse_dashboard.dart';

/// Builds branch-detail route targets without depending on widget rendering.
class WarehouseBranchDetailRoutes {
  const WarehouseBranchDetailRoutes(this.detail);

  final InventoryWarehouseBranchDetail detail;

  String get hubRoute => InventoryRoutes.warehouseDashboard;

  String get stockRoute {
    return inventoryStockDeepLink(branch: detail.branchFilterValue);
  }

  String get movementsRoute {
    return inventoryMovementsDeepLink(branch: detail.branchFilterValue);
  }

  String get capacityRoute {
    return inventoryWarehouseCapacityDeepLink(branch: detail.branchFilterValue);
  }

  String warehouseDetailRoute(InventoryWarehouseOperationSummary operation) {
    return inventoryWarehouseDetailDeepLink(warehouseId: operation.warehouseId);
  }

  String operationStockRoute(InventoryWarehouseOperationSummary operation) {
    return inventoryStockDeepLink(
      branch: detail.branchFilterValue,
      warehouseId: operation.warehouseId,
    );
  }

  String operationMovementsRoute(InventoryWarehouseOperationSummary operation) {
    return inventoryMovementsDeepLink(
      branch: detail.branchFilterValue,
      warehouseId: operation.warehouseId,
    );
  }

  String operationCapacityRoute(InventoryWarehouseOperationSummary operation) {
    return inventoryWarehouseCapacityDeepLink(
      branch: detail.branchFilterValue,
      warehouseId: operation.warehouseId,
    );
  }
}
