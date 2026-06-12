import '../../inventory/models/inventory_product_catalog.dart';
import '../product_routes.dart';
import '../utils/product_catalog_review_target.dart';
import 'experience_profile.dart';
import 'product_module_destination.dart';
import 'product_workspace_shortcut_intent.dart';

enum ProductWorkspaceShortcutId {
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
  freshnessQueue,
  attentionReview,
}

class ProductWorkspaceShortcut {
  const ProductWorkspaceShortcut({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    this.destination,
    this.intent,
    this.setupIntent,
    this.isEnabled = true,
    this.disabledReason,
  });

  final ProductWorkspaceShortcutId id;
  final String title;
  final String subtitle;
  final String status;
  final ProductModuleDestination? destination;
  final ProductWorkspaceShortcutIntent? intent;
  final ProductWorkspaceShortcutIntent? setupIntent;
  final bool isEnabled;
  final String? disabledReason;

  bool get hasDestination => destination != null;
  bool get isDisabled => !isEnabled;
  bool get hasRouteIntent => routePath != null;
  bool get hasSetupIntent => setupRoutePath != null;
  bool get canNavigate => isEnabled && hasRouteIntent;

  String? get routePath {
    final intentPath = intent?.routePath;
    if (intentPath != null) return intentPath;

    final destinationPath = destination?.path.trim();
    return destinationPath == null || destinationPath.isEmpty
        ? null
        : destinationPath;
  }

  String? get setupRoutePath => setupIntent?.routePath;

  static ProductWorkspaceShortcut fromDestination(
    ProductModuleDestination destination,
    InventoryProductCatalogSummary summary,
  ) {
    return ProductWorkspaceShortcut(
      id: _shortcutIdForDestination(destination.id),
      title: destination.title,
      subtitle: _subtitleForDestination(destination),
      status: _statusForDestination(destination, summary),
      destination: destination,
      intent: ProductWorkspaceShortcutIntent.route(destination.path),
    );
  }

  static ProductWorkspaceShortcut attentionReview(
    InventoryProductCatalogSummary summary,
  ) {
    return ProductWorkspaceShortcut(
      id: ProductWorkspaceShortcutId.attentionReview,
      title: 'Attention Review',
      subtitle: 'Open products that are low, empty, or untracked',
      status: '${summary.attentionProductCount} review',
      intent: ProductWorkspaceShortcutIntent.route(
        ProductRoutes.catalogUriForReviewTarget(
          const ProductCatalogReviewTarget(
            filter: InventoryProductCatalogFilter.attention,
            title: 'Attention Review',
          ),
        ),
      ),
    );
  }
}

List<ProductWorkspaceShortcut> buildProductWorkspaceShortcuts(
  InventoryProductCatalogSummary summary, {
  ProductExperienceProfile? experienceProfile,
  ProductModuleDestinationRegistry registry =
      defaultProductModuleDestinationRegistry,
  List<ProductModuleDestination>? destinations,
  bool? includeAttentionReview,
}) {
  final resolvedDestinations =
      destinations ??
      experienceProfile?.destinationsIn(registry) ??
      registry.destinations;
  final resolvedIncludeAttentionReview =
      includeAttentionReview ??
      experienceProfile?.includeAttentionReviewShortcut ??
      true;

  return [
    for (final destination in resolvedDestinations)
      ProductWorkspaceShortcut.fromDestination(destination, summary),
    if (resolvedIncludeAttentionReview)
      ProductWorkspaceShortcut.attentionReview(summary),
  ];
}

ProductWorkspaceShortcutId _shortcutIdForDestination(
  ProductModuleDestinationId id,
) {
  switch (id) {
    case ProductModuleDestinationId.strategy:
      return ProductWorkspaceShortcutId.strategy;
    case ProductModuleDestinationId.assortmentPlanning:
      return ProductWorkspaceShortcutId.assortmentPlanning;
    case ProductModuleDestinationId.categoryManagement:
      return ProductWorkspaceShortcutId.categoryManagement;
    case ProductModuleDestinationId.pricingManagement:
      return ProductWorkspaceShortcutId.pricingManagement;
    case ProductModuleDestinationId.sourcingManagement:
      return ProductWorkspaceShortcutId.sourcingManagement;
    case ProductModuleDestinationId.lifecycleManagement:
      return ProductWorkspaceShortcutId.lifecycleManagement;
    case ProductModuleDestinationId.variantManagement:
      return ProductWorkspaceShortcutId.variantManagement;
    case ProductModuleDestinationId.relationshipManagement:
      return ProductWorkspaceShortcutId.relationshipManagement;
    case ProductModuleDestinationId.availabilityManagement:
      return ProductWorkspaceShortcutId.availabilityManagement;
    case ProductModuleDestinationId.channelReadiness:
      return ProductWorkspaceShortcutId.channelReadiness;
    case ProductModuleDestinationId.setupTargets:
      return ProductWorkspaceShortcutId.setupTargets;
    case ProductModuleDestinationId.packContracts:
      return ProductWorkspaceShortcutId.packContracts;
    case ProductModuleDestinationId.catalog:
      return ProductWorkspaceShortcutId.catalog;
    case ProductModuleDestinationId.freshnessReview:
      return ProductWorkspaceShortcutId.freshnessReview;
    case ProductModuleDestinationId.addProduct:
      return ProductWorkspaceShortcutId.addProduct;
    case ProductModuleDestinationId.stockMovements:
      return ProductWorkspaceShortcutId.stockMovements;
    case ProductModuleDestinationId.addStockMovement:
      return ProductWorkspaceShortcutId.addStockMovement;
    case ProductModuleDestinationId.stockOpname:
      return ProductWorkspaceShortcutId.stockOpname;
    case ProductModuleDestinationId.scanProduct:
      return ProductWorkspaceShortcutId.scanProduct;
    case ProductModuleDestinationId.discrepancyReport:
      return ProductWorkspaceShortcutId.discrepancyReport;
  }
}

String _subtitleForDestination(ProductModuleDestination destination) {
  switch (destination.id) {
    case ProductModuleDestinationId.strategy:
      return 'Switch product packs, presets, and selling channel behavior';
    case ProductModuleDestinationId.assortmentPlanning:
      return 'Plan category coverage, launch readiness, and segment gaps';
    case ProductModuleDestinationId.categoryManagement:
      return 'Manage taxonomy coverage, uncategorized products, and risk';
    case ProductModuleDestinationId.pricingManagement:
      return 'Review price coverage, margin risk, and pricing outliers';
    case ProductModuleDestinationId.sourcingManagement:
      return 'Review supplier coverage, cost visibility, and supply risk';
    case ProductModuleDestinationId.lifecycleManagement:
      return 'Govern draft, active, blocked, retiring, and archived products';
    case ProductModuleDestinationId.variantManagement:
      return 'Review variant families, option coverage, and SKU variants';
    case ProductModuleDestinationId.relationshipManagement:
      return 'Map substitutes, bundles, add-ons, upsells, and cross-sells';
    case ProductModuleDestinationId.availabilityManagement:
      return 'Manage channel access, stock gates, and selling windows';
    case ProductModuleDestinationId.channelReadiness:
      return 'Review product coverage across active selling channels';
    case ProductModuleDestinationId.setupTargets:
      return 'Open pack-aware setup requirements and activation prompts';
    case ProductModuleDestinationId.packContracts:
      return 'Audit required fields, runtime packs, and extension hooks';
    case ProductModuleDestinationId.catalog:
      return 'Search, create, edit, and review product health';
    case ProductModuleDestinationId.freshnessReview:
      return 'Open expiry, batch, and fresh-stock readiness review';
    case ProductModuleDestinationId.addProduct:
      return 'Create products with the active management pack fields';
    case ProductModuleDestinationId.stockMovements:
      return 'Review product stock movement history and filters';
    case ProductModuleDestinationId.addStockMovement:
      return 'Record inbound or outbound stock for a product';
    case ProductModuleDestinationId.stockOpname:
      return 'Open the product count queue and count status';
    case ProductModuleDestinationId.scanProduct:
      return 'Capture actual stock by product id or barcode';
    case ProductModuleDestinationId.discrepancyReport:
      return 'Review count variances and pending counts';
  }
}

String _statusForDestination(
  ProductModuleDestination destination,
  InventoryProductCatalogSummary summary,
) {
  switch (destination.id) {
    case ProductModuleDestinationId.strategy:
      return 'Strategy';
    case ProductModuleDestinationId.assortmentPlanning:
      return 'Plan';
    case ProductModuleDestinationId.categoryManagement:
      return '${summary.categoryCount} categories';
    case ProductModuleDestinationId.pricingManagement:
      return 'Pricing';
    case ProductModuleDestinationId.sourcingManagement:
      return 'Sourcing';
    case ProductModuleDestinationId.lifecycleManagement:
      return 'Lifecycle';
    case ProductModuleDestinationId.variantManagement:
      return 'Variants';
    case ProductModuleDestinationId.relationshipManagement:
      return 'Relations';
    case ProductModuleDestinationId.availabilityManagement:
      return 'Availability';
    case ProductModuleDestinationId.channelReadiness:
      return 'Channels';
    case ProductModuleDestinationId.setupTargets:
      return 'Setup';
    case ProductModuleDestinationId.packContracts:
      return 'Contracts';
    case ProductModuleDestinationId.catalog:
      return '${summary.productCount} products';
    case ProductModuleDestinationId.freshnessReview:
      return 'Freshness';
    case ProductModuleDestinationId.addProduct:
      return 'Create';
    case ProductModuleDestinationId.stockMovements:
      return 'Ledger';
    case ProductModuleDestinationId.addStockMovement:
      return 'Record';
    case ProductModuleDestinationId.stockOpname:
      return 'Count';
    case ProductModuleDestinationId.scanProduct:
      return 'Scan';
    case ProductModuleDestinationId.discrepancyReport:
      return 'Audit';
  }
}
