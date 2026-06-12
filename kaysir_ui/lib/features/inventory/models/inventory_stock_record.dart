import '../../product/models/product.dart';
import 'inventory_branch_filter.dart';
import '../utils/inventory_label_utils.dart';
import '../utils/inventory_search_utils.dart';
import 'inventory_item.dart';
import 'warehouse.dart';

enum InventoryStockFilter { all, needsAttention, inStock }

enum InventoryStockStatus { outOfStock, lowStock, inStock }

class InventoryStockRecord {
  const InventoryStockRecord({
    required this.item,
    required this.product,
    required this.warehouse,
  });

  final InventoryItem item;
  final Product product;
  final Warehouse warehouse;

  String get productName => inventoryProductNameLabel(product.name);

  String get skuLabel => inventorySkuLabel(product.sku);

  String get categoryLabel => inventoryCategoryLabel(product.category);

  String get warehouseName => inventoryWarehouseNameLabel(warehouse.name);

  String get warehouseBranch => warehouse.branchLabel;

  String? get warehouseBranchId => warehouse.branchId;

  String get warehouseLocation => inventoryLocationLabel(warehouse.location);

  int get quantity => item.currentQuantity;

  int get reorderPoint => item.reorderPoint;

  int get reorderQuantity => item.reorderQuantity;

  double get inventoryValue => product.price * quantity;

  int get shortage => quantity >= reorderPoint ? 0 : reorderPoint - quantity;

  int get buffer => quantity <= reorderPoint ? 0 : quantity - reorderPoint;

  bool get needsAttention => status != InventoryStockStatus.inStock;

  InventoryStockStatus get status {
    if (quantity <= 0) {
      return InventoryStockStatus.outOfStock;
    }
    if (item.needsReorder) {
      return InventoryStockStatus.lowStock;
    }
    return InventoryStockStatus.inStock;
  }

  bool matchesQuery(String query) {
    return inventorySearchMatchesAny(query, [
      productName,
      skuLabel,
      categoryLabel,
      warehouseName,
      warehouseBranch,
      warehouseLocation,
    ]);
  }

  bool matchesFilter(InventoryStockFilter filter) {
    switch (filter) {
      case InventoryStockFilter.all:
        return true;
      case InventoryStockFilter.needsAttention:
        return needsAttention;
      case InventoryStockFilter.inStock:
        return status == InventoryStockStatus.inStock;
    }
  }

  bool matchesBranch(String? branchName) {
    return inventoryBranchFilterMatches(
      branchId: warehouseBranchId,
      branchLabel: warehouseBranch,
      selectedBranch: branchName,
    );
  }
}

List<InventoryStockRecord> buildInventoryStockRecords({
  required List<InventoryItem> inventoryItems,
  required List<Product> products,
  required List<Warehouse> warehouses,
}) {
  final productsById = {for (final product in products) product.id: product};
  final warehousesById = {
    for (final warehouse in warehouses) warehouse.id: warehouse,
  };

  return [
    for (final item in inventoryItems)
      InventoryStockRecord(
        item: item,
        product: productsById[item.productId] ?? _unknownProduct(item),
        warehouse: warehousesById[item.warehouseId] ?? _unknownWarehouse(item),
      ),
  ]..sort(_compareStockRecords);
}

List<InventoryStockRecord> filterInventoryStockRecords(
  List<InventoryStockRecord> records, {
  String query = '',
  String? warehouseId,
  String? branchName,
  InventoryStockFilter filter = InventoryStockFilter.all,
}) {
  return [
    for (final record in records)
      if ((warehouseId == null || record.warehouse.id == warehouseId) &&
          record.matchesBranch(branchName) &&
          record.matchesFilter(filter) &&
          record.matchesQuery(query))
        record,
  ];
}

int _compareStockRecords(
  InventoryStockRecord first,
  InventoryStockRecord second,
) {
  final statusRank = _stockStatusRank(
    first.status,
  ).compareTo(_stockStatusRank(second.status));
  if (statusRank != 0) return statusRank;

  final productRank = first.productName.compareTo(second.productName);
  if (productRank != 0) return productRank;

  return first.warehouseName.compareTo(second.warehouseName);
}

int _stockStatusRank(InventoryStockStatus status) {
  switch (status) {
    case InventoryStockStatus.outOfStock:
      return 0;
    case InventoryStockStatus.lowStock:
      return 1;
    case InventoryStockStatus.inStock:
      return 2;
  }
}

Product _unknownProduct(InventoryItem item) {
  return Product(
    id: item.productId,
    name: inventoryUnknownProductLabel,
    sku: 'Unknown',
    category: inventoryUncategorizedLabel,
    price: 0,
  );
}

Warehouse _unknownWarehouse(InventoryItem item) {
  return Warehouse(
    id: item.warehouseId,
    name: inventoryUnknownWarehouseLabel,
    location: '',
    description: '',
  );
}
