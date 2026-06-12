import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_pack_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_action_registry.dart';
import 'package:kaysir/features/product/models/product_workspace_overview.dart';
import 'package:kaysir/features/product/widgets/workspace_pulse_panel.dart';

void main() {
  testWidgets('workspace pulse panel renders overview and delegates actions', (
    tester,
  ) async {
    var reviewedQueue = false;
    var reviewedAttention = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspacePulsePanel(
            overview: _overview,
            onReviewLaunchQueue: () => reviewedQueue = true,
            onReviewAttention: () => reviewedAttention = true,
          ),
        ),
      ),
    );

    expect(find.text('Workspace pulse'), findsOneWidget);
    expect(find.text('Omni Retail'), findsAtLeastNWidgets(1));
    expect(find.text('Catalog setup'), findsOneWidget);
    expect(find.text('Launch queue'), findsOneWidget);
    expect(find.text('Workflow readiness'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('1 product needs attention'), findsOneWidget);

    await tester.tap(find.text('Review queue'));
    await tester.tap(find.text('Review attention'));

    expect(reviewedQueue, isTrue);
    expect(reviewedAttention, isTrue);
  });
}

final _overview = _buildOverview();

ProductWorkspaceOverview _buildOverview() {
  final registry = ProductSalesChannelProfileRegistry.fromPacks(
    coreProductManagementPack.profilePacks,
  );
  final selectedProfile = registry.fallbackProfile;

  return buildProductWorkspaceOverview(
    products: _products,
    stockRecords: _stockRecords,
    actionRegistry: ProductWorkspaceActionRegistry(
      pack: coreProductManagementPack,
    ),
    managementPack: coreProductManagementPack,
    channelProfiles: registry.profiles,
    channelProfile: selectedProfile,
    channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
      packs: coreProductManagementPack.profilePacks,
      registry: registry,
      selectedProfile: selectedProfile,
    ),
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
    price: 100,
    barcode: '8990001',
  ),
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Accessories',
    price: 25,
  ),
];

final _warehouse = Warehouse(
  id: 'w1',
  name: 'Main Warehouse',
  location: 'Jakarta',
);

final _stockRecords = [
  InventoryStockRecord(
    item: InventoryItem(
      id: 'i1',
      productId: 'p1',
      warehouseId: 'w1',
      currentQuantity: 10,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    product: _products[0],
    warehouse: _warehouse,
  ),
  InventoryStockRecord(
    item: InventoryItem(
      id: 'i2',
      productId: 'p2',
      warehouseId: 'w1',
      currentQuantity: 1,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    product: _products[1],
    warehouse: _warehouse,
  ),
];
