import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/inventory/states/inventory_item_provider.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart';
import 'package:kaysir/features/inventory/states/warehouse_provider.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_module_brief.dart';
import 'package:kaysir/features/product/models/management_suite_destination.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/screens/product_assortment_planning_screen.dart';
import 'package:kaysir/features/product/screens/product_availability_management_screen.dart';
import 'package:kaysir/features/product/screens/product_category_management_screen.dart';
import 'package:kaysir/features/product/screens/product_channel_readiness_screen.dart';
import 'package:kaysir/features/product/screens/product_lifecycle_management_screen.dart';
import 'package:kaysir/features/product/screens/product_pack_contracts_screen.dart';
import 'package:kaysir/features/product/screens/product_pricing_management_screen.dart';
import 'package:kaysir/features/product/screens/product_relationship_management_screen.dart';
import 'package:kaysir/features/product/screens/product_setup_targets_screen.dart';
import 'package:kaysir/features/product/screens/product_sourcing_management_screen.dart';
import 'package:kaysir/features/product/screens/product_strategy_screen.dart';
import 'package:kaysir/features/product/screens/product_variant_management_screen.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/management_module_brief_provider.dart';
import 'package:kaysir/features/product/widgets/experience_profile_scope.dart';
import 'package:kaysir/widgets/ui/app_list_surface.dart';

void main() {
  testWidgets('product strategy screen renders management modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductStrategyScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Product Strategy'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);
    expect(find.text('Product pack mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Product editions');

    expect(find.text('Product editions'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods'), findsAtLeastNWidgets(1));

    await _scrollTextIntoView(tester, 'Experience profiles');

    expect(find.text('Experience profiles'), findsOneWidget);
    expect(find.text('All profiles ready'), findsAtLeastNWidgets(1));

    await _scrollTextIntoView(tester, 'Pack readiness');

    expect(find.text('Pack readiness'), findsOneWidget);
    await _scrollTextIntoView(tester, 'Pack contribution bundle');

    expect(find.text('Pack contribution bundle'), findsOneWidget);
  });

  testWidgets('channel readiness screen renders channel strategy modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductChannelReadinessScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Channel Readiness'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);
    expect(find.text('Channel strategy'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Channel readiness');

    expect(find.text('Launch priorities'), findsOneWidget);
    expect(find.text('Channel readiness'), findsOneWidget);
  });

  testWidgets('assortment planning screen renders segment modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductAssortmentPlanningScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Assortment Planning'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Assortment planning');

    expect(find.text('Launch-ready'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
  });

  testWidgets('category management screen renders taxonomy modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductCategoryManagementScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Category Management'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Category management');

    expect(find.text('Taxonomy coverage'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
  });

  testWidgets('pricing management screen renders pricing modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductPricingManagementScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Pricing Management'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Pricing management');

    expect(find.text('Price coverage'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
  });

  testWidgets('product suite shell renders modern context header', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductPricingManagementScreen()));

    expect(
      find.byKey(const ValueKey('product-management-suite-header')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('product-management-suite-command-strip')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('product-management-suite-module-brief')),
      findsOneWidget,
    );
    expect(find.text('Pricing Management'), findsOneWidget);
    expect(find.text('Pricing snapshot'), findsOneWidget);
    expect(find.text('Commercial area'), findsOneWidget);
    expect(find.text('Commercial profile'), findsOneWidget);
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Add product'), findsOneWidget);
    expect(find.text('Core Catalog'), findsAtLeastNWidgets(1));
    expect(find.text('Omni Retail'), findsAtLeastNWidgets(1));
  });

  testWidgets('product suite shell accepts module brief registry overrides', (
    tester,
  ) async {
    final registry = defaultProductManagementModuleBriefRegistry.mergedWith([
      ProductManagementModuleBriefResolver(
        destination: ProductManagementSuiteDestination.pricingManagement,
        buildAction:
            (_) => const ProductManagementModuleBriefAction(
              id: 'coffee_price_band_review',
              label: 'Audit coffee price bands',
              detail: 'Espresso menu price matrix',
              destination: ProductManagementSuiteDestination.pricingManagement,
              contextLabel: 'Coffee shop pack',
            ),
      ),
    ]);

    await _setLargeSurface(tester);
    await tester.pumpWidget(
      _screen(
        const ProductPricingManagementScreen(),
        moduleBriefRegistry: registry,
      ),
    );

    expect(find.text('Audit coffee price bands'), findsOneWidget);
    expect(find.text('Espresso menu price matrix'), findsOneWidget);
    expect(find.textContaining('Coffee shop pack'), findsOneWidget);
  });

  testWidgets('product suite shell scopes commercial navigation by default', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductPricingManagementScreen()));

    expect(find.text('Commercial'), findsOneWidget);
    expect(find.text('Catalog'), findsAtLeastNWidgets(1));
    expect(find.text('Structure'), findsNothing);
    expect(find.text('Operations'), findsNothing);
  });

  testWidgets('product suite shell respects scoped experience navigation', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(
      _screen(
        const ProductExperienceProfileScope(
          profile: productFreshGoodsExperienceProfile,
          child: ProductAvailabilityManagementScreen(),
        ),
      ),
    );

    expect(find.text('Availability'), findsAtLeastNWidgets(1));
    expect(find.text('Channels'), findsAtLeastNWidgets(1));
    expect(find.text('Setup'), findsAtLeastNWidgets(1));
    expect(find.text('Contracts'), findsAtLeastNWidgets(1));
    expect(find.text('Freshness'), findsAtLeastNWidgets(1));
    expect(find.text('Pricing'), findsNothing);
    expect(find.text('Sourcing'), findsNothing);
  });

  testWidgets('sourcing management screen renders supplier modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductSourcingManagementScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Sourcing Management'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Sourcing management');

    expect(find.text('Supplier coverage'), findsOneWidget);
    expect(find.text('Unassigned supplier'), findsOneWidget);
  });

  testWidgets('lifecycle management screen renders lifecycle modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductLifecycleManagementScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Lifecycle Management'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Lifecycle management');

    expect(find.text('Active coverage'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
  });

  testWidgets('variant management screen renders variant modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductVariantManagementScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Variant Management'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Variant management');

    expect(find.text('Variant coverage'), findsOneWidget);
    expect(find.text('Standalone products'), findsOneWidget);
  });

  testWidgets('relationship management screen renders relationship modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(
      _screen(const ProductRelationshipManagementScreen()),
    );

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Relationship Management'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Relationship management');

    expect(find.text('Relationship coverage'), findsOneWidget);
    expect(find.text('Complements'), findsOneWidget);
  });

  testWidgets('availability management screen renders availability modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(
      _screen(const ProductAvailabilityManagementScreen()),
    );

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Availability Rules'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Rule authoring');
    expect(find.text('Rule authoring'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Availability rules');

    expect(find.text('Availability coverage'), findsOneWidget);
    expect(find.text('Channel access'), findsOneWidget);
  });

  testWidgets('setup targets screen renders pack-aware setup modules', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductSetupTargetsScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Setup Targets'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Setup targets');

    expect(find.text('Setup targets'), findsOneWidget);
    expect(find.text('1 needs attention'), findsOneWidget);
  });

  testWidgets('product suite shell scopes setup navigation by default', (
    tester,
  ) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductSetupTargetsScreen()));

    expect(find.text('Setup'), findsAtLeastNWidgets(1));
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Commercial'), findsNothing);
    expect(find.text('Structure'), findsNothing);
  });

  testWidgets('pack contracts screen renders contract modules', (tester) async {
    await _setLargeSurface(tester);
    await tester.pumpWidget(_screen(const ProductPackContractsScreen()));

    expect(find.byType(AppListSurface), findsOneWidget);
    expect(find.text('Pack Contracts'), findsOneWidget);
    expect(find.text('Active product mode'), findsOneWidget);

    await _scrollTextIntoView(tester, 'Pack readiness');

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.text('Pack readiness'), findsOneWidget);
    await _scrollTextIntoView(tester, 'Pack contribution bundle');

    expect(find.text('Pack contribution bundle'), findsOneWidget);
  });
}

Future<void> _setLargeSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1180, 920));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _screen(
  Widget child, {
  ProductManagementModuleBriefRegistry? moduleBriefRegistry,
}) {
  return ProviderScope(
    overrides: [
      productsProvider.overrideWith((ref) => _SeededProducts(_products)),
      warehousesProvider.overrideWith((ref) => _SeededWarehouses(_warehouses)),
      inventoryItemsProvider.overrideWith(
        (ref) => _SeededInventoryItems(_inventoryItems),
      ),
      productManagementPackPreferencesRepositoryProvider.overrideWithValue(
        ProductManagementPackPreferencesRepository(
          store: MemoryProductManagementPackPreferencesStore(),
        ),
      ),
      if (moduleBriefRegistry != null)
        productManagementModuleBriefRegistryProvider.overrideWithValue(
          moduleBriefRegistry,
        ),
    ],
    child: MaterialApp(home: child),
  );
}

Future<void> _scrollTextIntoView(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    420,
    scrollable: find.byType(Scrollable).first,
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
    customAttributes: const {'add_ons': 'Cable', 'available_channels': 'POS'},
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
    name: 'Notebook',
    sku: 'NB-001',
    category: 'Stationery',
    price: 5,
  ),
];

final _warehouses = [
  Warehouse(id: 'w1', name: 'Main Warehouse', location: 'Jakarta'),
];

final _inventoryItems = [
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
    productId: 'p2',
    warehouseId: 'w1',
    currentQuantity: 2,
    reorderPoint: 5,
    reorderQuantity: 10,
  ),
];

class _SeededProducts extends ProductsNotifier {
  _SeededProducts(List<Product> products) {
    state = products;
  }
}

class _SeededWarehouses extends WarehousesNotifier {
  _SeededWarehouses(List<Warehouse> warehouses) {
    state = warehouses;
  }
}

class _SeededInventoryItems extends InventoryItemsNotifier {
  _SeededInventoryItems(List<InventoryItem> items) {
    state = items;
  }
}
