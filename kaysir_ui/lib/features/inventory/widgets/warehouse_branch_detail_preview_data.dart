import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_branch.dart';
import '../models/inventory_item.dart';
import '../models/inventory_warehouse_dashboard.dart';
import '../models/warehouse.dart';

Widget inventoryWarehouseBranchDetailPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

InventoryWarehouseBranchDetail inventoryWarehouseBranchDetailPreviewDetail() {
  final detail = buildInventoryWarehouseBranchDetail(
    branchKey: 'branch-jakarta',
    branches: _previewBranches(),
    warehouses: _previewWarehouses(),
    inventoryItems: _previewInventoryItems(),
    products: _previewProducts(),
  );

  if (detail == null) {
    throw StateError('The warehouse branch detail preview fixture is invalid.');
  }

  return detail;
}

InventoryWarehouseOperationSummary inventoryWarehouseBranchOperationPreview([
  InventoryWarehouseBranchDetail? detail,
]) {
  final operations =
      (detail ?? inventoryWarehouseBranchDetailPreviewDetail())
          .warehouseOperations;

  return operations.firstWhere(
    (operation) => operation.attentionStockCount > 0,
    orElse: () => operations.first,
  );
}

List<InventoryBranch> _previewBranches() {
  return const [
    InventoryBranch(
      id: 'branch-jakarta',
      name: 'Jakarta Central',
      city: 'Jakarta',
      managerName: 'Rina Maharani',
      contact: 'jakarta@example.test',
      code: 'JKT',
      region: 'West Java',
      legalEntity: 'PT Kaysir Retail Indonesia',
      type: InventoryBranchType.fulfillmentHub,
      complianceTier: InventoryBranchComplianceTier.monitored,
      employeeCount: 48,
    ),
  ];
}

List<Warehouse> _previewWarehouses() {
  return [
    Warehouse(
      id: 'warehouse-main',
      name: 'Main Fulfillment Hub',
      branchId: 'branch-jakarta',
      branchName: 'Jakarta Central',
      location: 'Jakarta',
      description: 'Fast-moving inventory for same-day fulfillment',
      capacity: 100,
    ),
    Warehouse(
      id: 'warehouse-cold',
      name: 'Cold Chain Storage',
      branchId: 'branch-jakarta',
      branchName: 'Jakarta Central',
      location: 'Bekasi',
      description: 'Temperature-managed stock and fragile goods',
      capacity: 80,
    ),
    Warehouse(
      id: 'warehouse-overflow',
      name: 'Overflow Dock',
      branchId: 'branch-jakarta',
      branchName: 'Jakarta Central',
      location: 'Tangerang',
      description: 'Temporary staging for inbound purchase orders',
    ),
  ];
}

List<InventoryItem> _previewInventoryItems() {
  return [
    InventoryItem(
      id: 'stock-laptop',
      productId: 'product-laptop',
      warehouseId: 'warehouse-main',
      currentQuantity: 8,
      reorderPoint: 12,
      reorderQuantity: 32,
    ),
    InventoryItem(
      id: 'stock-scanner',
      productId: 'product-scanner',
      warehouseId: 'warehouse-main',
      currentQuantity: 0,
      reorderPoint: 6,
      reorderQuantity: 18,
    ),
    InventoryItem(
      id: 'stock-label-roll',
      productId: 'product-label-roll',
      warehouseId: 'warehouse-cold',
      currentQuantity: 36,
      reorderPoint: 10,
      reorderQuantity: 30,
    ),
    InventoryItem(
      id: 'stock-printer',
      productId: 'product-printer',
      warehouseId: 'warehouse-cold',
      currentQuantity: 22,
      reorderPoint: 12,
      reorderQuantity: 24,
    ),
  ];
}

List<Product> _previewProducts() {
  return [
    Product(
      id: 'product-laptop',
      name: 'Laptop',
      sku: 'LP-001',
      category: 'Electronics',
      price: 980,
    ),
    Product(
      id: 'product-scanner',
      name: 'Barcode Scanner',
      sku: 'SCN-004',
      category: 'Hardware',
      price: 120,
    ),
    Product(
      id: 'product-label-roll',
      name: 'Label Roll',
      sku: 'LBL-100',
      category: 'Supplies',
      price: 9,
    ),
    Product(
      id: 'product-printer',
      name: 'Thermal Printer',
      sku: 'PRN-022',
      category: 'Hardware',
      price: 180,
    ),
  ];
}
