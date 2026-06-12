import 'experience_profile.dart';
import 'experience_profile_launch_target.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

/// Stable identifier for a reusable product edition.
class ProductEditionId {
  const ProductEditionId(this.value);

  static const coreRetail = ProductEditionId('core_retail');
  static const catalogOperations = ProductEditionId('catalog_operations');
  static const counterService = ProductEditionId('counter_service');
  static const digitalCommerce = ProductEditionId('digital_commerce');
  static const groceryFreshGoods = ProductEditionId('grocery_fresh_goods');
  static const kioskSelfService = ProductEditionId('kiosk_self_service');
  static const stockControl = ProductEditionId('stock_control');
  static const setupContracts = ProductEditionId('setup_contracts');

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductEditionId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Business segment for grouping editions in launch and discovery surfaces.
enum ProductEditionKind {
  retail,
  grocery,
  counterService,
  digitalCommerce,
  kiosk,
  operations,
  setup,
}

/// Presentation labels for product edition segment types.
extension ProductEditionKindLabel on ProductEditionKind {
  String get label {
    return switch (this) {
      ProductEditionKind.retail => 'Retail',
      ProductEditionKind.grocery => 'Grocery',
      ProductEditionKind.counterService => 'Counter service',
      ProductEditionKind.digitalCommerce => 'Digital commerce',
      ProductEditionKind.kiosk => 'Self-service kiosk',
      ProductEditionKind.operations => 'Operations',
      ProductEditionKind.setup => 'Setup',
    };
  }
}

/// Releasable product configuration assembled from shared product modules.
class ProductEdition {
  const ProductEdition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.kind,
    required this.experienceProfileId,
    required this.managementPackId,
    required this.channelProfileId,
    this.capabilityLabels = const [],
  });

  final ProductEditionId id;
  final String title;
  final String subtitle;
  final String description;
  final ProductEditionKind kind;
  final ProductExperienceProfileId experienceProfileId;
  final ProductManagementPackId managementPackId;
  final ProductSalesChannelProfileId channelProfileId;
  final List<String> capabilityLabels;

  String get kindLabel => kind.label;

  String get capabilitySummaryLabel {
    if (capabilityLabels.isEmpty) return 'Reusable product edition';
    if (capabilityLabels.length <= 2) return capabilityLabels.join(', ');

    return '${capabilityLabels.first}, ${capabilityLabels[1]} + '
        '${capabilityLabels.length - 2} more';
  }

  bool usesExperienceProfile(ProductExperienceProfileId id) {
    return experienceProfileId == id;
  }

  ProductExperienceProfile experienceProfileIn(
    ProductExperienceProfileRegistry registry,
  ) {
    return registry.profileForId(experienceProfileId) ??
        registry.fallbackProfile;
  }

  ProductExperienceProfileLaunchTarget launchTarget({
    ProductExperienceProfileRegistry profileRegistry =
        defaultProductExperienceProfileRegistry,
  }) {
    return ProductExperienceProfileLaunchTarget(
      profile: experienceProfileIn(profileRegistry),
      packId: managementPackId,
      channelProfileId: channelProfileId,
      modeSource: ProductExperienceProfileLaunchModeSource.edition,
    );
  }
}

/// Lookup container for available product editions.
class ProductEditionRegistry {
  const ProductEditionRegistry(this.editions);

  final List<ProductEdition> editions;

  bool get isEmpty => editions.isEmpty;
  bool get hasEditions => editions.isNotEmpty;

  ProductEdition? editionForId(ProductEditionId id) {
    for (final edition in editions) {
      if (edition.id == id) return edition;
    }

    return null;
  }

  ProductEdition? editionForValue(String value) {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) return null;

    for (final edition in editions) {
      if (edition.id.value == normalizedValue) return edition;
    }

    return null;
  }

  ProductEdition get fallbackEdition {
    if (editions.isEmpty) return coreRetailProductEdition;
    return editions.first;
  }

  ProductEdition editionOrFallback(ProductEditionId id) {
    return editionForId(id) ?? fallbackEdition;
  }

  List<ProductEdition> editionsForExperienceProfile(
    ProductExperienceProfileId id,
  ) {
    return List.unmodifiable(
      editions.where((edition) => edition.usesExperienceProfile(id)),
    );
  }

  List<ProductEdition> editionsForKind(ProductEditionKind kind) {
    return List.unmodifiable(editions.where((edition) => edition.kind == kind));
  }
}

const coreRetailProductEdition = ProductEdition(
  id: ProductEditionId.coreRetail,
  title: 'Core Retail',
  subtitle: 'Reusable catalog, stock, and channel operations',
  description:
      'General retail edition for products that need catalog setup, stock tracking, and omnichannel readiness.',
  kind: ProductEditionKind.retail,
  experienceProfileId: ProductExperienceProfileId.coreOperations,
  managementPackId: ProductManagementPackId.coreCatalog,
  channelProfileId: ProductSalesChannelProfileId.omniRetail,
  capabilityLabels: [
    'Catalog operations',
    'Stock tracking',
    'Omnichannel readiness',
  ],
);

const catalogOperationsProductEdition = ProductEdition(
  id: ProductEditionId.catalogOperations,
  title: 'Catalog Operations',
  subtitle: 'Focused setup for catalog teams',
  description:
      'Catalog-first edition for SKU setup, category health, pricing readiness, and channel availability review.',
  kind: ProductEditionKind.operations,
  experienceProfileId: ProductExperienceProfileId.catalogOperations,
  managementPackId: ProductManagementPackId.coreCatalog,
  channelProfileId: ProductSalesChannelProfileId.omniRetail,
  capabilityLabels: ['SKU setup', 'Category health', 'Price readiness'],
);

const counterServiceProductEdition = ProductEdition(
  id: ProductEditionId.counterService,
  title: 'Counter Service',
  subtitle: 'Cashier-led product readiness',
  description:
      'Counter-service edition for fast checkout, scan readiness, sellable stock, and assisted kiosk queues.',
  kind: ProductEditionKind.counterService,
  experienceProfileId: ProductExperienceProfileId.catalogOperations,
  managementPackId: ProductManagementPackId.coreCatalog,
  channelProfileId: ProductSalesChannelProfileId.counterService,
  capabilityLabels: ['Fast checkout', 'Scan readiness', 'Sellable stock'],
);

const digitalCommerceProductEdition = ProductEdition(
  id: ProductEditionId.digitalCommerce,
  title: 'Digital Commerce',
  subtitle: 'Online and marketplace product readiness',
  description:
      'Digital-commerce edition for storefront listings, marketplace taxonomy, product copy, and online availability.',
  kind: ProductEditionKind.digitalCommerce,
  experienceProfileId: ProductExperienceProfileId.omnichannelCommerce,
  managementPackId: ProductManagementPackId.coreCatalog,
  channelProfileId: ProductSalesChannelProfileId.digitalCommerce,
  capabilityLabels: ['Online catalog', 'Marketplace listing', 'Product copy'],
);

const groceryFreshGoodsProductEdition = ProductEdition(
  id: ProductEditionId.groceryFreshGoods,
  title: 'Grocery Fresh Goods',
  subtitle: 'Expiry, batch, and freshness operations',
  description:
      'Fresh-goods edition for grocery, expiry-aware selling, batch traceability, weighted products, and freshness queues.',
  kind: ProductEditionKind.grocery,
  experienceProfileId: ProductExperienceProfileId.freshGoods,
  managementPackId: ProductManagementPackId.groceryFreshGoods,
  channelProfileId: groceryFreshGoodsProfileId,
  capabilityLabels: [
    'Expiry-aware selling',
    'Batch traceability',
    'Freshness queue',
  ],
);

const kioskSelfServiceProductEdition = ProductEdition(
  id: ProductEditionId.kioskSelfService,
  title: 'Self-Service Kiosk',
  subtitle: 'Fast scan-ready self-service products',
  description:
      'Kiosk edition for products that need barcode discipline, sellable stock, and self-service launch coverage.',
  kind: ProductEditionKind.kiosk,
  experienceProfileId: ProductExperienceProfileId.omnichannelCommerce,
  managementPackId: ProductManagementPackId.coreCatalog,
  channelProfileId: ProductSalesChannelProfileId.counterService,
  capabilityLabels: ['Kiosk scan flow', 'Barcode coverage', 'Stock gate'],
);

const stockControlProductEdition = ProductEdition(
  id: ProductEditionId.stockControl,
  title: 'Stock Control',
  subtitle: 'Counts, movement ledger, and variance review',
  description:
      'Stock-control edition for movement review, count capture, scan workflows, and discrepancy follow-up.',
  kind: ProductEditionKind.operations,
  experienceProfileId: ProductExperienceProfileId.stockControl,
  managementPackId: ProductManagementPackId.coreCatalog,
  channelProfileId: ProductSalesChannelProfileId.omniRetail,
  capabilityLabels: ['Stock counts', 'Movement ledger', 'Variance review'],
);

const setupContractsProductEdition = ProductEdition(
  id: ProductEditionId.setupContracts,
  title: 'Product Setup',
  subtitle: 'Contracts, packs, and activation readiness',
  description:
      'Setup edition for product pack contracts, setup targets, extension hooks, and activation readiness.',
  kind: ProductEditionKind.setup,
  experienceProfileId: ProductExperienceProfileId.setupContracts,
  managementPackId: ProductManagementPackId.coreCatalog,
  channelProfileId: ProductSalesChannelProfileId.omniRetail,
  capabilityLabels: ['Pack contracts', 'Setup targets', 'Extension hooks'],
);

const defaultProductEditions = [
  coreRetailProductEdition,
  catalogOperationsProductEdition,
  counterServiceProductEdition,
  digitalCommerceProductEdition,
  groceryFreshGoodsProductEdition,
  kioskSelfServiceProductEdition,
  stockControlProductEdition,
  setupContractsProductEdition,
];

const defaultProductEditionRegistry = ProductEditionRegistry(
  defaultProductEditions,
);
