import 'management_pack.dart';
import 'product_module_destination.dart';
import 'sales_channel_profile.dart';

/// Stable identifier for a reusable product workspace experience.
class ProductExperienceProfileId {
  const ProductExperienceProfileId(this.value);

  static const fullSuite = ProductExperienceProfileId('full_suite');
  static const coreOperations = ProductExperienceProfileId('core_operations');
  static const catalogOperations = ProductExperienceProfileId(
    'catalog_operations',
  );
  static const freshGoods = ProductExperienceProfileId('fresh_goods');
  static const omnichannelCommerce = ProductExperienceProfileId(
    'omnichannel_commerce',
  );
  static const stockControl = ProductExperienceProfileId('stock_control');
  static const setupContracts = ProductExperienceProfileId('setup_contracts');
  static const values = [
    fullSuite,
    coreOperations,
    catalogOperations,
    freshGoods,
    omnichannelCommerce,
    stockControl,
    setupContracts,
  ];

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductExperienceProfileId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Reusable workspace profile that scopes product destinations and defaults.
class ProductExperienceProfile {
  const ProductExperienceProfile({
    required this.id,
    required this.workspaceTitle,
    required this.workspaceSubtitle,
    required this.workspaceDescription,
    required this.destinationIds,
    this.defaultPackId,
    this.defaultChannelProfileId,
    this.includeAttentionReviewShortcut = true,
  });

  final ProductExperienceProfileId id;
  final String workspaceTitle;
  final String workspaceSubtitle;
  final String workspaceDescription;
  final List<ProductModuleDestinationId> destinationIds;
  final ProductManagementPackId? defaultPackId;
  final ProductSalesChannelProfileId? defaultChannelProfileId;
  final bool includeAttentionReviewShortcut;

  bool containsDestinationId(ProductModuleDestinationId id) {
    return destinationIds.contains(id);
  }

  List<ProductModuleDestination> destinationsIn(
    ProductModuleDestinationRegistry registry,
  ) {
    return registry.destinationsForIds(destinationIds);
  }

  ProductModuleDestinationRegistry destinationRegistry({
    ProductModuleDestinationRegistry source =
        defaultProductModuleDestinationRegistry,
  }) {
    return ProductModuleDestinationRegistry(destinationsIn(source));
  }
}

/// Lookup container for available product experience profiles.
class ProductExperienceProfileRegistry {
  const ProductExperienceProfileRegistry(this.profiles);

  final List<ProductExperienceProfile> profiles;

  bool get isEmpty => profiles.isEmpty;
  bool get hasProfiles => profiles.isNotEmpty;

  ProductExperienceProfile? profileForId(ProductExperienceProfileId id) {
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }

    return null;
  }

  ProductExperienceProfile? profileForValue(String value) {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) return null;

    for (final profile in profiles) {
      if (profile.id.value == normalizedValue) return profile;
    }

    return null;
  }

  ProductExperienceProfile profileOrFallback(ProductExperienceProfileId id) {
    return profileForId(id) ?? fallbackProfile;
  }

  ProductExperienceProfile get fallbackProfile {
    if (profiles.isEmpty) return productFullSuiteExperienceProfile;
    return profiles.first;
  }
}

const productFullSuiteExperienceProfile = ProductExperienceProfile(
  id: ProductExperienceProfileId.fullSuite,
  workspaceTitle: 'Products',
  workspaceSubtitle: 'Catalog and stock health',
  workspaceDescription:
      'Central product directory for SKU, pricing, category, stock health, and product catalog operations.',
  destinationIds: defaultProductModuleDestinationIds,
);

const productCoreOperationsExperienceProfile = ProductExperienceProfile(
  id: ProductExperienceProfileId.coreOperations,
  workspaceTitle: 'Products',
  workspaceSubtitle: 'Catalog and stock health',
  workspaceDescription:
      'Core product workspace for catalog setup, management, stock operations, and count variance review.',
  destinationIds: [
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
    ProductModuleDestinationId.addProduct,
    ProductModuleDestinationId.stockMovements,
    ProductModuleDestinationId.addStockMovement,
    ProductModuleDestinationId.stockOpname,
    ProductModuleDestinationId.scanProduct,
    ProductModuleDestinationId.discrepancyReport,
  ],
  defaultPackId: ProductManagementPackId.coreCatalog,
);

const productCatalogOperationsExperienceProfile = ProductExperienceProfile(
  id: ProductExperienceProfileId.catalogOperations,
  workspaceTitle: 'Product Catalog',
  workspaceSubtitle: 'Catalog operations',
  workspaceDescription:
      'Focused catalog workspace for product setup, category health, pricing readiness, and channel availability.',
  destinationIds: [
    ProductModuleDestinationId.catalog,
    ProductModuleDestinationId.addProduct,
    ProductModuleDestinationId.categoryManagement,
    ProductModuleDestinationId.pricingManagement,
    ProductModuleDestinationId.availabilityManagement,
    ProductModuleDestinationId.channelReadiness,
  ],
);

const productFreshGoodsExperienceProfile = ProductExperienceProfile(
  id: ProductExperienceProfileId.freshGoods,
  workspaceTitle: 'Fresh Goods',
  workspaceSubtitle: 'Fresh inventory operations',
  workspaceDescription:
      'Fresh-goods product workspace for expiry, batch, count, setup, and channel readiness workflows.',
  destinationIds: [
    ProductModuleDestinationId.catalog,
    ProductModuleDestinationId.freshnessReview,
    ProductModuleDestinationId.stockOpname,
    ProductModuleDestinationId.scanProduct,
    ProductModuleDestinationId.discrepancyReport,
    ProductModuleDestinationId.availabilityManagement,
    ProductModuleDestinationId.channelReadiness,
    ProductModuleDestinationId.setupTargets,
    ProductModuleDestinationId.packContracts,
  ],
  defaultPackId: ProductManagementPackId.groceryFreshGoods,
  defaultChannelProfileId: groceryFreshGoodsProfileId,
);

const productOmnichannelCommerceExperienceProfile = ProductExperienceProfile(
  id: ProductExperienceProfileId.omnichannelCommerce,
  workspaceTitle: 'Omnichannel Products',
  workspaceSubtitle: 'Channel-ready catalog',
  workspaceDescription:
      'Product workspace for coordinating catalog, pricing, availability, relationships, and channel readiness across selling channels.',
  destinationIds: [
    ProductModuleDestinationId.strategy,
    ProductModuleDestinationId.catalog,
    ProductModuleDestinationId.addProduct,
    ProductModuleDestinationId.channelReadiness,
    ProductModuleDestinationId.availabilityManagement,
    ProductModuleDestinationId.pricingManagement,
    ProductModuleDestinationId.relationshipManagement,
    ProductModuleDestinationId.stockMovements,
  ],
  defaultChannelProfileId: ProductSalesChannelProfileId.digitalCommerce,
);

const productStockControlExperienceProfile = ProductExperienceProfile(
  id: ProductExperienceProfileId.stockControl,
  workspaceTitle: 'Product Stock Control',
  workspaceSubtitle: 'Counts, ledger, and variance',
  workspaceDescription:
      'Product workspace for stock movement review, physical counts, scan capture, and discrepancy follow-up.',
  destinationIds: [
    ProductModuleDestinationId.catalog,
    ProductModuleDestinationId.stockMovements,
    ProductModuleDestinationId.addStockMovement,
    ProductModuleDestinationId.stockOpname,
    ProductModuleDestinationId.scanProduct,
    ProductModuleDestinationId.discrepancyReport,
  ],
);

const productSetupContractsExperienceProfile = ProductExperienceProfile(
  id: ProductExperienceProfileId.setupContracts,
  workspaceTitle: 'Product Setup',
  workspaceSubtitle: 'Contracts and activation',
  workspaceDescription:
      'Product workspace for pack setup targets, data contracts, extension hooks, and activation readiness.',
  destinationIds: [
    ProductModuleDestinationId.setupTargets,
    ProductModuleDestinationId.packContracts,
    ProductModuleDestinationId.strategy,
    ProductModuleDestinationId.catalog,
  ],
);

const defaultProductExperienceProfiles = [
  productFullSuiteExperienceProfile,
  productCoreOperationsExperienceProfile,
  productCatalogOperationsExperienceProfile,
  productFreshGoodsExperienceProfile,
  productOmnichannelCommerceExperienceProfile,
  productStockControlExperienceProfile,
  productSetupContractsExperienceProfile,
];

const defaultProductExperienceProfileRegistry =
    ProductExperienceProfileRegistry(defaultProductExperienceProfiles);

/// Resolves the default workspace profile for a product management pack.
ProductExperienceProfile productExperienceProfileForManagementPackId(
  ProductManagementPackId id,
) {
  if (id == ProductManagementPackId.groceryFreshGoods) {
    return productFreshGoodsExperienceProfile;
  }

  return productCoreOperationsExperienceProfile;
}
