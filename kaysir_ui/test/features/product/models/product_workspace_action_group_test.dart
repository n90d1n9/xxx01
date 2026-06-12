import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';

void main() {
  test('workspace action groups organize default product actions', () {
    final groups = buildProductWorkspaceActionGroups(_summary);

    expect(groups.map((group) => group.id), [
      productWorkspaceManagementActionGroupId,
      productWorkspaceCatalogActionGroupId,
      productWorkspaceStockActionGroupId,
      productWorkspaceFreshnessActionGroupId,
      productWorkspaceAuditActionGroupId,
    ]);
    expect(groups.first.shortcuts.map((shortcut) => shortcut.id), [
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
    ]);
    expect(groups[1].shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.catalog,
      ProductWorkspaceShortcutId.addProduct,
      ProductWorkspaceShortcutId.attentionReview,
    ]);
    expect(groups[2].shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.stockMovements,
      ProductWorkspaceShortcutId.addStockMovement,
      ProductWorkspaceShortcutId.stockOpname,
      ProductWorkspaceShortcutId.scanProduct,
    ]);
    expect(groups[3].shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.freshnessReview,
    ]);
    expect(
      groups.last.shortcuts.single.id,
      ProductWorkspaceShortcutId.discrepancyReport,
    );
  });

  test('workspace action groups omit empty sections', () {
    final groups = buildProductWorkspaceActionGroups(
      _summary,
      destinations: [productCatalogDestination],
      includeAttentionReview: false,
    );

    expect(groups, hasLength(1));
    expect(groups.single.id, productWorkspaceCatalogActionGroupId);
    expect(
      groups.single.shortcuts.single.id,
      ProductWorkspaceShortcutId.catalog,
    );
  });

  test('workspace action groups can build from a destination registry', () {
    const registry = ProductModuleDestinationRegistry([
      productCatalogDestination,
      productFreshnessReviewDestination,
    ]);

    final groups = buildProductWorkspaceActionGroups(
      _summary,
      registry: registry,
      includeAttentionReview: false,
    );

    expect(groups.map((group) => group.id), [
      productWorkspaceCatalogActionGroupId,
      productWorkspaceFreshnessActionGroupId,
    ]);
    expect(
      groups.first.shortcuts.single.id,
      ProductWorkspaceShortcutId.catalog,
    );
    expect(
      groups.last.shortcuts.single.id,
      ProductWorkspaceShortcutId.freshnessReview,
    );
  });

  test('workspace action groups can build from an experience profile', () {
    final groups = buildProductWorkspaceActionGroups(
      _summary,
      experienceProfile: productFreshGoodsExperienceProfile,
      includeAttentionReview: false,
    );

    expect(groups.map((group) => group.id), [
      productWorkspaceManagementActionGroupId,
      productWorkspaceCatalogActionGroupId,
      productWorkspaceStockActionGroupId,
      productWorkspaceFreshnessActionGroupId,
      productWorkspaceAuditActionGroupId,
    ]);
    expect(groups.first.shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.availabilityManagement,
      ProductWorkspaceShortcutId.channelReadiness,
      ProductWorkspaceShortcutId.setupTargets,
      ProductWorkspaceShortcutId.packContracts,
    ]);
    expect(groups[1].shortcuts.single.id, ProductWorkspaceShortcutId.catalog);
    expect(groups[2].shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.stockOpname,
      ProductWorkspaceShortcutId.scanProduct,
    ]);
    expect(
      groups[3].shortcuts.single.id,
      ProductWorkspaceShortcutId.freshnessReview,
    );
    expect(
      groups.last.shortcuts.single.id,
      ProductWorkspaceShortcutId.discrepancyReport,
    );
  });

  test('workspace action groups can bucket freshness shortcuts', () {
    final groups = buildProductWorkspaceActionGroupsFromShortcuts([
      ProductWorkspaceShortcut.fromDestination(
        productCatalogDestination,
        _summary,
      ),
      const ProductWorkspaceShortcut(
        id: ProductWorkspaceShortcutId.freshnessQueue,
        title: 'Freshness Queue',
        subtitle: 'Expiry and batch work',
        status: 'Setup',
      ),
    ]);

    expect(groups.map((group) => group.id), [
      productWorkspaceCatalogActionGroupId,
      productWorkspaceFreshnessActionGroupId,
    ]);
    expect(groups.last.title, 'Freshness control');
    expect(
      groups.last.shortcuts.single.id,
      ProductWorkspaceShortcutId.freshnessQueue,
    );
  });

  test('workspace action groups summarize action availability', () {
    const group = ProductWorkspaceActionGroup(
      id: 'custom',
      title: 'Custom',
      subtitle: 'Custom workflow actions',
      shortcuts: [
        ProductWorkspaceShortcut(
          id: ProductWorkspaceShortcutId.catalog,
          title: 'Catalog',
          subtitle: 'Open catalog',
          status: 'Ready',
        ),
        ProductWorkspaceShortcut(
          id: ProductWorkspaceShortcutId.freshnessQueue,
          title: 'Freshness Queue',
          subtitle: 'Expiry work',
          status: 'Setup',
          isEnabled: false,
          disabledReason: 'Connect route first',
        ),
      ],
    );

    expect(group.shortcutCount, 2);
    expect(group.enabledShortcutCount, 1);
    expect(group.disabledShortcutCount, 1);
    expect(group.hasDisabledShortcuts, isTrue);
    expect(group.isFullyGated, isFalse);
    expect(group.availability, ProductWorkspaceActionGroupAvailability.partial);
    expect(group.actionCountLabel, '2 actions');
    expect(group.disabledCountLabel, '1 gated');
    expect(group.readinessLabel, 'Partial');
    expect(group.availabilityLabel, '1/2 ready');
  });

  test('workspace action groups identify fully gated sections', () {
    const group = ProductWorkspaceActionGroup(
      id: 'freshness',
      title: 'Freshness',
      subtitle: 'Freshness setup',
      shortcuts: [
        ProductWorkspaceShortcut(
          id: ProductWorkspaceShortcutId.freshnessQueue,
          title: 'Freshness Queue',
          subtitle: 'Expiry work',
          status: 'Setup',
          isEnabled: false,
        ),
      ],
    );

    expect(group.enabledShortcutCount, 0);
    expect(group.isFullyGated, isTrue);
    expect(group.availability, ProductWorkspaceActionGroupAvailability.gated);
    expect(group.readinessLabel, 'Setup needed');
    expect(group.availabilityLabel, '0/1 ready');
  });

  test('workspace action groups keep empty availability explicit', () {
    const group = ProductWorkspaceActionGroup(
      id: 'empty',
      title: 'Empty',
      subtitle: 'No actions',
      shortcuts: [],
    );

    expect(group.hasShortcuts, isFalse);
    expect(group.availability, ProductWorkspaceActionGroupAvailability.gated);
    expect(group.readinessLabel, 'Setup needed');
    expect(group.availabilityLabel, 'No actions');
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
