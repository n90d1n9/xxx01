import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_item.dart';
import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';

/// Returns reusable low-stock replenishment plans for widget previews.
List<InventoryReplenishmentPlan> lowStockReplenishmentPreviewPlans() {
  return buildInventoryReplenishmentPlans(
    buildInventoryStockRecords(
      products: [
        Product(
          id: 'speaker',
          name: 'Bluetooth Speaker',
          sku: 'SPK-100',
          price: 250,
        ),
        Product(id: 'router', name: 'Mesh Router', sku: 'RTR-220', price: 180),
        Product(id: 'cable', name: 'USB-C Cable', sku: 'CBL-010', price: 12),
        Product(
          id: 'scanner',
          name: 'Barcode Scanner',
          sku: 'SCN-080',
          price: 95,
        ),
      ],
      warehouses: [
        Warehouse(
          id: 'jakarta',
          name: 'Jakarta Fulfillment',
          location: 'Jakarta',
          branchId: 'branch-jakarta',
          branchName: 'Jakarta Central',
        ),
        Warehouse(
          id: 'bandung',
          name: 'Bandung Satellite',
          location: 'Bandung',
          branchId: 'branch-bandung',
          branchName: 'Bandung West',
        ),
      ],
      inventoryItems: [
        InventoryItem(
          id: 'speaker-stock',
          productId: 'speaker',
          warehouseId: 'jakarta',
          currentQuantity: 0,
          reorderPoint: 4,
          reorderQuantity: 6,
        ),
        InventoryItem(
          id: 'router-stock',
          productId: 'router',
          warehouseId: 'jakarta',
          currentQuantity: 3,
          reorderPoint: 8,
          reorderQuantity: 12,
        ),
        InventoryItem(
          id: 'cable-stock',
          productId: 'cable',
          warehouseId: 'jakarta',
          currentQuantity: 4,
          reorderPoint: 6,
          reorderQuantity: 30,
        ),
        InventoryItem(
          id: 'scanner-stock',
          productId: 'scanner',
          warehouseId: 'bandung',
          currentQuantity: 1,
          reorderPoint: 5,
          reorderQuantity: 8,
        ),
      ],
    ),
  );
}

/// Returns warehouses represented by the replenishment preview plans.
List<Warehouse> lowStockReplenishmentPreviewWarehouses() {
  final warehousesById = <String, Warehouse>{};
  for (final plan in lowStockReplenishmentPreviewPlans()) {
    warehousesById[plan.record.warehouse.id] = plan.record.warehouse;
  }

  return warehousesById.values.toList()
    ..sort((first, second) => first.name.compareTo(second.name));
}

/// Wraps low-stock replenishment preview widgets in a realistic app shell.
Widget lowStockReplenishmentPreviewScaffold(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ),
  );
}
