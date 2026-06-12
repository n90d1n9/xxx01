import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_item.dart';
import '../models/inventory_movement.dart';
import '../models/inventory_movement_record.dart';
import '../models/inventory_stock_record.dart';
import '../models/inventory_warehouse_capacity_report.dart';
import '../models/inventory_warehouse_detail.dart';
import '../models/movement_type.dart';
import '../models/warehouse.dart';

Widget inventoryWarehouseDetailPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

InventoryWarehouseDetail inventoryWarehouseStockPreviewDetail() {
  final warehouse = _previewMainWarehouse();
  final products = _previewProducts();
  final stockRecords = [
    _previewStockRecord(
      id: 'stock-tablet',
      product: products[0],
      warehouse: warehouse,
      quantity: 0,
      reorderPoint: 8,
      reorderQuantity: 24,
    ),
    _previewStockRecord(
      id: 'stock-chair',
      product: products[1],
      warehouse: warehouse,
      quantity: 6,
      reorderPoint: 10,
      reorderQuantity: 18,
    ),
    _previewStockRecord(
      id: 'stock-printer',
      product: products[2],
      warehouse: warehouse,
      quantity: 72,
      reorderPoint: 16,
      reorderQuantity: 30,
    ),
  ];

  return _previewDetail(
    warehouse: warehouse,
    productCount: products.length,
    usedUnits: 78,
    stockRecords: stockRecords,
  );
}

InventoryWarehouseDetail inventoryWarehouseMovementPreviewDetail() {
  final mainWarehouse = _previewMainWarehouse();
  final overflowWarehouse = Warehouse(
    id: 'warehouse-overflow',
    name: 'Overflow Hub',
    branchId: 'central',
    branchName: 'Central Branch',
    location: 'Bekasi',
    capacity: 90,
  );
  final products = _previewProducts();
  final movementRecords = [
    _previewMovementRecord(
      id: 'move-transfer',
      product: products[0],
      sourceWarehouse: mainWarehouse,
      destinationWarehouse: overflowWarehouse,
      quantity: 12,
      type: MovementType.transfer,
      date: DateTime(2026, 6, 9, 14),
      reference: 'TR-221',
    ),
    _previewMovementRecord(
      id: 'move-issue',
      product: products[1],
      sourceWarehouse: mainWarehouse,
      quantity: 18,
      type: MovementType.issue,
      date: DateTime(2026, 6, 9, 12),
      reference: 'SO-778',
    ),
    _previewMovementRecord(
      id: 'move-receipt',
      product: products[0],
      sourceWarehouse: mainWarehouse,
      quantity: 42,
      type: MovementType.receipt,
      date: DateTime(2026, 6, 9, 10),
      reference: 'PO-1024',
    ),
  ];

  return _previewDetail(
    warehouse: mainWarehouse,
    productCount: products.length,
    usedUnits: 72,
    movementRecords: movementRecords,
  );
}

InventoryWarehouseCategoryMixLine inventoryWarehouseCategoryMixPreviewLine([
  InventoryWarehouseDetail? detail,
]) {
  final resolvedDetail = detail ?? inventoryWarehouseStockPreviewDetail();
  return resolvedDetail.categoryMixLines.first;
}

InventoryWarehouseMovementFlowLine inventoryWarehouseMovementFlowPreviewLine(
  InventoryWarehouseDetail detail,
) {
  return detail.activeMovementFlowLines.first;
}

Warehouse _previewMainWarehouse() {
  return Warehouse(
    id: 'warehouse-main',
    name: 'Main Fulfillment Hub',
    branchId: 'central',
    branchName: 'Central Branch',
    location: 'Jakarta',
    capacity: 140,
  );
}

List<Product> _previewProducts() {
  return [
    Product(
      id: 'product-tablet',
      name: 'Tablet',
      sku: 'TAB-01',
      category: 'Electronics',
      price: 320,
    ),
    Product(
      id: 'product-chair',
      name: 'Office Chair',
      sku: 'CHR-01',
      category: 'Furniture',
      price: 80,
    ),
    Product(
      id: 'product-printer',
      name: 'Thermal Printer',
      sku: 'PRN-01',
      category: 'Equipment',
      price: 140,
    ),
  ];
}

InventoryStockRecord _previewStockRecord({
  required String id,
  required Product product,
  required Warehouse warehouse,
  required int quantity,
  required int reorderPoint,
  required int reorderQuantity,
}) {
  return InventoryStockRecord(
    item: InventoryItem(
      id: id,
      productId: product.id,
      warehouseId: warehouse.id,
      currentQuantity: quantity,
      reorderPoint: reorderPoint,
      reorderQuantity: reorderQuantity,
    ),
    product: product,
    warehouse: warehouse,
  );
}

InventoryMovementRecord _previewMovementRecord({
  required String id,
  required Product product,
  required Warehouse sourceWarehouse,
  Warehouse? destinationWarehouse,
  required int quantity,
  required MovementType type,
  required DateTime date,
  required String reference,
}) {
  return InventoryMovementRecord(
    movement: InventoryMovement(
      id: id,
      productId: product.id,
      sourceWarehouseId: sourceWarehouse.id,
      destinationWarehouseId: destinationWarehouse?.id,
      quantity: quantity,
      type: type,
      date: date,
      reference: reference,
    ),
    product: product,
    sourceWarehouse: sourceWarehouse,
    destinationWarehouse: destinationWarehouse,
  );
}

InventoryWarehouseDetail _previewDetail({
  required Warehouse warehouse,
  required int productCount,
  required int usedUnits,
  List<InventoryStockRecord> stockRecords = const [],
  List<InventoryMovementRecord> movementRecords = const [],
}) {
  return InventoryWarehouseDetail(
    warehouse: warehouse,
    capacityLine: InventoryWarehouseCapacityLine(
      warehouseId: warehouse.id,
      warehouseName: warehouse.name,
      branchId: warehouse.branchId,
      branchLabel: warehouse.branchLabel,
      locationLabel: warehouse.location,
      usedUnits: usedUnits,
      productCount: productCount,
      capacity: warehouse.capacity,
    ),
    stockRecords: stockRecords,
    movementRecords: movementRecords,
  );
}
