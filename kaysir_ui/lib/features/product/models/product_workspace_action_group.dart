import '../../inventory/models/inventory_product_catalog.dart';
import 'experience_profile.dart';
import 'product_module_destination.dart';
import 'product_workspace_shortcut.dart';

const productWorkspaceManagementActionGroupId = 'management';
const productWorkspaceCatalogActionGroupId = 'catalog';
const productWorkspaceStockActionGroupId = 'stock';
const productWorkspaceFreshnessActionGroupId = 'freshness';
const productWorkspaceAuditActionGroupId = 'audit';

const productWorkspaceDefaultActionGroupOrder = [
  productWorkspaceManagementActionGroupId,
  productWorkspaceCatalogActionGroupId,
  productWorkspaceStockActionGroupId,
  productWorkspaceFreshnessActionGroupId,
  productWorkspaceAuditActionGroupId,
];

enum ProductWorkspaceActionGroupAvailability { ready, partial, gated }

class ProductWorkspaceActionGroup {
  const ProductWorkspaceActionGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.shortcuts,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<ProductWorkspaceShortcut> shortcuts;

  bool get isEmpty => shortcuts.isEmpty;
  bool get hasShortcuts => shortcuts.isNotEmpty;
  int get shortcutCount => shortcuts.length;
  int get enabledShortcutCount {
    return shortcuts.where((shortcut) => shortcut.isEnabled).length;
  }

  int get disabledShortcutCount => shortcutCount - enabledShortcutCount;
  bool get hasEnabledShortcuts => enabledShortcutCount > 0;
  bool get hasDisabledShortcuts => disabledShortcutCount > 0;
  bool get isFullyGated => hasShortcuts && !hasEnabledShortcuts;

  ProductWorkspaceActionGroupAvailability get availability {
    if (!hasShortcuts) return ProductWorkspaceActionGroupAvailability.gated;
    if (isFullyGated) return ProductWorkspaceActionGroupAvailability.gated;
    if (hasDisabledShortcuts) {
      return ProductWorkspaceActionGroupAvailability.partial;
    }

    return ProductWorkspaceActionGroupAvailability.ready;
  }

  String get actionCountLabel {
    return shortcutCount == 1 ? '1 action' : '$shortcutCount actions';
  }

  String get disabledCountLabel {
    return disabledShortcutCount == 1
        ? '1 gated'
        : '$disabledShortcutCount gated';
  }

  String get readinessLabel {
    return switch (availability) {
      ProductWorkspaceActionGroupAvailability.ready => 'Ready',
      ProductWorkspaceActionGroupAvailability.partial => 'Partial',
      ProductWorkspaceActionGroupAvailability.gated => 'Setup needed',
    };
  }

  String get availabilityLabel {
    if (!hasShortcuts) return 'No actions';

    return '$enabledShortcutCount/$shortcutCount ready';
  }
}

List<ProductWorkspaceActionGroup> buildProductWorkspaceActionGroups(
  InventoryProductCatalogSummary summary, {
  ProductExperienceProfile? experienceProfile,
  ProductModuleDestinationRegistry registry =
      defaultProductModuleDestinationRegistry,
  List<ProductModuleDestination>? destinations,
  bool? includeAttentionReview,
}) {
  return buildProductWorkspaceActionGroupsFromShortcuts(
    buildProductWorkspaceShortcuts(
      summary,
      experienceProfile: experienceProfile,
      registry: registry,
      destinations: destinations,
      includeAttentionReview: includeAttentionReview,
    ),
  );
}

List<ProductWorkspaceActionGroup>
buildProductWorkspaceActionGroupsFromShortcuts(
  List<ProductWorkspaceShortcut> shortcuts,
) {
  final managementShortcuts = <ProductWorkspaceShortcut>[];
  final catalogShortcuts = <ProductWorkspaceShortcut>[];
  final stockShortcuts = <ProductWorkspaceShortcut>[];
  final freshnessShortcuts = <ProductWorkspaceShortcut>[];
  final auditShortcuts = <ProductWorkspaceShortcut>[];

  for (final shortcut in shortcuts) {
    switch (shortcut.id) {
      case ProductWorkspaceShortcutId.strategy:
      case ProductWorkspaceShortcutId.assortmentPlanning:
      case ProductWorkspaceShortcutId.categoryManagement:
      case ProductWorkspaceShortcutId.pricingManagement:
      case ProductWorkspaceShortcutId.sourcingManagement:
      case ProductWorkspaceShortcutId.lifecycleManagement:
      case ProductWorkspaceShortcutId.variantManagement:
      case ProductWorkspaceShortcutId.relationshipManagement:
      case ProductWorkspaceShortcutId.availabilityManagement:
      case ProductWorkspaceShortcutId.channelReadiness:
      case ProductWorkspaceShortcutId.setupTargets:
      case ProductWorkspaceShortcutId.packContracts:
        managementShortcuts.add(shortcut);
        break;
      case ProductWorkspaceShortcutId.catalog:
      case ProductWorkspaceShortcutId.addProduct:
      case ProductWorkspaceShortcutId.attentionReview:
        catalogShortcuts.add(shortcut);
        break;
      case ProductWorkspaceShortcutId.stockMovements:
      case ProductWorkspaceShortcutId.addStockMovement:
      case ProductWorkspaceShortcutId.stockOpname:
      case ProductWorkspaceShortcutId.scanProduct:
        stockShortcuts.add(shortcut);
        break;
      case ProductWorkspaceShortcutId.freshnessReview:
      case ProductWorkspaceShortcutId.freshnessQueue:
        freshnessShortcuts.add(shortcut);
        break;
      case ProductWorkspaceShortcutId.discrepancyReport:
        auditShortcuts.add(shortcut);
        break;
    }
  }

  return [
    ProductWorkspaceActionGroup(
      id: productWorkspaceManagementActionGroupId,
      title: 'Product management',
      subtitle: 'Shape product packs, channel strategy, and setup contracts',
      shortcuts: managementShortcuts,
    ),
    ProductWorkspaceActionGroup(
      id: productWorkspaceCatalogActionGroupId,
      title: 'Catalog & review',
      subtitle: 'Maintain product data and resolve catalog health issues',
      shortcuts: catalogShortcuts,
    ),
    ProductWorkspaceActionGroup(
      id: productWorkspaceStockActionGroupId,
      title: 'Stock operations',
      subtitle: 'Move, count, and scan product stock from one launchpad',
      shortcuts: stockShortcuts,
    ),
    ProductWorkspaceActionGroup(
      id: productWorkspaceFreshnessActionGroupId,
      title: 'Freshness control',
      subtitle: 'Track expiry, batch, and freshness-sensitive workflows',
      shortcuts: freshnessShortcuts,
    ),
    ProductWorkspaceActionGroup(
      id: productWorkspaceAuditActionGroupId,
      title: 'Audit & control',
      subtitle: 'Review count variance and operational exceptions',
      shortcuts: auditShortcuts,
    ),
  ].where((group) => group.hasShortcuts).toList(growable: false);
}
