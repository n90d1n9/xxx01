import 'product_module_destination.dart';

/// Product management suite pages that can participate in suite navigation.
enum ProductManagementSuiteDestination {
  strategy,
  assortmentPlanning,
  categoryManagement,
  pricingManagement,
  sourcingManagement,
  lifecycleManagement,
  variantManagement,
  relationshipManagement,
  availabilityManagement,
  channelReadiness,
  setupTargets,
  packContracts,
  catalog,
  freshnessReview,
  addProduct,
  stockMovements,
  addStockMovement,
  stockOpname,
  scanProduct,
  discrepancyReport,
}

/// Module destination ids that map to product management suite pages.
const productManagementSuiteModuleDestinationIds =
    defaultProductModuleDestinationIds;

/// Operational product module destinations shown in product suite navigation.
const productManagementSuiteOperationalDestinationIds = [
  ProductModuleDestinationId.addProduct,
  ProductModuleDestinationId.stockMovements,
  ProductModuleDestinationId.addStockMovement,
  ProductModuleDestinationId.stockOpname,
  ProductModuleDestinationId.scanProduct,
  ProductModuleDestinationId.discrepancyReport,
];

/// Legacy strategy and management destinations shown in product suite navigation.
const productManagementSuiteManagementDestinationIds = [
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
];

/// Resolves a module destination id to its suite destination when supported.
ProductManagementSuiteDestination?
productManagementSuiteDestinationForModuleDestinationId(
  ProductModuleDestinationId id,
) {
  return switch (id) {
    ProductModuleDestinationId.strategy =>
      ProductManagementSuiteDestination.strategy,
    ProductModuleDestinationId.assortmentPlanning =>
      ProductManagementSuiteDestination.assortmentPlanning,
    ProductModuleDestinationId.categoryManagement =>
      ProductManagementSuiteDestination.categoryManagement,
    ProductModuleDestinationId.pricingManagement =>
      ProductManagementSuiteDestination.pricingManagement,
    ProductModuleDestinationId.sourcingManagement =>
      ProductManagementSuiteDestination.sourcingManagement,
    ProductModuleDestinationId.lifecycleManagement =>
      ProductManagementSuiteDestination.lifecycleManagement,
    ProductModuleDestinationId.variantManagement =>
      ProductManagementSuiteDestination.variantManagement,
    ProductModuleDestinationId.relationshipManagement =>
      ProductManagementSuiteDestination.relationshipManagement,
    ProductModuleDestinationId.availabilityManagement =>
      ProductManagementSuiteDestination.availabilityManagement,
    ProductModuleDestinationId.channelReadiness =>
      ProductManagementSuiteDestination.channelReadiness,
    ProductModuleDestinationId.setupTargets =>
      ProductManagementSuiteDestination.setupTargets,
    ProductModuleDestinationId.packContracts =>
      ProductManagementSuiteDestination.packContracts,
    ProductModuleDestinationId.catalog =>
      ProductManagementSuiteDestination.catalog,
    ProductModuleDestinationId.freshnessReview =>
      ProductManagementSuiteDestination.freshnessReview,
    ProductModuleDestinationId.addProduct =>
      ProductManagementSuiteDestination.addProduct,
    ProductModuleDestinationId.stockMovements =>
      ProductManagementSuiteDestination.stockMovements,
    ProductModuleDestinationId.addStockMovement =>
      ProductManagementSuiteDestination.addStockMovement,
    ProductModuleDestinationId.stockOpname =>
      ProductManagementSuiteDestination.stockOpname,
    ProductModuleDestinationId.scanProduct =>
      ProductManagementSuiteDestination.scanProduct,
    ProductModuleDestinationId.discrepancyReport =>
      ProductManagementSuiteDestination.discrepancyReport,
  };
}

/// Converts a suite destination back to the matching module destination id.
ProductModuleDestinationId productModuleDestinationIdForSuiteDestination(
  ProductManagementSuiteDestination destination,
) {
  return switch (destination) {
    ProductManagementSuiteDestination.strategy =>
      ProductModuleDestinationId.strategy,
    ProductManagementSuiteDestination.assortmentPlanning =>
      ProductModuleDestinationId.assortmentPlanning,
    ProductManagementSuiteDestination.categoryManagement =>
      ProductModuleDestinationId.categoryManagement,
    ProductManagementSuiteDestination.pricingManagement =>
      ProductModuleDestinationId.pricingManagement,
    ProductManagementSuiteDestination.sourcingManagement =>
      ProductModuleDestinationId.sourcingManagement,
    ProductManagementSuiteDestination.lifecycleManagement =>
      ProductModuleDestinationId.lifecycleManagement,
    ProductManagementSuiteDestination.variantManagement =>
      ProductModuleDestinationId.variantManagement,
    ProductManagementSuiteDestination.relationshipManagement =>
      ProductModuleDestinationId.relationshipManagement,
    ProductManagementSuiteDestination.availabilityManagement =>
      ProductModuleDestinationId.availabilityManagement,
    ProductManagementSuiteDestination.channelReadiness =>
      ProductModuleDestinationId.channelReadiness,
    ProductManagementSuiteDestination.setupTargets =>
      ProductModuleDestinationId.setupTargets,
    ProductManagementSuiteDestination.packContracts =>
      ProductModuleDestinationId.packContracts,
    ProductManagementSuiteDestination.catalog =>
      ProductModuleDestinationId.catalog,
    ProductManagementSuiteDestination.freshnessReview =>
      ProductModuleDestinationId.freshnessReview,
    ProductManagementSuiteDestination.addProduct =>
      ProductModuleDestinationId.addProduct,
    ProductManagementSuiteDestination.stockMovements =>
      ProductModuleDestinationId.stockMovements,
    ProductManagementSuiteDestination.addStockMovement =>
      ProductModuleDestinationId.addStockMovement,
    ProductManagementSuiteDestination.stockOpname =>
      ProductModuleDestinationId.stockOpname,
    ProductManagementSuiteDestination.scanProduct =>
      ProductModuleDestinationId.scanProduct,
    ProductManagementSuiteDestination.discrepancyReport =>
      ProductModuleDestinationId.discrepancyReport,
  };
}

/// Resolves a suite destination to the registered module destination metadata.
ProductModuleDestination? productModuleDestinationForSuiteDestination(
  ProductManagementSuiteDestination destination, {
  ProductModuleDestinationRegistry registry =
      defaultProductModuleDestinationRegistry,
}) {
  final destinationId = productModuleDestinationIdForSuiteDestination(
    destination,
  );

  return registry.destinationForId(destinationId);
}

/// Whether a module destination should appear in suite-style navigation.
bool productModuleDestinationSupportsSuiteNavigation(
  ProductModuleDestinationId id,
) {
  return productManagementSuiteDestinationForModuleDestinationId(id) != null;
}
