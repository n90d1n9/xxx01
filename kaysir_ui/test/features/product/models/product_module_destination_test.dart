import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_suite_destination.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('product module destinations map standalone product screens', () {
    expect(
      defaultProductModuleDestinationIds,
      defaultProductModuleDestinations.map((destination) => destination.id),
    );
    expect(
      defaultProductModuleDestinations.map((destination) => destination.id),
      [
        ProductModuleDestinationId.strategy,
        ProductModuleDestinationId.assortmentPlanning,
        ProductModuleDestinationId.categoryManagement,
        ProductModuleDestinationId.pricingManagement,
        ProductModuleDestinationId.sourcingManagement,
        ProductModuleDestinationId.lifecycleManagement,
        ProductModuleDestinationId.variantManagement,
        ProductModuleDestinationId.relationshipManagement,
        ProductModuleDestinationId.availabilityManagement,
        ProductModuleDestinationId.channelReadiness,
        ProductModuleDestinationId.setupTargets,
        ProductModuleDestinationId.packContracts,
        ProductModuleDestinationId.catalog,
        ProductModuleDestinationId.freshnessReview,
        ProductModuleDestinationId.addProduct,
        ProductModuleDestinationId.stockMovements,
        ProductModuleDestinationId.addStockMovement,
        ProductModuleDestinationId.stockOpname,
        ProductModuleDestinationId.scanProduct,
        ProductModuleDestinationId.discrepancyReport,
      ],
    );

    expect(productStrategyDestination.path, ProductRoutes.strategyPath);
    expect(
      productAssortmentPlanningDestination.path,
      ProductRoutes.assortmentPlanningPath,
    );
    expect(
      productCategoryManagementDestination.routeName,
      ProductRoutes.categoryManagementRouteName,
    );
    expect(
      productPricingManagementDestination.path,
      ProductRoutes.pricingManagementPath,
    );
    expect(
      productSourcingManagementDestination.routeName,
      ProductRoutes.sourcingManagementRouteName,
    );
    expect(
      productLifecycleManagementDestination.path,
      ProductRoutes.lifecycleManagementPath,
    );
    expect(
      productVariantManagementDestination.routeName,
      ProductRoutes.variantManagementRouteName,
    );
    expect(
      productRelationshipManagementDestination.path,
      ProductRoutes.relationshipManagementPath,
    );
    expect(
      productAvailabilityManagementDestination.routeName,
      ProductRoutes.availabilityManagementRouteName,
    );
    expect(
      productAvailabilityManagementDestination.path,
      ProductRoutes.availabilityManagementPath,
    );
    expect(
      productChannelReadinessDestination.routeName,
      ProductRoutes.channelReadinessRouteName,
    );
    expect(productSetupTargetsDestination.path, ProductRoutes.setupTargetsPath);
    expect(
      productPackContractsDestination.routeName,
      ProductRoutes.packContractsRouteName,
    );
    expect(productCatalogDestination.path, ProductRoutes.catalogPath);
    expect(
      productFreshnessReviewDestination.routeName,
      ProductRoutes.freshnessReviewRouteName,
    );
    expect(
      productFreshnessReviewDestination.path,
      ProductRoutes.freshnessReviewPath,
    );
    expect(productAddProductDestination.path, ProductRoutes.addProductPath);
    expect(
      productAddProductDestination.routeName,
      ProductRoutes.addProductRouteName,
    );
    expect(
      productStockMovementsDestination.path,
      ProductRoutes.stockMovementsPath,
    );
    expect(
      productAddStockMovementDestination.routeName,
      ProductRoutes.addStockMovementRouteName,
    );
    expect(productStockOpnameDestination.path, ProductRoutes.stockOpnamePath);
    expect(productScanProductDestination.path, ProductRoutes.scanProductPath);
    expect(
      productDiscrepancyReportDestination.routeName,
      ProductRoutes.discrepancyReportRouteName,
    );
  });

  test('product module destination registry resolves common lookups', () {
    final registry = defaultProductModuleDestinationRegistry;

    expect(registry.hasDestinations, isTrue);
    expect(registry.ids, defaultProductModuleDestinationIds);
    expect(
      registry.routeNames,
      defaultProductModuleDestinations.map(
        (destination) => destination.routeName,
      ),
    );
    expect(
      registry.titles,
      defaultProductModuleDestinations.map((destination) => destination.title),
    );
    expect(
      registry.paths,
      defaultProductModuleDestinations.map((destination) => destination.path),
    );
    expect(
      registry.destinationForId(ProductModuleDestinationId.catalog),
      productCatalogDestination,
    );
    expect(
      registry.destinationForPath(ProductRoutes.freshnessReviewPath),
      productFreshnessReviewDestination,
    );
    expect(
      registry.destinationForRouteName(
        ProductRoutes.pricingManagementRouteName,
      ),
      productPricingManagementDestination,
    );
    expect(
      registry.destinationsForIds([
        ProductModuleDestinationId.catalog,
        ProductModuleDestinationId.freshnessReview,
      ]),
      [productCatalogDestination, productFreshnessReviewDestination],
    );

    final ids = {
      for (final destination in registry.destinations) destination.id,
    };
    final routeNames = {
      for (final destination in registry.destinations) destination.routeName,
    };
    final paths = {
      for (final destination in registry.destinations) destination.path,
    };

    expect(ids.length, registry.destinations.length);
    expect(routeNames.length, registry.destinations.length);
    expect(paths.length, registry.destinations.length);
  });

  test('product suite destinations map back to module destinations', () {
    expect(productManagementSuiteModuleDestinationIds, [
      ...defaultProductModuleDestinationIds,
    ]);
    expect(productManagementSuiteOperationalDestinationIds, [
      ProductModuleDestinationId.addProduct,
      ProductModuleDestinationId.stockMovements,
      ProductModuleDestinationId.addStockMovement,
      ProductModuleDestinationId.stockOpname,
      ProductModuleDestinationId.scanProduct,
      ProductModuleDestinationId.discrepancyReport,
    ]);
    expect(productManagementSuiteManagementDestinationIds, [
      ...defaultProductModuleDestinationIds.where(
        (id) => !productManagementSuiteOperationalDestinationIds.contains(id),
      ),
    ]);

    for (final destination in ProductManagementSuiteDestination.values) {
      final moduleDestination = productModuleDestinationForSuiteDestination(
        destination,
      );
      final moduleDestinationId = productModuleDestinationIdForSuiteDestination(
        destination,
      );

      expect(moduleDestination, isNotNull);
      expect(moduleDestination!.id, moduleDestinationId);
      expect(
        productManagementSuiteDestinationForModuleDestinationId(
          moduleDestinationId,
        ),
        destination,
      );
      expect(
        productModuleDestinationSupportsSuiteNavigation(moduleDestinationId),
        isTrue,
      );
    }
  });

  test('all product module destinations support suite navigation', () {
    for (final id in ProductModuleDestinationId.values) {
      expect(
        productManagementSuiteDestinationForModuleDestinationId(id),
        isNotNull,
      );
      expect(productModuleDestinationSupportsSuiteNavigation(id), isTrue);
    }
  });
}
