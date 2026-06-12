import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/utils/default_product_line_module_manifests.dart';

void main() {
  test(
    'product line module definition generates scoped contribution hooks',
    () {
      const definition = coffeeCounterProductLineModuleDefinition;
      final manifest = definition.toManifest();
      final actionContribution = manifest.actionContributions.single;
      final setupReadinessContribution =
          manifest.setupReadinessContributions.single;
      final recommendationContribution =
          manifest.recommendationContributions.single;
      final briefResolver = manifest.moduleBriefResolvers.single;
      final availabilityContribution =
          manifest.availabilityRuleTemplateContributions.single;
      final actionGroups = actionContribution.groupsFor(
        coreProductManagementPack,
        _summary,
      );

      expect(definition.normalizedId, 'coffee_counter_operations');
      expect(manifest.id, 'coffee_counter_operations');
      expect(manifest.hasContributions, isTrue);
      expect(manifest.isActiveFor(coreProductManagementPack), isTrue);
      expect(
        manifest.isActiveFor(groceryFreshGoodsProductManagementPack),
        isFalse,
      );
      expect(actionContribution.id, 'coffee_counter_operations_actions');
      expect(actionContribution.setupTargetsFor(coreProductManagementPack), [
        definition.setupTarget,
      ]);
      expect(actionGroups.single.title, 'Coffee counter');
      expect(
        actionGroups.single.shortcuts.single.id,
        ProductWorkspaceShortcutId.variantManagement,
      );
      expect(
        actionGroups.single.shortcuts.single.routePath,
        ProductRoutes.variantManagementPath,
      );
      expect(
        setupReadinessContribution.id,
        'coffee_counter_operations_readiness',
      );
      expect(setupReadinessContribution.normalizedTargetIds, ['coffee_menu']);
      expect(
        recommendationContribution.normalizedId,
        'coffee_counter_operations_recommendations',
      );
      expect(
        briefResolver.contributionId,
        'coffee_counter_operations_brief_action',
      );
      expect(
        availabilityContribution.normalizedId,
        'coffee_counter_operations_availability_templates',
      );
      expect(
        availabilityContribution.templates.map((template) => template.id.value),
        [
          'coffee_counter_operations_counter_service',
          'coffee_counter_operations_pickup_window',
        ],
      );
    },
  );

  test('default product line manifests register without hook conflicts', () {
    final registry = ProductModuleContributionRegistry.fromManifests(
      defaultProductLineModuleContributionManifests,
    );

    expect(defaultProductLineModuleDefinitions, hasLength(4));
    expect(registry.manifestIds, [
      'coffee_counter_operations',
      'restaurant_menu_operations',
      'retail_assortment_operations',
      'kiosk_self_service_operations',
    ]);
    expect(registry.hasDuplicateHookDiagnostics, isFalse);
    expect(registry.ignoredManifestDiagnostics, isEmpty);
    expect(
      registry
          .activeManifestsFor(coreProductManagementPack)
          .map((manifest) => manifest.id),
      registry.manifestIds,
    );
    expect(
      registry.activeManifestsFor(groceryFreshGoodsProductManagementPack),
      isEmpty,
    );
    expect(
      registry
          .sourceForActionContribution('restaurant_menu_operations_actions')
          ?.title,
      'Restaurant menu operations',
    );
    expect(
      registry
          .sourceForAvailabilityRuleTemplateContribution(
            'kiosk_self_service_operations_availability_templates',
          )
          ?.title,
      'Kiosk self-service operations',
    );
  });

  test('product line readiness rules evaluate setup target requirements', () {
    const definition = coffeeCounterProductLineModuleDefinition;
    final contribution = definition.toSetupReadinessContribution();
    final registry = contribution.registryFor(
      ProductWorkspaceSetupReadinessContributionContext(
        records: _coffeeRecords,
      ),
    );
    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      ProductWorkspaceSetupPrompt(
        target: definition.setupTarget,
        action: ProductWorkspaceSetupAction(
          targetId: definition.setupTarget.normalizedId,
          label: definition.setupTarget.actionLabel,
          routePath: ProductRoutes.workspacePath,
          source: ProductWorkspaceSetupActionSource.fallback,
        ),
      ),
    ], registry: registry);

    expect(readiness.totalCount, 3);
    expect(readiness.readyCount, 2);
    expect(readiness.missingCount, 1);
    expect(readiness.statusLabel, 'Needs setup');
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'coffee_menu',
            requirementId: 'drink_menu_data',
          )
          ?.reason,
      'Drink products have category coverage.',
    );
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'coffee_menu',
            requirementId: 'modifier_options',
          )
          ?.reason,
      'Modifier option data is available.',
    );
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'coffee_menu',
            requirementId: 'barista_station_handoff',
          )
          ?.reason,
      'Add barista station or handoff workflow metadata.',
    );
  });
}

const _summary = InventoryProductCatalogSummary(
  productCount: 12,
  trackedProductCount: 10,
  inStockProductCount: 8,
  untrackedProductCount: 2,
  attentionProductCount: 3,
  totalQuantity: 120,
  totalInventoryValue: 2400,
  categoryCount: 5,
);

final _coffeeRecords = [
  InventoryProductCatalogRecord(
    product: Product(
      id: 'latte',
      name: 'Latte',
      category: 'Coffee',
      price: 28000,
      customAttributes: const {'modifier_options': 'Milk, size, syrup'},
    ),
    stockRecords: const [],
  ),
];
