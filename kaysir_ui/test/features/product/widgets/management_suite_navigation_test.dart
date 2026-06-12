import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/utils/management_route_mode.dart';
import 'package:kaysir/features/product/widgets/management_suite_navigation.dart';

void main() {
  testWidgets('product management suite navigation delegates selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(2100, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ProductManagementSuiteDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementSuiteNavigation(
            activeDestination: ProductManagementSuiteDestination.strategy,
            onSelected: (destination) => selectedDestination = destination,
          ),
        ),
      ),
    );

    expect(find.text('Product management'), findsOneWidget);
    expect(find.text('Planning'), findsOneWidget);
    expect(find.text('Commercial'), findsOneWidget);
    expect(find.text('Structure'), findsOneWidget);
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Strategy'), findsAtLeastNWidgets(1));
    expect(find.text('Assortment'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Sourcing'), findsOneWidget);
    expect(find.text('Lifecycle'), findsOneWidget);
    expect(find.text('Variants'), findsOneWidget);
    expect(find.text('Relations'), findsOneWidget);
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Channels'), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);
    expect(find.text('Contracts'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Freshness'), findsOneWidget);
    expect(find.text('Add product'), findsOneWidget);
    expect(find.text('Movements'), findsOneWidget);
    expect(find.text('Add movement'), findsOneWidget);
    expect(find.text('Stock count'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Discrepancy'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-300, 0),
    );
    await tester.pump();
    await tester.tap(find.text('Channels'));
    await tester.pump();

    expect(
      selectedDestination,
      ProductManagementSuiteDestination.channelReadiness,
    );
  });

  testWidgets('product management suite navigation supports scoped sections', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(2100, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ProductManagementSuiteDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementSuiteNavigation(
            activeDestination: ProductManagementSuiteDestination.catalog,
            sections: const [
              ProductManagementSuiteNavigationSection(
                id: 'catalog-ops',
                label: 'Catalog ops',
                items: [
                  productManagementSuiteCatalogItem,
                  productManagementSuiteFreshnessReviewItem,
                ],
              ),
            ],
            onSelected: (destination) => selectedDestination = destination,
          ),
        ),
      ),
    );

    expect(find.text('Catalog ops'), findsOneWidget);
    expect(find.text('Catalog'), findsAtLeastNWidgets(1));
    expect(find.text('Freshness'), findsOneWidget);
    expect(find.text('Strategy'), findsNothing);

    await tester.tap(find.text('Freshness'));
    await tester.pump();

    expect(
      selectedDestination,
      ProductManagementSuiteDestination.freshnessReview,
    );
  });

  testWidgets('product management suite navigation supports named profiles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(2100, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ProductManagementSuiteDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementSuiteNavigation.withProfile(
            activeDestination:
                ProductManagementSuiteDestination.freshnessReview,
            profile: productManagementFreshGoodsNavigationProfile,
            onSelected: (destination) => selectedDestination = destination,
          ),
        ),
      ),
    );

    expect(find.text('Fresh ops'), findsOneWidget);
    expect(find.text('Controls'), findsOneWidget);
    expect(find.text('Freshness'), findsAtLeastNWidgets(1));
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Strategy'), findsNothing);

    await tester.tap(find.text('Availability'));
    await tester.pump();

    expect(
      selectedDestination,
      ProductManagementSuiteDestination.availabilityManagement,
    );
  });

  testWidgets('product management suite navigation uses compact menu', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ProductManagementSuiteDestination? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementSuiteNavigation(
            activeDestination: ProductManagementSuiteDestination.strategy,
            onSelected: (destination) => selectedDestination = destination,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('product-management-suite-navigation-select')),
      findsOneWidget,
    );
    expect(
      find.byType(SegmentedButton<ProductManagementSuiteDestination>),
      findsNothing,
    );

    final compactMenu = tester.widget<
      DropdownButtonFormField<ProductManagementSuiteDestination>
    >(find.byKey(const ValueKey('product-management-suite-navigation-select')));
    compactMenu.onChanged?.call(ProductManagementSuiteDestination.catalog);
    await tester.pump();

    expect(selectedDestination, ProductManagementSuiteDestination.catalog);

    compactMenu.onChanged?.call(
      ProductManagementSuiteDestination.freshnessReview,
    );
    await tester.pump();

    expect(
      selectedDestination,
      ProductManagementSuiteDestination.freshnessReview,
    );
  });

  testWidgets('product management suite navigation can force layout strategy', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementSuiteNavigation(
            activeDestination: ProductManagementSuiteDestination.strategy,
            layout: ProductManagementSuiteNavigationLayout.segmented,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('product-management-suite-navigation-select')),
      findsNothing,
    );
    expect(
      find.byType(SegmentedButton<ProductManagementSuiteDestination>),
      findsNWidgets(productManagementSuiteNavigationSections.length),
    );
    expect(find.text('Planning'), findsOneWidget);
  });

  test('product management suite routes preserve active product mode', () {
    const mode = ProductManagementRouteMode(
      packId: ProductManagementPackId.groceryFreshGoods,
      channelProfileId: groceryFreshGoodsProfileId,
    );

    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.assortmentPlanning,
        mode: mode,
      ),
      '/products/assortment-planning?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.categoryManagement,
        mode: mode,
      ),
      '/products/categories?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.pricingManagement,
        mode: mode,
      ),
      '/products/pricing?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.sourcingManagement,
        mode: mode,
      ),
      '/products/sourcing?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.lifecycleManagement,
        mode: mode,
      ),
      '/products/lifecycle?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.variantManagement,
        mode: mode,
      ),
      '/products/variants?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.relationshipManagement,
        mode: mode,
      ),
      '/products/relationships?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.availabilityManagement,
        mode: mode,
      ),
      '/products/availability?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.channelReadiness,
        mode: mode,
      ),
      '/products/channel-readiness?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.setupTargets,
        mode: mode,
      ),
      '/products/setup-targets?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.packContracts,
        mode: mode,
      ),
      '/products/pack-contracts?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.catalog,
        mode: mode,
      ),
      '/products?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.freshnessReview,
        mode: mode,
      ),
      '/products/freshness?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.addProduct,
        mode: mode,
      ),
      '/products/new?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.stockMovements,
        mode: mode,
      ),
      '/products/stock-movements',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.addStockMovement,
        mode: mode,
      ),
      '/products/stock-movements/new',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.stockOpname,
        mode: mode,
      ),
      '/products/stock-opname',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.scanProduct,
        mode: mode,
      ),
      '/products/stock-opname/scan',
    );
    expect(
      productManagementSuiteDestinationRoute(
        ProductManagementSuiteDestination.discrepancyReport,
        mode: mode,
      ),
      '/products/discrepancy-report',
    );
  });

  test(
    'product management suite metadata keeps sections and items aligned',
    () {
      final sectionDestinations = [
        for (final section in productManagementSuiteNavigationSections)
          for (final item in section.items) item.destination,
      ];
      final itemDestinations = [
        for (final item in productManagementSuiteNavigationItems)
          item.destination,
      ];

      expect(sectionDestinations, itemDestinations);
      expect(
        productManagementSuiteNavigationSectionFor(
          ProductManagementSuiteDestination.freshnessReview,
        )?.id,
        'operations',
      );

      for (final item in productManagementSuiteNavigationItems) {
        final moduleDestination = productModuleDestinationForSuiteDestination(
          item.destination,
        );
        expect(moduleDestination, isNotNull);
        expect(item.moduleDestination.id, moduleDestination!.id);
        expect(item.path, moduleDestination.path);
      }
    },
  );

  test('product management suite navigation profiles stay routable', () {
    for (final profile in productManagementSuiteNavigationProfiles) {
      expect(profile.id, isNotEmpty);
      expect(profile.sections, isNotEmpty);
      expect(profile.items, isNotEmpty);

      final destinations = [for (final item in profile.items) item.destination];
      expect(destinations.toSet().length, destinations.length);
    }

    for (final destination in ProductManagementSuiteDestination.values) {
      final profile = productManagementSuiteNavigationProfileForDestination(
        destination,
      );
      expect(profile.contains(destination), isTrue);
    }

    expect(
      productManagementSuiteNavigationProfileForDestination(
        ProductManagementSuiteDestination.freshnessReview,
      ).id,
      productManagementFreshGoodsNavigationProfile.id,
    );
    expect(
      productManagementSuiteNavigationProfileForDestination(
        ProductManagementSuiteDestination.stockOpname,
      ).id,
      productManagementCatalogOperationsNavigationProfile.id,
    );
  });

  test('product suite navigation profiles can be derived from experiences', () {
    final freshGoodsProfile =
        productManagementSuiteNavigationProfileForExperienceProfile(
          productFreshGoodsExperienceProfile,
          activeDestination:
              ProductManagementSuiteDestination.availabilityManagement,
        );
    final freshGoodsDestinations = [
      for (final item in freshGoodsProfile.items) item.destination,
    ];

    expect(freshGoodsProfile.id, 'experience-fresh_goods');
    expect(
      freshGoodsDestinations,
      containsAll([
        ProductManagementSuiteDestination.availabilityManagement,
        ProductManagementSuiteDestination.channelReadiness,
        ProductManagementSuiteDestination.setupTargets,
        ProductManagementSuiteDestination.packContracts,
        ProductManagementSuiteDestination.catalog,
        ProductManagementSuiteDestination.freshnessReview,
        ProductManagementSuiteDestination.stockOpname,
        ProductManagementSuiteDestination.scanProduct,
        ProductManagementSuiteDestination.discrepancyReport,
      ]),
    );
    expect(
      freshGoodsDestinations,
      isNot(contains(ProductManagementSuiteDestination.pricingManagement)),
    );
    expect(
      freshGoodsDestinations,
      isNot(contains(ProductManagementSuiteDestination.sourcingManagement)),
    );

    final fallbackProfile =
        productManagementSuiteNavigationProfileForExperienceProfile(
          productStockControlExperienceProfile,
          activeDestination:
              ProductManagementSuiteDestination.availabilityManagement,
        );

    expect(fallbackProfile.id, productManagementCommercialNavigationProfile.id);
  });
}
