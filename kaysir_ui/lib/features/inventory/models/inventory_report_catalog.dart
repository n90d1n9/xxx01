enum InventoryReportType {
  valuation,
  movementHistory,
  lowStock,
  warehouseCapacity,
}

class InventoryReportDefinition {
  const InventoryReportDefinition({
    required this.type,
    required this.title,
    required this.description,
  });

  final InventoryReportType type;
  final String title;
  final String description;
}

class InventoryReportHubStats {
  const InventoryReportHubStats({
    required this.productCount,
    required this.stockLineCount,
    required this.movementCount,
    required this.lowStockCount,
    required this.warehouseCount,
  });

  final int productCount;
  final int stockLineCount;
  final int movementCount;
  final int lowStockCount;
  final int warehouseCount;

  int get readyReportCount {
    return inventoryReportDefinitions
        .where((definition) => canGenerate(definition.type))
        .length;
  }

  bool canGenerate(InventoryReportType type) {
    switch (type) {
      case InventoryReportType.valuation:
        return productCount > 0 && stockLineCount > 0 && warehouseCount > 0;
      case InventoryReportType.movementHistory:
        return productCount > 0 && movementCount > 0 && warehouseCount > 0;
      case InventoryReportType.lowStock:
        return productCount > 0;
      case InventoryReportType.warehouseCapacity:
        return warehouseCount > 0;
    }
  }

  String dataLabelFor(InventoryReportType type) {
    switch (type) {
      case InventoryReportType.valuation:
        return '$stockLineCount stock lines';
      case InventoryReportType.movementHistory:
        return '$movementCount movements';
      case InventoryReportType.lowStock:
        return '$lowStockCount alerts';
      case InventoryReportType.warehouseCapacity:
        return '$warehouseCount warehouses';
    }
  }

  String readinessLabelFor(InventoryReportType type) {
    if (canGenerate(type)) return 'Ready';

    switch (type) {
      case InventoryReportType.valuation:
        return 'Needs stock data';
      case InventoryReportType.movementHistory:
        return 'Needs movements';
      case InventoryReportType.lowStock:
        return 'Needs products';
      case InventoryReportType.warehouseCapacity:
        return 'Needs warehouses';
    }
  }
}

const inventoryReportDefinitions = [
  InventoryReportDefinition(
    type: InventoryReportType.valuation,
    title: 'Inventory Valuation',
    description: 'Current stock value by product and warehouse.',
  ),
  InventoryReportDefinition(
    type: InventoryReportType.movementHistory,
    title: 'Stock Movement History',
    description: 'Inbound, outbound, transfer, and adjustment activity.',
  ),
  InventoryReportDefinition(
    type: InventoryReportType.lowStock,
    title: 'Low Stock Report',
    description: 'Products below reorder point with replenishment urgency.',
  ),
  InventoryReportDefinition(
    type: InventoryReportType.warehouseCapacity,
    title: 'Warehouse Capacity',
    description: 'Storage usage, available capacity, and product spread.',
  ),
];

InventoryReportHubStats buildInventoryReportHubStats({
  required int productCount,
  required int stockLineCount,
  required int movementCount,
  required int lowStockCount,
  required int warehouseCount,
}) {
  return InventoryReportHubStats(
    productCount: productCount,
    stockLineCount: stockLineCount,
    movementCount: movementCount,
    lowStockCount: lowStockCount,
    warehouseCount: warehouseCount,
  );
}
