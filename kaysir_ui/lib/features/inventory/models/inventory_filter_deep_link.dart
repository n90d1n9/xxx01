import '../inventory_routes.dart';
import 'inventory_movement_record.dart';
import 'inventory_stock_record.dart';

/// Query parameter names shared by inventory deep-link builders and parsers.
class InventoryFilterQueryKeys {
  const InventoryFilterQueryKeys._();

  static const branch = 'branch';
  static const warehouse = 'warehouse';
  static const query = 'q';
  static const filter = 'filter';
}

String inventoryStockDeepLink({
  String? branch,
  String? warehouseId,
  String? query,
  InventoryStockFilter filter = InventoryStockFilter.all,
}) {
  return _routeWithQuery(InventoryRoutes.stock, {
    InventoryFilterQueryKeys.branch: branch,
    InventoryFilterQueryKeys.warehouse: warehouseId,
    InventoryFilterQueryKeys.query: query,
    InventoryFilterQueryKeys.filter: inventoryStockFilterQueryValue(filter),
  });
}

String inventoryMovementsDeepLink({
  String? branch,
  String? warehouseId,
  String? query,
  InventoryMovementFilter filter = InventoryMovementFilter.all,
}) {
  return _routeWithQuery(InventoryRoutes.movements, {
    InventoryFilterQueryKeys.branch: branch,
    InventoryFilterQueryKeys.warehouse: warehouseId,
    InventoryFilterQueryKeys.query: query,
    InventoryFilterQueryKeys.filter: inventoryMovementFilterQueryValue(filter),
  });
}

String inventoryPurchaseOrdersDeepLink({String? query}) {
  return _routeWithQuery(InventoryRoutes.purchaseOrders, {
    InventoryFilterQueryKeys.query: query,
  });
}

String inventoryWarehouseBranchDetailDeepLink({required String branchKey}) {
  return _routeWithQuery(InventoryRoutes.warehouseBranchDetail, {
    InventoryFilterQueryKeys.branch: branchKey,
  });
}

String inventoryWarehouseDetailDeepLink({required String warehouseId}) {
  return _routeWithQuery(InventoryRoutes.warehouseDetail, {
    InventoryFilterQueryKeys.warehouse: warehouseId,
  });
}

String inventoryWarehouseCapacityDeepLink({
  String? branch,
  String? warehouseId,
}) {
  return _routeWithQuery(InventoryRoutes.warehouseCapacity, {
    InventoryFilterQueryKeys.branch: branch,
    InventoryFilterQueryKeys.warehouse: warehouseId,
  });
}

String inventoryBrowserDeepLink(String route, {Uri? baseUri}) {
  final base = baseUri ?? Uri.base;
  final normalizedRoute = route.startsWith('/') ? route : '/$route';

  if (base.scheme.isEmpty && base.host.isEmpty) {
    return normalizedRoute;
  }

  final buffer = StringBuffer();
  buffer
    ..write(base.scheme)
    ..write('://');
  if (base.userInfo.isNotEmpty) {
    buffer
      ..write(base.userInfo)
      ..write('@');
  }
  buffer.write(base.host);
  if (base.hasPort) {
    buffer
      ..write(':')
      ..write(base.port);
  }

  final basePath =
      base.path.isEmpty || !base.path.endsWith('/') ? '/' : base.path;
  buffer
    ..write(basePath)
    ..write('#')
    ..write(normalizedRoute);

  return buffer.toString();
}

String? inventoryStockFilterQueryValue(InventoryStockFilter filter) {
  switch (filter) {
    case InventoryStockFilter.all:
      return null;
    case InventoryStockFilter.needsAttention:
      return 'attention';
    case InventoryStockFilter.inStock:
      return 'in_stock';
  }
}

InventoryStockFilter inventoryStockFilterFromQuery(String? value) {
  switch (_normalizeQueryValue(value)) {
    case 'attention':
    case 'needs_attention':
    case 'low_stock':
      return InventoryStockFilter.needsAttention;
    case 'in_stock':
    case 'instock':
      return InventoryStockFilter.inStock;
    case 'all':
    case null:
    default:
      return InventoryStockFilter.all;
  }
}

String? inventoryMovementFilterQueryValue(InventoryMovementFilter filter) {
  switch (filter) {
    case InventoryMovementFilter.all:
      return null;
    case InventoryMovementFilter.inbound:
      return 'inbound';
    case InventoryMovementFilter.outbound:
      return 'outbound';
    case InventoryMovementFilter.transfer:
      return 'transfer';
    case InventoryMovementFilter.adjustment:
      return 'adjustment';
    case InventoryMovementFilter.stockOpname:
      return 'stock_opname';
  }
}

InventoryMovementFilter inventoryMovementFilterFromQuery(String? value) {
  switch (_normalizeQueryValue(value)) {
    case 'inbound':
      return InventoryMovementFilter.inbound;
    case 'outbound':
      return InventoryMovementFilter.outbound;
    case 'transfer':
      return InventoryMovementFilter.transfer;
    case 'adjustment':
    case 'adjust':
      return InventoryMovementFilter.adjustment;
    case 'stock_opname':
    case 'stock-opname':
    case 'audit':
      return InventoryMovementFilter.stockOpname;
    case 'all':
    case null:
    default:
      return InventoryMovementFilter.all;
  }
}

String _routeWithQuery(String path, Map<String, String?> values) {
  final queryParameters = <String, String>{};

  for (final entry in values.entries) {
    final value = entry.value?.trim();
    if (value != null && value.isNotEmpty) {
      queryParameters[entry.key] = value;
    }
  }

  return Uri(
    path: path,
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  ).toString();
}

String? _normalizeQueryValue(String? value) {
  final normalized = value?.trim().toLowerCase();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
