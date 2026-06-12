import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/experience_profile.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_module_destination.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/product_workspace_action_registry.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';

void main() {
  test('workspace action registry can scope actions by experience profile', () {
    final registry = ProductWorkspaceActionRegistry(
      pack: coreProductManagementPack,
      contributions: const [],
      experienceProfile: productStockControlExperienceProfile,
      includeAttentionReview: false,
    );
    final groups = registry.groupsFor(_summary);

    expect(registry.destinations.map((destination) => destination.id), [
      ProductModuleDestinationId.catalog,
      ProductModuleDestinationId.stockMovements,
      ProductModuleDestinationId.addStockMovement,
      ProductModuleDestinationId.stockOpname,
      ProductModuleDestinationId.scanProduct,
      ProductModuleDestinationId.discrepancyReport,
    ]);
    expect(groups.map((group) => group.id), [
      productWorkspaceCatalogActionGroupId,
      productWorkspaceStockActionGroupId,
      productWorkspaceAuditActionGroupId,
    ]);
    expect(
      groups.first.shortcuts.single.id,
      ProductWorkspaceShortcutId.catalog,
    );
    expect(groups[1].shortcuts.map((shortcut) => shortcut.id), [
      ProductWorkspaceShortcutId.stockMovements,
      ProductWorkspaceShortcutId.addStockMovement,
      ProductWorkspaceShortcutId.stockOpname,
      ProductWorkspaceShortcutId.scanProduct,
    ]);
    expect(
      groups.last.shortcuts.single.id,
      ProductWorkspaceShortcutId.discrepancyReport,
    );
  });

  test(
    'explicit destinations still override experience profile destinations',
    () {
      final registry = ProductWorkspaceActionRegistry(
        pack: coreProductManagementPack,
        contributions: const [],
        experienceProfile: productStockControlExperienceProfile,
        destinations: const [productCatalogDestination],
        includeAttentionReview: false,
      );

      expect(registry.destinations, [productCatalogDestination]);
      expect(
        registry.groupsFor(_summary).single.shortcuts.single.id,
        [ProductWorkspaceShortcutId.catalog].single,
      );
    },
  );
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
