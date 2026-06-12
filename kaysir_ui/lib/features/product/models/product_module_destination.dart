import '../product_routes.dart';

enum ProductModuleDestinationId {
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

/// Describes one reusable product module destination and its shell route metadata.
class ProductModuleDestination {
  const ProductModuleDestination({
    required this.id,
    required this.name,
    required this.routeName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.path,
  });

  final ProductModuleDestinationId id;
  final String name;
  final String routeName;
  final String title;
  final String subtitle;
  final String description;
  final String path;
}

/// Lookup registry for product module destinations used by experience profiles.
class ProductModuleDestinationRegistry {
  const ProductModuleDestinationRegistry(this.destinations);

  final List<ProductModuleDestination> destinations;

  bool get isEmpty => destinations.isEmpty;
  bool get hasDestinations => destinations.isNotEmpty;

  List<ProductModuleDestinationId> get ids {
    return List.unmodifiable(destinations.map((destination) => destination.id));
  }

  List<String> get routeNames {
    return List.unmodifiable(
      destinations.map((destination) => destination.routeName),
    );
  }

  List<String> get titles {
    return List.unmodifiable(
      destinations.map((destination) => destination.title),
    );
  }

  List<String> get paths {
    return List.unmodifiable(
      destinations.map((destination) => destination.path),
    );
  }

  ProductModuleDestination? destinationForId(ProductModuleDestinationId id) {
    for (final destination in destinations) {
      if (destination.id == id) return destination;
    }

    return null;
  }

  ProductModuleDestination? destinationForPath(String path) {
    final normalizedPath = path.trim();
    for (final destination in destinations) {
      if (destination.path == normalizedPath) return destination;
    }

    return null;
  }

  ProductModuleDestination? destinationForRouteName(String routeName) {
    final normalizedRouteName = routeName.trim();
    for (final destination in destinations) {
      if (destination.routeName == normalizedRouteName) return destination;
    }

    return null;
  }

  bool containsId(ProductModuleDestinationId id) {
    return destinationForId(id) != null;
  }

  List<ProductModuleDestination> destinationsForIds(
    Iterable<ProductModuleDestinationId> ids,
  ) {
    return [
      for (final id in ids)
        if (destinationForId(id) case final destination?) destination,
    ];
  }
}

const productStrategyDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.strategy,
  name: 'Product Strategy',
  routeName: ProductRoutes.strategyRouteName,
  title: 'Product Strategy',
  subtitle: 'Modes, packs, and channel profiles',
  description:
      'Standalone product management strategy screen for switching product packs, channel behavior, and reusable product-line presets.',
  path: ProductRoutes.strategyPath,
);

const productAssortmentPlanningDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.assortmentPlanning,
  name: 'Assortment Planning',
  routeName: ProductRoutes.assortmentPlanningRouteName,
  title: 'Assortment Planning',
  subtitle: 'Category coverage and launch gaps',
  description:
      'Standalone product planning screen for category coverage, segment readiness, launch blockers, and reusable assortment review.',
  path: ProductRoutes.assortmentPlanningPath,
);

const productCategoryManagementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.categoryManagement,
  name: 'Category Management',
  routeName: ProductRoutes.categoryManagementRouteName,
  title: 'Category Management',
  subtitle: 'Taxonomy coverage and category risk',
  description:
      'Standalone product category management screen for taxonomy coverage, uncategorized products, category risk, and catalog review handoff.',
  path: ProductRoutes.categoryManagementPath,
);

const productPricingManagementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.pricingManagement,
  name: 'Pricing Management',
  routeName: ProductRoutes.pricingManagementRouteName,
  title: 'Pricing Management',
  subtitle: 'Price coverage, margin risk, and outliers',
  description:
      'Standalone product pricing management screen for price coverage, cost-backed margin risk, price-band outliers, and catalog review handoff.',
  path: ProductRoutes.pricingManagementPath,
);

const productSourcingManagementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.sourcingManagement,
  name: 'Sourcing Management',
  routeName: ProductRoutes.sourcingManagementRouteName,
  title: 'Sourcing Management',
  subtitle: 'Supplier coverage, cost visibility, and supply risk',
  description:
      'Standalone product sourcing management screen for supplier coverage, unassigned products, cost visibility, and catalog review handoff.',
  path: ProductRoutes.sourcingManagementPath,
);

const productLifecycleManagementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.lifecycleManagement,
  name: 'Lifecycle Management',
  routeName: ProductRoutes.lifecycleManagementRouteName,
  title: 'Lifecycle Management',
  subtitle: 'Launch state, blockers, and retirement risk',
  description:
      'Standalone product lifecycle management screen for draft, active, blocked, retiring, and archived product governance.',
  path: ProductRoutes.lifecycleManagementPath,
);

const productVariantManagementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.variantManagement,
  name: 'Variant Management',
  routeName: ProductRoutes.variantManagementRouteName,
  title: 'Variant Management',
  subtitle: 'Families, options, bundles, and SKU variants',
  description:
      'Standalone product variant management screen for option families, inferred SKU variants, duplicate options, and standalone product review.',
  path: ProductRoutes.variantManagementPath,
);

const productRelationshipManagementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.relationshipManagement,
  name: 'Relationship Management',
  routeName: ProductRoutes.relationshipManagementRouteName,
  title: 'Relationship Management',
  subtitle: 'Substitutes, bundles, add-ons, and cross-sells',
  description:
      'Standalone product relationship management screen for substitutes, complements, bundle components, upsells, cross-sells, and target resolution.',
  path: ProductRoutes.relationshipManagementPath,
);

const productAvailabilityManagementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.availabilityManagement,
  name: 'Availability Rules',
  routeName: ProductRoutes.availabilityManagementRouteName,
  title: 'Availability Rules',
  subtitle: 'Channel access, stock gates, and selling windows',
  description:
      'Standalone product availability screen for channel access, sales status, stock gates, schedule windows, and fulfillment mode review.',
  path: ProductRoutes.availabilityManagementPath,
);

const productChannelReadinessDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.channelReadiness,
  name: 'Channel Readiness',
  routeName: ProductRoutes.channelReadinessRouteName,
  title: 'Channel Readiness',
  subtitle: 'Omnichannel launch coverage',
  description:
      'Standalone channel readiness screen for reviewing product coverage across POS, online, marketplace, kiosk, and future selling channels.',
  path: ProductRoutes.channelReadinessPath,
);

const productSetupTargetsDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.setupTargets,
  name: 'Setup Targets',
  routeName: ProductRoutes.setupTargetsRouteName,
  title: 'Setup Targets',
  subtitle: 'Pack-aware setup requirements',
  description:
      'Standalone setup target screen for product workflow requirements, inactive pack setup, and readiness prompts.',
  path: ProductRoutes.setupTargetsPath,
);

const productPackContractsDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.packContracts,
  name: 'Pack Contracts',
  routeName: ProductRoutes.packContractsRouteName,
  title: 'Pack Contracts',
  subtitle: 'Data contracts and extension hooks',
  description:
      'Standalone pack contract screen for required fields, channel runtime packs, module contributions, and readiness health.',
  path: ProductRoutes.packContractsPath,
);

const productCatalogDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.catalog,
  name: 'Product Catalog',
  routeName: ProductRoutes.catalogRouteName,
  title: 'Product Catalog',
  subtitle: 'Products, SKU, and stock health',
  description:
      'Browse, search, create, edit, and monitor products from the shared inventory-backed catalog.',
  path: ProductRoutes.catalogPath,
);

const productFreshnessReviewDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.freshnessReview,
  name: 'Freshness Review',
  routeName: ProductRoutes.freshnessReviewRouteName,
  title: 'Freshness Review',
  subtitle: 'Expiry, batch, and fresh-stock readiness',
  description:
      'Grocery fresh-goods catalog review with expiry, batch, and freshness queue signals surfaced from reusable product catalog logic.',
  path: ProductRoutes.freshnessReviewPath,
);

const productAddProductDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.addProduct,
  name: 'Add Product',
  routeName: ProductRoutes.addProductRouteName,
  title: 'Add Product',
  subtitle: 'Create pack-aware product records',
  description:
      'Standalone product form for creating products with the active product management pack fields.',
  path: ProductRoutes.addProductPath,
);

const productStockMovementsDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.stockMovements,
  name: 'Stock Movements',
  routeName: ProductRoutes.stockMovementsRouteName,
  title: 'Stock Movements',
  subtitle: 'Movement ledger and filters',
  description:
      'Standalone product stock movement ledger for stock events, movement type filtering, search, and activity review.',
  path: ProductRoutes.stockMovementsPath,
);

const productAddStockMovementDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.addStockMovement,
  name: 'Add Stock Movement',
  routeName: ProductRoutes.addStockMovementRouteName,
  title: 'Add Stock Movement',
  subtitle: 'Record inbound and outbound stock',
  description:
      'Standalone stock action picker for selecting a product and recording add or remove stock movements.',
  path: ProductRoutes.addStockMovementPath,
);

const productStockOpnameDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.stockOpname,
  name: 'Stock Opname',
  routeName: ProductRoutes.stockOpnameRouteName,
  title: 'Stock Opname',
  subtitle: 'Physical count queue',
  description:
      'Product-owned stock opname list for reviewing count status and opening scan-based count entry.',
  path: ProductRoutes.stockOpnamePath,
);

const productScanProductDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.scanProduct,
  name: 'Scan Product',
  routeName: ProductRoutes.scanProductRouteName,
  title: 'Scan Product',
  subtitle: 'Count by barcode or product id',
  description:
      'Scan or enter a product identifier, capture actual quantity, and save stock count notes.',
  path: ProductRoutes.scanProductPath,
);

const productDiscrepancyReportDestination = ProductModuleDestination(
  id: ProductModuleDestinationId.discrepancyReport,
  name: 'Discrepancy Report',
  routeName: ProductRoutes.discrepancyReportRouteName,
  title: 'Discrepancy Report',
  subtitle: 'Count variance review',
  description:
      'Review products where actual stock counts differ from system stock or still need a count.',
  path: ProductRoutes.discrepancyReportPath,
);

const defaultProductModuleDestinationIds = [
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
];

const defaultProductModuleDestinations = [
  productStrategyDestination,
  productAssortmentPlanningDestination,
  productCategoryManagementDestination,
  productPricingManagementDestination,
  productSourcingManagementDestination,
  productLifecycleManagementDestination,
  productVariantManagementDestination,
  productRelationshipManagementDestination,
  productAvailabilityManagementDestination,
  productChannelReadinessDestination,
  productSetupTargetsDestination,
  productPackContractsDestination,
  productCatalogDestination,
  productFreshnessReviewDestination,
  productAddProductDestination,
  productStockMovementsDestination,
  productAddStockMovementDestination,
  productStockOpnameDestination,
  productScanProductDestination,
  productDiscrepancyReportDestination,
];

const defaultProductModuleDestinationRegistry =
    ProductModuleDestinationRegistry(defaultProductModuleDestinations);
