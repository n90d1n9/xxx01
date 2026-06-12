import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_module_brief.dart';
import 'package:kaysir/features/product/models/management_suite_destination.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_pack_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_action_registry.dart';
import 'package:kaysir/features/product/models/product_workspace_overview.dart';
import 'package:kaysir/features/product/widgets/management_suite_module_brief.dart';
import 'package:kaysir/features/product/widgets/management_suite_navigation_items.dart';

void main() {
  testWidgets('product management suite module brief renders overview health', (
    tester,
  ) async {
    final overview = _overview();
    final action = defaultProductManagementModuleBriefRegistry.resolve(
      activeDestination: ProductManagementSuiteDestination.pricingManagement,
      overview: overview,
    );
    var actionTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementSuiteModuleBrief(
            activeItem: productManagementSuitePricingManagementItem,
            overview: overview,
            action: action,
            onActionPressed: () => actionTapped = true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('product-management-suite-module-brief')),
      findsOneWidget,
    );
    expect(find.text('Pricing snapshot'), findsOneWidget);
    expect(find.text('2 products across 2 categories'), findsOneWidget);
    expect(find.text(overview.catalogQualityLabel), findsOneWidget);
    expect(find.text(overview.attentionLabel), findsOneWidget);
    expect(find.text(overview.workflowReadinessLabel), findsOneWidget);
    expect(find.text(overview.launchQueueLabel), findsOneWidget);
    expect(find.textContaining('Next action'), findsOneWidget);
    expect(find.textContaining(action.contextLabel), findsOneWidget);
    expect(find.text(action.label), findsOneWidget);
    expect(find.text(action.detail), findsOneWidget);

    await tester.tap(find.text(action.label));
    await tester.pump();

    expect(actionTapped, isTrue);
  });
}

ProductWorkspaceOverview _overview() {
  final products = [
    Product(
      id: 'coffee-beans',
      name: 'House Blend Beans',
      sku: 'COF-001',
      category: 'Coffee',
      description: 'Whole bean retail pack',
      price: 12,
      customAttributes: const {'available_channels': 'POS, Online'},
    ),
    Product(
      id: 'cold-brew',
      name: 'Cold Brew Bottle',
      sku: 'DRK-014',
      category: 'Beverage',
      price: 0,
    ),
  ];
  final warehouses = [
    Warehouse(id: 'main-store', name: 'Main Store', location: 'Jakarta'),
  ];
  final stockRecords = buildInventoryStockRecords(
    inventoryItems: [
      InventoryItem(
        id: 'stock-1',
        productId: 'coffee-beans',
        warehouseId: 'main-store',
        currentQuantity: 24,
        reorderPoint: 8,
        reorderQuantity: 20,
      ),
      InventoryItem(
        id: 'stock-2',
        productId: 'cold-brew',
        warehouseId: 'main-store',
        currentQuantity: 2,
        reorderPoint: 8,
        reorderQuantity: 12,
      ),
    ],
    products: products,
    warehouses: warehouses,
  );
  final registry = defaultProductSalesChannelProfileRegistry;
  final channelProfile = omniRetailProductSalesChannelProfile;

  return buildProductWorkspaceOverview(
    products: products,
    stockRecords: stockRecords,
    actionRegistry: ProductWorkspaceActionRegistry(
      pack: coreProductManagementPack,
    ),
    managementPack: coreProductManagementPack,
    channelProfiles: registry.profiles,
    channelProfile: channelProfile,
    channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
      packs: [defaultProductSalesChannelProfilePack],
      registry: registry,
      selectedProfile: channelProfile,
    ),
  );
}
