import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut_intent.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('workspace shortcuts build default module and attention actions', () {
    final shortcuts = buildProductWorkspaceShortcuts(_summary);

    expect(shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.strategy,
      ProductWorkspaceShortcutId.assortmentPlanning,
      ProductWorkspaceShortcutId.categoryManagement,
      ProductWorkspaceShortcutId.pricingManagement,
      ProductWorkspaceShortcutId.sourcingManagement,
      ProductWorkspaceShortcutId.lifecycleManagement,
      ProductWorkspaceShortcutId.variantManagement,
      ProductWorkspaceShortcutId.relationshipManagement,
      ProductWorkspaceShortcutId.availabilityManagement,
      ProductWorkspaceShortcutId.channelReadiness,
      ProductWorkspaceShortcutId.setupTargets,
      ProductWorkspaceShortcutId.packContracts,
      ProductWorkspaceShortcutId.catalog,
      ProductWorkspaceShortcutId.freshnessReview,
      ProductWorkspaceShortcutId.addProduct,
      ProductWorkspaceShortcutId.stockMovements,
      ProductWorkspaceShortcutId.addStockMovement,
      ProductWorkspaceShortcutId.stockOpname,
      ProductWorkspaceShortcutId.scanProduct,
      ProductWorkspaceShortcutId.discrepancyReport,
      ProductWorkspaceShortcutId.attentionReview,
    ]);
    expect(shortcuts.first.title, 'Product Strategy');
    expect(shortcuts.first.status, 'Strategy');
    expect(shortcuts.first.destination, productStrategyDestination);
    expect(shortcuts.first.routePath, productStrategyDestination.path);
    expect(shortcuts.first.canNavigate, isTrue);

    final assortmentPlanning = shortcuts.singleWhere(
      (shortcut) =>
          shortcut.id == ProductWorkspaceShortcutId.assortmentPlanning,
    );
    expect(assortmentPlanning.title, 'Assortment Planning');
    expect(assortmentPlanning.status, 'Plan');
    expect(
      assortmentPlanning.routePath,
      productAssortmentPlanningDestination.path,
    );

    final categoryManagement = shortcuts.singleWhere(
      (shortcut) =>
          shortcut.id == ProductWorkspaceShortcutId.categoryManagement,
    );
    expect(categoryManagement.title, 'Category Management');
    expect(categoryManagement.status, '4 categories');
    expect(
      categoryManagement.routePath,
      productCategoryManagementDestination.path,
    );

    final pricingManagement = shortcuts.singleWhere(
      (shortcut) => shortcut.id == ProductWorkspaceShortcutId.pricingManagement,
    );
    expect(pricingManagement.title, 'Pricing Management');
    expect(pricingManagement.status, 'Pricing');
    expect(
      pricingManagement.routePath,
      productPricingManagementDestination.path,
    );

    final sourcingManagement = shortcuts.singleWhere(
      (shortcut) =>
          shortcut.id == ProductWorkspaceShortcutId.sourcingManagement,
    );
    expect(sourcingManagement.title, 'Sourcing Management');
    expect(sourcingManagement.status, 'Sourcing');
    expect(
      sourcingManagement.routePath,
      productSourcingManagementDestination.path,
    );

    final lifecycleManagement = shortcuts.singleWhere(
      (shortcut) =>
          shortcut.id == ProductWorkspaceShortcutId.lifecycleManagement,
    );
    expect(lifecycleManagement.title, 'Lifecycle Management');
    expect(lifecycleManagement.status, 'Lifecycle');
    expect(
      lifecycleManagement.routePath,
      productLifecycleManagementDestination.path,
    );

    final variantManagement = shortcuts.singleWhere(
      (shortcut) => shortcut.id == ProductWorkspaceShortcutId.variantManagement,
    );
    expect(variantManagement.title, 'Variant Management');
    expect(variantManagement.status, 'Variants');
    expect(
      variantManagement.routePath,
      productVariantManagementDestination.path,
    );

    final relationshipManagement = shortcuts.singleWhere(
      (shortcut) =>
          shortcut.id == ProductWorkspaceShortcutId.relationshipManagement,
    );
    expect(relationshipManagement.title, 'Relationship Management');
    expect(relationshipManagement.status, 'Relations');
    expect(
      relationshipManagement.routePath,
      productRelationshipManagementDestination.path,
    );

    final availabilityManagement = shortcuts.singleWhere(
      (shortcut) =>
          shortcut.id == ProductWorkspaceShortcutId.availabilityManagement,
    );
    expect(availabilityManagement.title, 'Availability Rules');
    expect(availabilityManagement.status, 'Availability');
    expect(
      availabilityManagement.routePath,
      productAvailabilityManagementDestination.path,
    );

    final catalog = shortcuts.singleWhere(
      (shortcut) => shortcut.id == ProductWorkspaceShortcutId.catalog,
    );
    final freshnessReview = shortcuts.singleWhere(
      (shortcut) => shortcut.id == ProductWorkspaceShortcutId.freshnessReview,
    );
    final addProduct = shortcuts.singleWhere(
      (shortcut) => shortcut.id == ProductWorkspaceShortcutId.addProduct,
    );

    expect(catalog.title, 'Product Catalog');
    expect(catalog.status, '12 products');
    expect(catalog.destination, productCatalogDestination);
    expect(catalog.routePath, productCatalogDestination.path);
    expect(catalog.canNavigate, isTrue);
    expect(freshnessReview.title, 'Freshness Review');
    expect(freshnessReview.status, 'Freshness');
    expect(freshnessReview.destination, productFreshnessReviewDestination);
    expect(freshnessReview.routePath, ProductRoutes.freshnessReviewPath);
    expect(freshnessReview.canNavigate, isTrue);
    expect(addProduct.title, 'Add Product');
    expect(addProduct.status, 'Create');
    expect(addProduct.routePath, ProductRoutes.addProductPath);
    expect(shortcuts.last.title, 'Attention Review');
    expect(shortcuts.last.status, '5 review');
    expect(shortcuts.last.hasDestination, isFalse);
    expect(
      shortcuts.last.routePath,
      '/products?filter=attention&review=Attention+Review',
    );
    expect(shortcuts.last.canNavigate, isTrue);
  });

  test('workspace shortcuts can omit attention action', () {
    final shortcuts = buildProductWorkspaceShortcuts(
      _summary,
      includeAttentionReview: false,
    );

    expect(shortcuts.length, defaultProductModuleDestinations.length);
    expect(
      shortcuts.any(
        (shortcut) => shortcut.id == ProductWorkspaceShortcutId.attentionReview,
      ),
      isFalse,
    );
  });

  test('workspace shortcuts can build custom destination sets', () {
    final shortcuts = buildProductWorkspaceShortcuts(
      _summary,
      destinations: [productCatalogDestination],
      includeAttentionReview: false,
    );

    expect(shortcuts, hasLength(1));
    expect(shortcuts.single.id, ProductWorkspaceShortcutId.catalog);
    expect(shortcuts.single.destination, productCatalogDestination);
    expect(shortcuts.single.routePath, ProductRoutes.catalogPath);
  });

  test('workspace shortcuts can build from a destination registry', () {
    const registry = ProductModuleDestinationRegistry([
      productCatalogDestination,
      productFreshnessReviewDestination,
    ]);

    final shortcuts = buildProductWorkspaceShortcuts(
      _summary,
      registry: registry,
      includeAttentionReview: false,
    );

    expect(shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.catalog,
      ProductWorkspaceShortcutId.freshnessReview,
    ]);
    expect(shortcuts.first.destination, productCatalogDestination);
    expect(shortcuts.last.destination, productFreshnessReviewDestination);
  });

  test('workspace shortcuts can build from an experience profile', () {
    final shortcuts = buildProductWorkspaceShortcuts(
      _summary,
      experienceProfile: productStockControlExperienceProfile,
      includeAttentionReview: false,
    );

    expect(shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.catalog,
      ProductWorkspaceShortcutId.stockMovements,
      ProductWorkspaceShortcutId.addStockMovement,
      ProductWorkspaceShortcutId.stockOpname,
      ProductWorkspaceShortcutId.scanProduct,
      ProductWorkspaceShortcutId.discrepancyReport,
    ]);
    expect(shortcuts.first.status, '12 products');
    expect(shortcuts.last.status, 'Audit');
  });

  test('workspace shortcuts can represent gated actions', () {
    final shortcut = ProductWorkspaceShortcut(
      id: ProductWorkspaceShortcutId.catalog,
      title: 'Wholesale Catalog',
      subtitle: 'Partner-ready catalog management',
      status: 'Setup',
      destination: productCatalogDestination,
      isEnabled: false,
      disabledReason: 'Enable wholesale pack first',
    );

    expect(shortcut.hasDestination, isTrue);
    expect(shortcut.isDisabled, isTrue);
    expect(shortcut.hasRouteIntent, isTrue);
    expect(shortcut.canNavigate, isFalse);
    expect(shortcut.disabledReason, 'Enable wholesale pack first');
  });

  test('workspace shortcuts can carry route intent without destination', () {
    final shortcut = ProductWorkspaceShortcut(
      id: ProductWorkspaceShortcutId.freshnessQueue,
      title: 'Freshness Queue',
      subtitle: 'Expiry and batch work',
      status: 'Route',
      intent: ProductWorkspaceShortcutIntent.route('/products/freshness'),
    );

    expect(shortcut.hasDestination, isFalse);
    expect(shortcut.hasRouteIntent, isTrue);
    expect(shortcut.routePath, '/products/freshness');
    expect(shortcut.canNavigate, isTrue);
  });

  test('workspace shortcuts can carry setup route intent separately', () {
    final shortcut = ProductWorkspaceShortcut(
      id: ProductWorkspaceShortcutId.freshnessQueue,
      title: 'Freshness Queue',
      subtitle: 'Expiry and batch work',
      status: 'Setup',
      intent: ProductWorkspaceShortcutIntent.route('/products/freshness'),
      setupIntent: ProductWorkspaceShortcutIntent.route(
        ProductRoutes.workspaceSetupUri(ProductWorkspaceSetupTarget.freshness),
      ),
      isEnabled: false,
      disabledReason: 'Connect freshness route first',
    );

    expect(shortcut.hasRouteIntent, isTrue);
    expect(shortcut.routePath, '/products/freshness');
    expect(shortcut.canNavigate, isFalse);
    expect(shortcut.hasSetupIntent, isTrue);
    expect(
      shortcut.setupRoutePath,
      ProductRoutes.workspaceSetupUri(ProductWorkspaceSetupTarget.freshness),
    );
  });
}

const _summary = InventoryProductCatalogSummary(
  productCount: 12,
  trackedProductCount: 9,
  inStockProductCount: 7,
  untrackedProductCount: 3,
  attentionProductCount: 5,
  totalQuantity: 80,
  totalInventoryValue: 1200,
  categoryCount: 4,
);
