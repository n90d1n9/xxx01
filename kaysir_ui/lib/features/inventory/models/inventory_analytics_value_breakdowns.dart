import '../../product/models/product.dart';
import '../utils/inventory_label_utils.dart';
import 'inventory_item.dart';
import 'warehouse.dart';

/// Stock value breakdowns used by inventory analytics summary panels.
class InventoryAnalyticsValueBreakdowns {
  const InventoryAnalyticsValueBreakdowns({
    required this.totalInventoryValue,
    required this.lowStockCount,
    required this.categoryValues,
    required this.warehouseValues,
  });

  final double totalInventoryValue;
  final int lowStockCount;
  final List<InventoryAnalyticsCategoryValue> categoryValues;
  final List<InventoryAnalyticsWarehouseValue> warehouseValues;
}

/// Inventory valuation summary for one product category.
class InventoryAnalyticsCategoryValue {
  const InventoryAnalyticsCategoryValue({
    required this.category,
    required this.value,
    required this.quantity,
    required this.productCount,
  });

  final String category;
  final double value;
  final int quantity;
  final int productCount;
}

/// Inventory valuation summary for one warehouse.
class InventoryAnalyticsWarehouseValue {
  const InventoryAnalyticsWarehouseValue({
    required this.warehouseId,
    required this.warehouseName,
    required this.value,
    required this.quantity,
    required this.productCount,
  });

  final String warehouseId;
  final String warehouseName;
  final double value;
  final int quantity;
  final int productCount;
}

/// Builds value, category, warehouse, and low-stock analytics from stock lines.
InventoryAnalyticsValueBreakdowns buildInventoryAnalyticsValueBreakdowns({
  required List<Product> products,
  required List<InventoryItem> inventoryItems,
  required List<Warehouse> warehouses,
}) {
  final productsById = {for (final product in products) product.id: product};
  final warehousesById = {
    for (final warehouse in warehouses) warehouse.id: warehouse,
  };
  final categoryBuilders = <String, _CategoryValueBuilder>{};
  final warehouseBuilders = <String, _WarehouseValueBuilder>{};
  var totalInventoryValue = 0.0;
  var lowStockCount = 0;

  for (final item in inventoryItems) {
    final product = productsById[item.productId];
    final unitPrice = product?.price ?? 0;
    final lineValue = unitPrice * item.currentQuantity;
    final category = inventoryCategoryLabel(product?.category);
    final warehouse = warehousesById[item.warehouseId];
    final warehouseName = inventoryFirstWarehouseNameLabel([
      warehouse?.name,
      item.warehouseId,
    ]);

    totalInventoryValue += lineValue;
    if (item.needsReorder) lowStockCount += 1;

    categoryBuilders
        .putIfAbsent(category, () => _CategoryValueBuilder(category))
        .add(item.productId, item.currentQuantity, lineValue);
    warehouseBuilders
        .putIfAbsent(
          item.warehouseId,
          () => _WarehouseValueBuilder(item.warehouseId, warehouseName),
        )
        .add(item.productId, item.currentQuantity, lineValue);
  }

  return InventoryAnalyticsValueBreakdowns(
    totalInventoryValue: totalInventoryValue,
    lowStockCount: lowStockCount,
    categoryValues: _sortedCategoryValues(categoryBuilders.values),
    warehouseValues: _sortedWarehouseValues(warehouseBuilders.values),
  );
}

List<InventoryAnalyticsCategoryValue> _sortedCategoryValues(
  Iterable<_CategoryValueBuilder> builders,
) {
  return [for (final builder in builders) builder.toValue()]..sort(
    (first, second) => _compareValueThenLabel(
      first.value,
      second.value,
      first.category,
      second.category,
    ),
  );
}

List<InventoryAnalyticsWarehouseValue> _sortedWarehouseValues(
  Iterable<_WarehouseValueBuilder> builders,
) {
  return [for (final builder in builders) builder.toValue()]..sort(
    (first, second) => _compareValueThenLabel(
      first.value,
      second.value,
      first.warehouseName,
      second.warehouseName,
    ),
  );
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

class _CategoryValueBuilder {
  _CategoryValueBuilder(this.category);

  final String category;
  final productIds = <String>{};
  var quantity = 0;
  var value = 0.0;

  void add(String productId, int lineQuantity, double lineValue) {
    productIds.add(productId);
    quantity += lineQuantity;
    value += lineValue;
  }

  InventoryAnalyticsCategoryValue toValue() {
    return InventoryAnalyticsCategoryValue(
      category: category,
      value: value,
      quantity: quantity,
      productCount: productIds.length,
    );
  }
}

class _WarehouseValueBuilder {
  _WarehouseValueBuilder(this.warehouseId, this.warehouseName);

  final String warehouseId;
  final String warehouseName;
  final productIds = <String>{};
  var quantity = 0;
  var value = 0.0;

  void add(String productId, int lineQuantity, double lineValue) {
    productIds.add(productId);
    quantity += lineQuantity;
    value += lineValue;
  }

  InventoryAnalyticsWarehouseValue toValue() {
    return InventoryAnalyticsWarehouseValue(
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      value: value,
      quantity: quantity,
      productCount: productIds.length,
    );
  }
}
