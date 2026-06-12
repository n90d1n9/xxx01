import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_item.dart';
import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_presentation_state.dart';
import '../models/inventory_product_catalog_saved_view.dart';
import '../models/inventory_stock_record.dart';
import '../models/warehouse.dart';

/// Shared preview shell for product catalog widgets.
Widget inventoryProductCatalogPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

/// Representative product catalog records for previews.
List<InventoryProductCatalogRecord> inventoryProductCatalogPreviewRecords() {
  final products = [
    Product(
      id: 'p1',
      name: 'Laptop',
      sku: 'LT-001',
      category: 'Electronics',
      description: 'Workstation bundle',
      price: 100,
    ),
    Product(
      id: 'p2',
      name: 'Cable',
      sku: 'CB-001',
      category: 'Accessories',
      price: 25,
    ),
    Product(
      id: 'p3',
      name: 'Adapter',
      sku: 'AD-001',
      category: 'Accessories',
      price: 20,
    ),
    Product(
      id: 'p4',
      name: 'Notebook',
      sku: 'NB-001',
      category: 'Stationery',
      price: 5,
    ),
  ];
  final warehouses = [
    Warehouse(
      id: 'w1',
      name: 'Main Warehouse',
      branchId: 'branch-jkt',
      branchName: 'Jakarta Flagship',
      location: 'Jakarta',
    ),
    Warehouse(
      id: 'w2',
      name: 'North Warehouse',
      branchId: 'branch-sby',
      branchName: 'Surabaya North',
      location: 'Surabaya',
    ),
  ];

  return buildInventoryProductCatalogRecords(
    products: products,
    stockRecords: buildInventoryStockRecords(
      products: products,
      warehouses: warehouses,
      inventoryItems: [
        InventoryItem(
          id: 'i1',
          productId: 'p1',
          warehouseId: 'w1',
          currentQuantity: 10,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: 'i2',
          productId: 'p1',
          warehouseId: 'w2',
          currentQuantity: 4,
          reorderPoint: 2,
          reorderQuantity: 6,
        ),
        InventoryItem(
          id: 'i3',
          productId: 'p2',
          warehouseId: 'w1',
          currentQuantity: 2,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: 'i4',
          productId: 'p3',
          warehouseId: 'w1',
          currentQuantity: 0,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
      ],
    ),
  );
}

/// Representative saved product catalog views for menu previews.
List<InventoryProductCatalogSavedView>
inventoryProductCatalogPreviewSavedViews() {
  return [
    InventoryProductCatalogSavedView(
      id: 'pricing-review',
      label: 'Pricing review',
      description: 'Margin and inventory value review',
      presentationState:
          InventoryProductCatalogPresentationPreset.pricing.presentationState,
    ),
    InventoryProductCatalogSavedView(
      id: 'channel-signals',
      label: 'Channel signals',
      description: 'Online readiness and sales channel fields',
      presentationState:
          InventoryProductCatalogPresentationPreset
              .channelSignals
              .presentationState,
    ),
  ];
}
