import 'package:flutter/material.dart';

import '../models/inventory_analytics_dashboard.dart';
import '../models/movement_type.dart';

/// Wraps analytics preview widgets in the standard Material preview shell.
Widget inventoryAnalyticsPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

/// Returns a representative top-level analytics summary for previews.
InventoryAnalyticsSummary inventoryAnalyticsPreviewSummary() {
  return const InventoryAnalyticsSummary(
    productCount: 48,
    warehouseCount: 5,
    lowStockCount: 3,
    totalInventoryValue: 21700,
    inboundQuantity: 36,
    outboundQuantity: 20,
  );
}

/// Returns a representative analytics dashboard used by previews and tests.
InventoryAnalyticsDashboard inventoryAnalyticsPreviewDashboard() {
  return InventoryAnalyticsDashboard(
    summary: inventoryAnalyticsPreviewSummary(),
    categoryValues: inventoryAnalyticsPreviewCategoryValues(),
    movementTrends: inventoryAnalyticsPreviewMovementTrends(),
    branchValues: inventoryAnalyticsPreviewBranchValues(),
    branchDetails: inventoryAnalyticsPreviewBranchDetails(),
    warehouseValues: inventoryAnalyticsPreviewWarehouseValues(),
  );
}

/// Returns representative category value rows for analytics previews.
List<InventoryAnalyticsCategoryValue>
inventoryAnalyticsPreviewCategoryValues() {
  return const [
    InventoryAnalyticsCategoryValue(
      category: 'Electronics',
      value: 12500,
      quantity: 32,
      productCount: 8,
    ),
    InventoryAnalyticsCategoryValue(
      category: 'Accessories',
      value: 6800,
      quantity: 91,
      productCount: 14,
    ),
    InventoryAnalyticsCategoryValue(
      category: 'Consumables',
      value: 2400,
      quantity: 220,
      productCount: 6,
    ),
  ];
}

/// Returns representative branch value rows for analytics previews.
List<InventoryAnalyticsBranchValue> inventoryAnalyticsPreviewBranchValues() {
  return const [
    InventoryAnalyticsBranchValue(
      branchId: 'branch-jakarta',
      branchName: 'Jakarta Central',
      value: 14200,
      quantity: 186,
      warehouseCount: 2,
      productCount: 24,
    ),
    InventoryAnalyticsBranchValue(
      branchId: 'branch-surabaya',
      branchName: 'Surabaya North',
      value: 7500,
      quantity: 157,
      warehouseCount: 1,
      productCount: 18,
    ),
  ];
}

/// Returns representative warehouse value rows for analytics previews.
List<InventoryAnalyticsWarehouseValue>
inventoryAnalyticsPreviewWarehouseValues() {
  return const [
    InventoryAnalyticsWarehouseValue(
      warehouseId: 'main',
      warehouseName: 'Main Warehouse',
      value: 11100,
      quantity: 120,
      productCount: 20,
    ),
    InventoryAnalyticsWarehouseValue(
      warehouseId: 'overflow',
      warehouseName: 'Overflow Hub',
      value: 10600,
      quantity: 223,
      productCount: 22,
    ),
  ];
}

/// Returns representative movement trend rows for analytics previews.
List<InventoryAnalyticsMovementTrend>
inventoryAnalyticsPreviewMovementTrends() {
  return [
    InventoryAnalyticsMovementTrend(
      date: DateTime(2026, 6, 5),
      inboundQuantity: 12,
      outboundQuantity: 4,
    ),
    InventoryAnalyticsMovementTrend(
      date: DateTime(2026, 6, 6),
      inboundQuantity: 8,
      outboundQuantity: 11,
    ),
    InventoryAnalyticsMovementTrend(
      date: DateTime(2026, 6, 7),
      inboundQuantity: 16,
      outboundQuantity: 5,
    ),
  ];
}

/// Returns representative branch drill-down data for analytics previews.
List<InventoryAnalyticsBranchDetail> inventoryAnalyticsPreviewBranchDetails() {
  return [
    InventoryAnalyticsBranchDetail(
      branchId: 'branch-jakarta',
      branchName: 'Jakarta Central',
      value: 14200,
      quantity: 186,
      lowStockCount: 2,
      warehouseCount: 2,
      productCount: 24,
      movementCount: 18,
      warehouses: const [
        InventoryAnalyticsBranchWarehouse(
          warehouseId: 'main',
          warehouseName: 'Main Warehouse',
          locationLabel: 'Jakarta',
          value: 11100,
          quantity: 120,
          lowStockCount: 1,
          productCount: 20,
        ),
        InventoryAnalyticsBranchWarehouse(
          warehouseId: 'overflow',
          warehouseName: 'Overflow Hub',
          locationLabel: 'Bekasi',
          value: 3100,
          quantity: 66,
          lowStockCount: 1,
          productCount: 9,
        ),
      ],
      recentMovements: [
        InventoryAnalyticsBranchMovement(
          productName: 'Cable',
          type: MovementType.transfer,
          quantity: 6,
          referenceLabel: 'TRF-001',
          routeLabel: 'Main Warehouse -> Overflow Hub',
          date: DateTime(2026, 6, 7, 12),
        ),
        InventoryAnalyticsBranchMovement(
          productName: 'Laptop',
          type: MovementType.purchase,
          quantity: 14,
          referenceLabel: 'PO-1024',
          routeLabel: 'Inbound to Main Warehouse',
          date: DateTime(2026, 6, 7, 9),
        ),
      ],
    ),
    const InventoryAnalyticsBranchDetail(
      branchId: 'branch-surabaya',
      branchName: 'Surabaya North',
      value: 7500,
      quantity: 157,
      lowStockCount: 0,
      warehouseCount: 1,
      productCount: 18,
      movementCount: 7,
      warehouses: [
        InventoryAnalyticsBranchWarehouse(
          warehouseId: 'north',
          warehouseName: 'North Warehouse',
          locationLabel: 'Surabaya',
          value: 7500,
          quantity: 157,
          lowStockCount: 0,
          productCount: 18,
        ),
      ],
      recentMovements: [],
    ),
  ];
}
