import 'package:flutter/material.dart';

import '../models/management_suite_destination.dart';
import '../models/product_module_destination.dart';
import '../utils/management_route_mode.dart';

/// Navigation metadata for a product management suite destination.
class ProductManagementSuiteNavigationItem {
  const ProductManagementSuiteNavigationItem({
    required this.destination,
    required this.label,
    required this.subtitle,
    required this.moduleDestination,
    required this.icon,
  });

  final ProductManagementSuiteDestination destination;
  final String label;
  final String subtitle;
  final ProductModuleDestination moduleDestination;
  final IconData icon;

  String get path => moduleDestination.path;
}

/// Logical navigation section used to group related suite destinations.
class ProductManagementSuiteNavigationSection {
  const ProductManagementSuiteNavigationSection({
    required this.id,
    required this.label,
    required this.items,
  });

  final String id;
  final String label;
  final List<ProductManagementSuiteNavigationItem> items;

  bool get isEmpty => items.isEmpty;
  bool get hasItems => items.isNotEmpty;

  bool contains(ProductManagementSuiteDestination destination) {
    return items.any((item) => item.destination == destination);
  }
}

const productManagementSuiteStrategyItem = ProductManagementSuiteNavigationItem(
  destination: ProductManagementSuiteDestination.strategy,
  label: 'Strategy',
  subtitle: 'Product packs, presets, and active channel behavior',
  moduleDestination: productStrategyDestination,
  icon: Icons.space_dashboard_rounded,
);

const productManagementSuiteAssortmentPlanningItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.assortmentPlanning,
      label: 'Assortment',
      subtitle: 'Category coverage, range health, and launch gaps',
      moduleDestination: productAssortmentPlanningDestination,
      icon: Icons.view_cozy_rounded,
    );

const productManagementSuiteCategoryManagementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.categoryManagement,
      label: 'Categories',
      subtitle: 'Taxonomy coverage, uncategorized products, and risk',
      moduleDestination: productCategoryManagementDestination,
      icon: Icons.category_rounded,
    );

const productManagementSuitePricingManagementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.pricingManagement,
      label: 'Pricing',
      subtitle: 'Price coverage, margin risk, and pricing outliers',
      moduleDestination: productPricingManagementDestination,
      icon: Icons.sell_rounded,
    );

const productManagementSuiteSourcingManagementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.sourcingManagement,
      label: 'Sourcing',
      subtitle: 'Supplier coverage, cost visibility, and supply risk',
      moduleDestination: productSourcingManagementDestination,
      icon: Icons.local_shipping_rounded,
    );

const productManagementSuiteLifecycleManagementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.lifecycleManagement,
      label: 'Lifecycle',
      subtitle: 'Launch state, blockers, and retirement risk',
      moduleDestination: productLifecycleManagementDestination,
      icon: Icons.flag_circle_rounded,
    );

const productManagementSuiteVariantManagementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.variantManagement,
      label: 'Variants',
      subtitle: 'Families, options, bundles, and SKU variants',
      moduleDestination: productVariantManagementDestination,
      icon: Icons.layers_rounded,
    );

const productManagementSuiteRelationshipManagementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.relationshipManagement,
      label: 'Relations',
      subtitle: 'Substitutes, bundles, add-ons, and cross-sells',
      moduleDestination: productRelationshipManagementDestination,
      icon: Icons.link_rounded,
    );

const productManagementSuiteAvailabilityManagementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.availabilityManagement,
      label: 'Availability',
      subtitle: 'Channel access, stock gates, and selling windows',
      moduleDestination: productAvailabilityManagementDestination,
      icon: Icons.event_available_rounded,
    );

const productManagementSuiteChannelReadinessItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.channelReadiness,
      label: 'Channels',
      subtitle: 'Launch coverage across active selling channels',
      moduleDestination: productChannelReadinessDestination,
      icon: Icons.hub_rounded,
    );

const productManagementSuiteSetupTargetsItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.setupTargets,
      label: 'Setup',
      subtitle: 'Pack-aware setup targets and readiness prompts',
      moduleDestination: productSetupTargetsDestination,
      icon: Icons.rule_folder_rounded,
    );

const productManagementSuitePackContractsItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.packContracts,
      label: 'Contracts',
      subtitle: 'Required fields, runtime packs, and extension hooks',
      moduleDestination: productPackContractsDestination,
      icon: Icons.fact_check_rounded,
    );

const productManagementSuiteCatalogItem = ProductManagementSuiteNavigationItem(
  destination: ProductManagementSuiteDestination.catalog,
  label: 'Catalog',
  subtitle: 'Catalog review, product data, and launch fixes',
  moduleDestination: productCatalogDestination,
  icon: Icons.inventory_2_rounded,
);

const productManagementSuiteFreshnessReviewItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.freshnessReview,
      label: 'Freshness',
      subtitle: 'Expiry, batch, and fresh-stock readiness',
      moduleDestination: productFreshnessReviewDestination,
      icon: Icons.eco_rounded,
    );

const productManagementSuiteAddProductItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.addProduct,
      label: 'Add product',
      subtitle: 'Create pack-aware product records',
      moduleDestination: productAddProductDestination,
      icon: Icons.add_box_rounded,
    );

const productManagementSuiteStockMovementsItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.stockMovements,
      label: 'Movements',
      subtitle: 'Movement ledger and stock activity',
      moduleDestination: productStockMovementsDestination,
      icon: Icons.swap_vert_rounded,
    );

const productManagementSuiteAddStockMovementItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.addStockMovement,
      label: 'Add movement',
      subtitle: 'Record inbound and outbound stock',
      moduleDestination: productAddStockMovementDestination,
      icon: Icons.playlist_add_rounded,
    );

const productManagementSuiteStockOpnameItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.stockOpname,
      label: 'Stock count',
      subtitle: 'Physical count queue and variance capture',
      moduleDestination: productStockOpnameDestination,
      icon: Icons.fact_check_rounded,
    );

const productManagementSuiteScanProductItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.scanProduct,
      label: 'Scan',
      subtitle: 'Count by barcode or product id',
      moduleDestination: productScanProductDestination,
      icon: Icons.qr_code_scanner_rounded,
    );

const productManagementSuiteDiscrepancyReportItem =
    ProductManagementSuiteNavigationItem(
      destination: ProductManagementSuiteDestination.discrepancyReport,
      label: 'Discrepancy',
      subtitle: 'Count variance review',
      moduleDestination: productDiscrepancyReportDestination,
      icon: Icons.difference_rounded,
    );

const productManagementSuiteNavigationSections = [
  ProductManagementSuiteNavigationSection(
    id: 'planning',
    label: 'Planning',
    items: [
      productManagementSuiteStrategyItem,
      productManagementSuiteAssortmentPlanningItem,
      productManagementSuiteCategoryManagementItem,
    ],
  ),
  ProductManagementSuiteNavigationSection(
    id: 'commercial',
    label: 'Commercial',
    items: [
      productManagementSuitePricingManagementItem,
      productManagementSuiteSourcingManagementItem,
      productManagementSuiteAvailabilityManagementItem,
      productManagementSuiteChannelReadinessItem,
    ],
  ),
  ProductManagementSuiteNavigationSection(
    id: 'structure',
    label: 'Structure',
    items: [
      productManagementSuiteLifecycleManagementItem,
      productManagementSuiteVariantManagementItem,
      productManagementSuiteRelationshipManagementItem,
    ],
  ),
  ProductManagementSuiteNavigationSection(
    id: 'operations',
    label: 'Operations',
    items: [
      productManagementSuiteCatalogItem,
      productManagementSuiteAddProductItem,
      productManagementSuiteFreshnessReviewItem,
      productManagementSuiteStockMovementsItem,
      productManagementSuiteAddStockMovementItem,
      productManagementSuiteStockOpnameItem,
      productManagementSuiteScanProductItem,
      productManagementSuiteDiscrepancyReportItem,
      productManagementSuiteSetupTargetsItem,
      productManagementSuitePackContractsItem,
    ],
  ),
];

const productManagementSuiteNavigationItems = [
  productManagementSuiteStrategyItem,
  productManagementSuiteAssortmentPlanningItem,
  productManagementSuiteCategoryManagementItem,
  productManagementSuitePricingManagementItem,
  productManagementSuiteSourcingManagementItem,
  productManagementSuiteAvailabilityManagementItem,
  productManagementSuiteChannelReadinessItem,
  productManagementSuiteLifecycleManagementItem,
  productManagementSuiteVariantManagementItem,
  productManagementSuiteRelationshipManagementItem,
  productManagementSuiteCatalogItem,
  productManagementSuiteAddProductItem,
  productManagementSuiteFreshnessReviewItem,
  productManagementSuiteStockMovementsItem,
  productManagementSuiteAddStockMovementItem,
  productManagementSuiteStockOpnameItem,
  productManagementSuiteScanProductItem,
  productManagementSuiteDiscrepancyReportItem,
  productManagementSuiteSetupTargetsItem,
  productManagementSuitePackContractsItem,
];

/// Flattens all visible navigation items from the given sections.
List<ProductManagementSuiteNavigationItem>
productManagementSuiteNavigationItemsForSections(
  List<ProductManagementSuiteNavigationSection> sections,
) {
  return [
    for (final section in sections)
      if (section.hasItems) ...section.items,
  ];
}

/// Finds the navigation item for a destination, falling back to the first item.
ProductManagementSuiteNavigationItem productManagementSuiteNavigationItemFor(
  ProductManagementSuiteDestination destination, {
  List<ProductManagementSuiteNavigationSection> sections =
      productManagementSuiteNavigationSections,
}) {
  for (final item in productManagementSuiteNavigationItemsForSections(
    sections,
  )) {
    if (item.destination == destination) return item;
  }

  return productManagementSuiteNavigationItems.first;
}

/// Finds the section that owns a destination, when present.
ProductManagementSuiteNavigationSection?
productManagementSuiteNavigationSectionFor(
  ProductManagementSuiteDestination destination, {
  List<ProductManagementSuiteNavigationSection> sections =
      productManagementSuiteNavigationSections,
}) {
  for (final section in sections) {
    if (section.contains(destination)) return section;
  }

  return null;
}

/// Builds a route for a suite destination while preserving active mode context.
String productManagementSuiteDestinationRoute(
  ProductManagementSuiteDestination destination, {
  required ProductManagementRouteMode mode,
}) {
  final item = productManagementSuiteNavigationItemFor(destination);

  return productRouteWithManagementMode(item.path, mode: mode);
}
