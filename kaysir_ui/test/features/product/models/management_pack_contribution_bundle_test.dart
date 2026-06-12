import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_module_brief.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_bundle.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_kind_summary.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_source_group.dart';
import 'package:kaysir/features/product/models/management_pack_module_hook_catalog_summary.dart';
import 'package:kaysir/features/product/models/management_suite_destination.dart';
import 'package:kaysir/features/product/models/product_module_contribution_activation_summary.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_pack_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_action_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_action_registry.dart';
import 'package:kaysir/features/product/models/product_workspace_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';
import 'package:kaysir/features/product/utils/default_product_module_contribution_manifests.dart';
import 'package:kaysir/features/product/utils/product_workspace_setup_readiness_evaluators.dart';

void main() {
  test('pack contribution bundle summarizes core pack contract', () {
    final bundle = _bundleFor(coreProductManagementPack);

    expect(bundle.managementPack, coreProductManagementPack);
    expect(bundle.fieldCountLabel, '4 fields');
    expect(bundle.requiredFieldCountLabel, '2 required fields');
    expect(bundle.capabilityCountLabel, '4 capabilities');
    expect(bundle.profilePackCountLabel, '1 channel pack');
    expect(bundle.workspaceActionGroupCountLabel, '9 workspace groups');
    expect(bundle.moduleContributionStatusLabel, '20/25 active hooks');
    expect(bundle.moduleRegistryDiagnosticCount, 0);
    expect(bundle.moduleRegistryDiagnosticCountLabel, '0 registry issues');
    expect(bundle.moduleRegistryHealthSummary.statusLabel, 'Registry healthy');
    expect(
      bundle.moduleRegistryHealthSummary.severityBreakdownLabel,
      'No registry issues',
    );
    expect(
      bundle.moduleRegistryHealthSummary.primaryNextActionLabel,
      'No registry action needed',
    );
    expect(bundle.hasIgnoredManifestDiagnostics, isFalse);
    expect(bundle.ignoredManifestDiagnosticCountLabel, '0 ignored manifests');
    expect(bundle.hasDuplicateHookDiagnostics, isFalse);
    expect(bundle.duplicateHookDiagnosticCountLabel, '0 duplicate hooks');
    final freshnessSummary = bundle.moduleActivationSummaries.firstWhere(
      (summary) => summary.id == 'freshness_operations',
    );
    final coffeeSummary = bundle.moduleActivationSummaries.firstWhere(
      (summary) => summary.id == 'coffee_counter_operations',
    );
    final freshnessGroup = bundle.moduleContributionSourceGroups.firstWhere(
      (group) => group.id == 'freshness_operations',
    );
    final coffeeGroup = bundle.moduleContributionSourceGroups.firstWhere(
      (group) => group.id == 'coffee_counter_operations',
    );

    expect(freshnessSummary.isActive, isFalse);
    expect(
      freshnessSummary.reasonLabel,
      'Requires freshness, expiry, or batch product capabilities',
    );
    expect(coffeeSummary.isActive, isTrue);
    expect(
      coffeeSummary.reasonLabel,
      'Coffee counter operations product-line module enabled',
    );
    expect(freshnessGroup.isModuleActive, isFalse);
    expect(
      freshnessGroup.reasonLabel,
      'Requires freshness, expiry, or batch product capabilities',
    );
    expect(coffeeGroup.isModuleActive, isTrue);
    expect(coffeeGroup.activeCountLabel, '5/5 active');
    expect(freshnessGroup.kindSections.map((section) => section.title), [
      'Workspace actions',
      'Setup readiness',
      'Recommendations',
      'Module brief actions',
      'Availability templates',
    ]);
    final catalogSummary = ProductManagementPackModuleHookCatalogSummary(
      groups: bundle.moduleContributionSourceGroups,
    );
    expect(catalogSummary.statusLabel, 'Partial module coverage');
    expect(catalogSummary.moduleCoverageLabel, '4/5 modules active');
    expect(catalogSummary.hookCoverageLabel, '20/25 hooks active');
    expect(catalogSummary.inactiveModuleCountLabel, '1 inactive module');
    expect(bundle.hasActiveModuleContributions, isTrue);
    expect(bundle.actionContributions.map((contribution) => contribution.id), [
      productWorkspaceFreshnessContributionId,
      'coffee_counter_operations_actions',
      'restaurant_menu_operations_actions',
      'retail_assortment_operations_actions',
      'kiosk_self_service_operations_actions',
    ]);
    expect(bundle.actionContributions.first.isActive, isFalse);
    expect(
      bundle.actionContributions
          .skip(1)
          .map((contribution) => contribution.isActive),
      everyElement(isTrue),
    );
    expect(bundle.setupReadinessContributions.first.isActive, isFalse);
    expect(
      bundle.setupReadinessContributions.first.kindLabel,
      'Setup readiness',
    );
    expect(bundle.recommendationContributions.first.isActive, isFalse);
    expect(bundle.moduleBriefContributions.first.isActive, isFalse);
    expect(
      bundle.moduleBriefContributions.first.kindLabel,
      'Module brief action',
    );
    expect(bundle.kindSummaries.map((summary) => summary.activeCountLabel), [
      '4/5 active',
      '4/5 active',
      '4/5 active',
      '4/5 active',
      '4/5 active',
    ]);
  });

  test('pack contribution bundle carries ignored manifest diagnostics', () {
    final registry = ProductModuleContributionRegistry.fromManifests([
      const ProductModuleContributionManifest(
        id: 'catalog_pack',
        title: 'Catalog pack',
        description: 'Primary catalog module.',
      ),
      const ProductModuleContributionManifest(
        id: 'catalog_pack',
        title: 'Duplicate catalog pack',
        description: 'Duplicate module.',
      ),
      const ProductModuleContributionManifest(
        id: '',
        title: 'Blank module',
        description: 'Missing module id.',
      ),
    ]);
    final bundle = _bundleFor(
      coreProductManagementPack,
      moduleContributionRegistry: registry,
    );

    expect(bundle.hasIgnoredManifestDiagnostics, isTrue);
    expect(bundle.hasModuleRegistryDiagnostics, isTrue);
    expect(bundle.moduleRegistryDiagnosticCount, 2);
    expect(bundle.moduleRegistryDiagnosticCountLabel, '2 registry issues');
    expect(bundle.moduleRegistryHealthSummary.statusLabel, 'Registry blocked');
    expect(bundle.moduleRegistryHealthSummary.errorCount, 2);
    expect(bundle.moduleRegistryHealthSummary.warningCount, 0);
    expect(
      bundle.moduleRegistryHealthSummary.severityBreakdownLabel,
      '2 errors',
    );
    expect(
      bundle.moduleRegistryHealthSummary.primaryNextActionLabel,
      'Rename Duplicate catalog pack or merge it with Catalog pack so every '
      'module manifest id stays unique.',
    );
    expect(bundle.ignoredManifestDiagnosticCountLabel, '2 ignored manifests');
    expect(
      bundle.ignoredManifestDiagnostics.map(
        (diagnostic) => diagnostic.reasonLabel,
      ),
      ['Duplicate module id', 'Blank module id'],
    );
    expect(
      bundle.ignoredManifestDiagnostics.first.message,
      'Duplicate catalog pack was ignored because Catalog pack already '
      'registered "catalog_pack".',
    );
  });

  test('pack contribution bundle carries duplicate hook diagnostics', () {
    final duplicateRegistry = ProductModuleContributionRegistry.fromManifests([
      const ProductModuleContributionManifest(
        id: 'freshness_a',
        title: 'Freshness A',
        description: 'First freshness module.',
        actionContributions: [freshnessProductWorkspaceActionContribution],
      ),
      const ProductModuleContributionManifest(
        id: 'freshness_b',
        title: 'Freshness B',
        description: 'Second freshness module.',
        actionContributions: [freshnessProductWorkspaceActionContribution],
      ),
    ]);
    final bundle = _bundleFor(
      groceryFreshGoodsProductManagementPack,
      moduleContributionRegistry: duplicateRegistry,
    );

    expect(bundle.hasDuplicateHookDiagnostics, isTrue);
    expect(bundle.hasModuleRegistryDiagnostics, isTrue);
    expect(bundle.moduleRegistryDiagnosticCount, 1);
    expect(bundle.moduleRegistryDiagnosticCountLabel, '1 registry issue');
    expect(bundle.moduleRegistryHealthSummary.statusLabel, 'Registry review');
    expect(bundle.moduleRegistryHealthSummary.errorCount, 0);
    expect(bundle.moduleRegistryHealthSummary.warningCount, 1);
    expect(
      bundle.moduleRegistryHealthSummary.severityBreakdownLabel,
      '1 warning',
    );
    expect(
      bundle.moduleRegistryHealthSummary.primaryNextActionLabel,
      'Give "freshness_queue" a unique workspace action id in all but one '
      'module, or consolidate the shared behavior into a single module.',
    );
    expect(bundle.duplicateHookDiagnosticCountLabel, '1 duplicate hook');
    expect(
      bundle.duplicateHookDiagnostics.single.kindLabel,
      'Workspace action',
    );
    expect(bundle.duplicateHookDiagnostics.single.hookId, 'freshness_queue');
    expect(
      bundle.duplicateHookDiagnostics.single.sourceLabel,
      'Freshness A, Freshness B',
    );
  });

  test('pack contribution bundle activates grocery freshness extensions', () {
    final bundle = _bundleFor(groceryFreshGoodsProductManagementPack);

    expect(bundle.fieldCountLabel, '9 fields');
    expect(bundle.requiredFieldCountLabel, '4 required fields');
    expect(bundle.capabilityCountLabel, '8 capabilities');
    expect(bundle.profilePackCountLabel, '1 channel pack');
    expect(bundle.workspaceActionGroupCountLabel, '5 workspace groups');
    expect(bundle.moduleContributionStatusLabel, '5/25 active hooks');
    final freshnessSummary = bundle.moduleActivationSummaries.firstWhere(
      (summary) => summary.id == 'freshness_operations',
    );
    final freshnessGroup = bundle.moduleContributionSourceGroups.firstWhere(
      (group) => group.id == 'freshness_operations',
    );

    expect(freshnessSummary.isActive, isTrue);
    expect(freshnessSummary.title, 'Freshness operations');
    expect(freshnessGroup.title, 'Freshness operations');
    expect(freshnessGroup.activeCountLabel, '5/5 active');
    expect(freshnessGroup.isModuleActive, isTrue);
    expect(
      freshnessGroup.reasonLabel,
      'Freshness, expiry, or batch capability matched',
    );
    expect(
      freshnessGroup.kindSections.map((section) => section.activeCountLabel),
      ['1/1 active', '1/1 active', '1/1 active', '1/1 active', '1/1 active'],
    );
    final catalogSummary = ProductManagementPackModuleHookCatalogSummary(
      groups: bundle.moduleContributionSourceGroups,
    );
    expect(catalogSummary.statusLabel, 'Partial module coverage');
    expect(catalogSummary.moduleCoverageLabel, '1/5 modules active');
    expect(catalogSummary.hookCoverageLabel, '5/25 hooks active');
    expect(catalogSummary.inactiveModuleCountLabel, '4 inactive modules');
    expect(bundle.hasActiveModuleContributions, isTrue);
    expect(
      bundle.managementPack.fieldIds,
      containsAll([
        ProductManagementFieldId.expiryDate,
        ProductManagementFieldId.batchNumber,
        ProductManagementFieldId.freshnessStatus,
      ]),
    );

    final actionContribution = bundle.actionContributions.firstWhere(
      (contribution) =>
          contribution.id == productWorkspaceFreshnessContributionId,
    );
    expect(actionContribution.isActive, isTrue);
    expect(actionContribution.title, 'Freshness control');
    expect(actionContribution.outputCount, 1);
    expect(actionContribution.kindLabel, 'Workspace action');
    expect(actionContribution.sourceId, 'freshness_operations');
    expect(actionContribution.sourceLabel, 'Freshness operations');

    final recommendationContribution = bundle.recommendationContributions
        .firstWhere(
          (contribution) =>
              contribution.id ==
              productWorkspaceFreshnessRecommendationContributionId,
        );
    expect(recommendationContribution.isActive, isTrue);
    expect(recommendationContribution.title, 'Prepare freshness data');
    expect(recommendationContribution.outputCount, 1);
    expect(recommendationContribution.kindLabel, 'Recommendation');
    expect(recommendationContribution.sourceLabel, 'Freshness operations');

    final moduleBriefContribution = bundle.moduleBriefContributions.firstWhere(
      (contribution) =>
          contribution.id == 'freshness_availability_brief_action',
    );
    expect(moduleBriefContribution.isActive, isTrue);
    expect(moduleBriefContribution.id, 'freshness_availability_brief_action');
    expect(moduleBriefContribution.title, 'Freshness selling gates');
    expect(
      moduleBriefContribution.detailLabel,
      'Routes availability next actions to freshness queue review.',
    );
    expect(moduleBriefContribution.outputCount, 1);
    expect(moduleBriefContribution.kindLabel, 'Module brief action');
    expect(moduleBriefContribution.sourceLabel, 'Freshness operations');

    final setupReadinessContribution = bundle.setupReadinessContributions
        .firstWhere(
          (contribution) =>
              contribution.id ==
              productWorkspaceFreshnessReadinessContributionId,
        );
    expect(setupReadinessContribution.isActive, isTrue);
    expect(setupReadinessContribution.title, 'Freshness Readiness');
    expect(setupReadinessContribution.outputCount, 1);
    expect(setupReadinessContribution.kindLabel, 'Setup readiness');
    expect(setupReadinessContribution.sourceLabel, 'Freshness operations');

    final availabilityTemplateContribution = bundle
        .availabilityTemplateContributions
        .firstWhere(
          (contribution) =>
              contribution.id == 'freshness_availability_templates',
        );
    expect(availabilityTemplateContribution.isActive, isTrue);
    expect(
      availabilityTemplateContribution.title,
      'Freshness availability templates',
    );
    expect(availabilityTemplateContribution.outputCount, 2);
    expect(availabilityTemplateContribution.kindLabel, 'Availability template');
    expect(
      availabilityTemplateContribution.sourceLabel,
      'Freshness operations',
    );
    expect(bundle.kindSummaries.map((summary) => summary.outputCountLabel), [
      '1 output',
      '1 output',
      '1 output',
      '1 output',
      '2 outputs',
    ]);
  });

  test('pack contribution bundle normalizes extension hook ids', () {
    const coffeeSetupTarget = ProductWorkspaceSetupTarget(
      id: ' coffee_setup ',
      title: 'Coffee menu setup',
      subtitle: 'Prepare drinks, modifiers, and barista stations.',
      actionLabel: 'Review coffee setup',
    );
    final actionContribution = ProductWorkspaceActionContribution(
      id: ' coffee_action ',
      isActive: (pack) => true,
      setupTargets: const [coffeeSetupTarget],
      buildGroups:
          (pack, summary) => const [
            ProductWorkspaceActionGroup(
              id: 'coffee_bar',
              title: 'Coffee bar',
              subtitle: 'Barista product setup',
              shortcuts: [
                ProductWorkspaceShortcut(
                  id: ProductWorkspaceShortcutId.catalog,
                  title: 'Menu catalog',
                  subtitle: 'Review drinks and modifiers',
                  status: 'Ready',
                ),
              ],
            ),
          ],
    );
    final setupReadinessContribution =
        ProductWorkspaceSetupReadinessContribution(
          id: ' coffee_readiness ',
          targetIds: const [' coffee_setup '],
          buildRegistry:
              (context) =>
                  const ProductWorkspaceSetupReadinessEvaluatorRegistry(),
        );
    final recommendationContribution =
        ProductWorkspaceRecommendationContribution(
          id: ' coffee_recommendation ',
          buildRecommendations:
              (context) => const [
                ProductWorkspaceRecommendation(
                  id: 'coffee_menu_review',
                  title: 'Review coffee menu',
                  subtitle: 'Check coffee menu launch data.',
                  actionLabel: 'Open menu',
                  statusLabel: 'Menu',
                  priority: ProductWorkspaceRecommendationPriority.high,
                ),
              ],
        );
    final moduleBriefResolver = ProductManagementModuleBriefResolver(
      id: ' coffee_brief ',
      title: 'Coffee launch brief',
      description: 'Routes coffee setup next actions.',
      destination: ProductManagementSuiteDestination.strategy,
      buildAction:
          (overview) => const ProductManagementModuleBriefAction(
            id: 'coffee_next_step',
            label: 'Review coffee launch',
            detail: 'Coffee menu needs launch review.',
            destination: ProductManagementSuiteDestination.catalog,
          ),
    );
    const availabilityTemplateContribution =
        ProductAvailabilityRuleTemplateContribution(
          id: ' coffee_availability ',
          title: 'Coffee availability',
          templates: [
            ProductAvailabilityRuleTemplate(
              id: ProductAvailabilityRuleTemplateId.counterService,
              title: 'Coffee counter',
              subtitle: 'Counter-service coffee availability.',
              attributes: {'available_channels': 'Counter'},
            ),
          ],
        );
    final registry = ProductModuleContributionRegistry.fromManifests([
      ProductModuleContributionManifest(
        id: 'coffee_operations',
        title: 'Coffee operations',
        description: 'Coffee product-line extension hooks.',
        actionContributions: [actionContribution],
        setupReadinessContributions: [setupReadinessContribution],
        recommendationContributions: [recommendationContribution],
        moduleBriefResolvers: [moduleBriefResolver],
        availabilityRuleTemplateContributions: const [
          availabilityTemplateContribution,
        ],
      ),
    ]);
    final bundle = _bundleFor(
      coreProductManagementPack,
      actionContributions: [actionContribution],
      setupReadinessContributionBundle:
          ProductWorkspaceSetupReadinessContributionBundle(
            contributions: [setupReadinessContribution],
          ),
      recommendationContributions: [recommendationContribution],
      moduleContributionRegistry: registry,
    );

    expect(bundle.actionContributions.single.id, 'coffee_action');
    expect(bundle.actionContributions.single.sourceLabel, 'Coffee operations');
    expect(bundle.setupReadinessContributions.single.id, 'coffee_readiness');
    expect(bundle.setupReadinessContributions.single.isActive, isTrue);
    expect(bundle.setupReadinessContributions.single.outputLabels, [
      'Coffee Setup',
    ]);
    expect(
      bundle.recommendationContributions.single.id,
      'coffee_recommendation',
    );
    expect(bundle.moduleBriefContributions.single.id, 'coffee_brief');
    expect(
      bundle.availabilityTemplateContributions.single.id,
      'coffee_availability',
    );
    expect(
      bundle.moduleContributions.map(
        (contribution) => contribution.sourceLabel,
      ),
      everyElement('Coffee operations'),
    );
  });

  test('contribution source groups preserve titled fallback modules', () {
    final groups = groupProductManagementPackContributionsBySource([
      ProductManagementPackContributionSummary(
        id: 'kitchen_menu',
        kind: ProductManagementPackContributionKind.workspaceAction,
        title: 'Kitchen menu board',
        detailLabel: '1 action',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 1,
        sourceTitle: 'Kitchen operations',
      ),
      ProductManagementPackContributionSummary(
        id: 'loyalty_prompt',
        kind: ProductManagementPackContributionKind.recommendation,
        title: 'Loyalty prompt',
        detailLabel: 'No source registered',
        statusLabel: 'Inactive',
        isActive: false,
        outputCount: 0,
      ),
    ]);

    expect(groups.map((group) => group.title), [
      'Kitchen operations',
      'Unassigned module',
    ]);
    expect(groups.first.kindSections.single.title, 'Workspace actions');
    expect(groups.last.kindSections.single.title, 'Recommendations');
    expect(groups.first.activeCountLabel, '1/1 active');
    expect(groups.first.statusLabel, 'Active');
    expect(groups.first.reasonLabel, 'Module hooks available for this pack');
    expect(groups.last.activeCountLabel, '0/1 active');
    expect(groups.last.statusLabel, 'Inactive');
    expect(
      groups.last.reasonLabel,
      'Module hooks are registered but inactive for this pack',
    );

    final summary = ProductManagementPackModuleHookCatalogSummary(
      groups: groups,
    );
    expect(summary.statusLabel, 'Partial module coverage');
    expect(summary.moduleCoverageLabel, '1/2 modules active');
    expect(summary.hookCoverageLabel, '1/2 hooks active');
    expect(summary.inactiveModuleCountLabel, '1 inactive module');
  });

  test(
    'contribution source groups follow activation order with empty modules',
    () {
      final groups = groupProductManagementPackContributionsBySource(
        [
          ProductManagementPackContributionSummary(
            id: 'kitchen_menu',
            kind: ProductManagementPackContributionKind.workspaceAction,
            title: 'Kitchen menu board',
            detailLabel: '1 action',
            statusLabel: 'Active',
            isActive: true,
            outputCount: 1,
            sourceId: 'kitchen_operations',
            sourceTitle: 'Kitchen operations',
          ),
        ],
        activationSummaries: const [
          ProductModuleContributionActivationSummary(
            id: 'checkout_guardrails',
            title: 'Checkout guardrails',
            description: 'Validates checkout module readiness.',
            isActive: true,
            reasonLabel: 'Enabled for this product pack',
            actionContributionCount: 0,
            setupReadinessContributionCount: 0,
            recommendationContributionCount: 0,
          ),
          ProductModuleContributionActivationSummary(
            id: 'kitchen_operations',
            title: 'Kitchen operations',
            description: 'Kitchen workflow hooks.',
            isActive: true,
            reasonLabel: 'Kitchen capability matched',
            actionContributionCount: 1,
            setupReadinessContributionCount: 0,
            recommendationContributionCount: 0,
          ),
        ],
      );

      expect(groups.map((group) => group.title), [
        'Checkout guardrails',
        'Kitchen operations',
      ]);
      expect(groups.first.contributionCount, 0);
      expect(groups.first.activeCountLabel, 'No hooks');
      expect(groups.first.contributionCountLabel, '0 hooks');
      expect(groups.first.isModuleActive, isTrue);
      expect(groups.first.reasonLabel, 'Enabled for this product pack');
      expect(groups.last.kindSections.single.title, 'Workspace actions');
    },
  );

  test('module hook catalog summary handles empty catalogs', () {
    final summary = ProductManagementPackModuleHookCatalogSummary(
      groups: const [],
    );

    expect(summary.statusLabel, 'No modules registered');
    expect(summary.moduleCoverageLabel, 'No modules');
    expect(summary.hookCoverageLabel, 'No hooks');
    expect(summary.inactiveModuleCountLabel, '0 inactive modules');
  });
}

ProductManagementPackContributionBundle _bundleFor(
  ProductManagementPack pack, {
  List<ProductWorkspaceActionContribution>? actionContributions,
  ProductWorkspaceSetupReadinessContributionBundle?
  setupReadinessContributionBundle,
  List<ProductWorkspaceRecommendationContribution>? recommendationContributions,
  ProductModuleContributionRegistry? moduleContributionRegistry,
}) {
  final resolvedModuleContributionRegistry =
      moduleContributionRegistry ??
      ProductModuleContributionRegistry.fromManifests(
        defaultProductModuleContributionManifests,
      );
  final resolvedActionContributions =
      actionContributions ??
      resolvedModuleContributionRegistry.actionContributions;
  final resolvedSetupReadinessContributionBundle =
      setupReadinessContributionBundle ??
      ProductWorkspaceSetupReadinessContributionBundle(
        contributions: [
          ...resolvedModuleContributionRegistry.setupReadinessContributions,
          for (final contribution in resolvedActionContributions)
            ...contribution.setupReadinessContributionsFor(pack),
        ],
      );
  final resolvedRecommendationContributions =
      recommendationContributions ??
      resolvedModuleContributionRegistry.recommendationContributions;
  final registry = ProductSalesChannelProfileRegistry.fromPacks(
    pack.profilePacks,
  );
  final selectedProfile = registry.fallbackProfile;
  final overview = buildProductWorkspaceOverview(
    products: _products,
    stockRecords: _stockRecords,
    actionRegistry: ProductWorkspaceActionRegistry(
      pack: pack,
      contributions: resolvedActionContributions,
    ),
    managementPack: pack,
    channelProfiles: registry.profiles,
    channelProfile: selectedProfile,
    channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
      packs: pack.profilePacks,
      registry: registry,
      selectedProfile: selectedProfile,
    ),
    recommendationContributions: resolvedRecommendationContributions,
  );

  return buildProductManagementPackContributionBundle(
    managementPack: pack,
    summary: overview.summary,
    qualitySummary: overview.qualitySummary,
    actionSummary: overview.actionSummary,
    strategyBrief: overview.strategyBrief,
    workspaceActionGroups: overview.actionGroups,
    primaryLaunchPriority: overview.primaryLaunchPriority,
    actionContributions: resolvedActionContributions,
    setupReadinessContributionBundle: resolvedSetupReadinessContributionBundle,
    recommendationContributions: resolvedRecommendationContributions,
    moduleContributionRegistry: resolvedModuleContributionRegistry,
  );
}

final _products = [
  Product(
    id: 'p1',
    name: 'Yogurt',
    sku: 'YG-001',
    category: 'Dairy',
    description: 'Plain yogurt',
    price: 18,
    barcode: '8990001',
  ),
  Product(
    id: 'p2',
    name: 'Spinach',
    sku: 'SP-001',
    category: 'Vegetables',
    price: 7,
    barcode: '8990002',
  ),
];

final _warehouse = Warehouse(
  id: 'w1',
  name: 'Main Warehouse',
  location: 'Jakarta',
);

final _stockRecords = [
  InventoryStockRecord(
    item: InventoryItem(
      id: 'i1',
      productId: 'p1',
      warehouseId: 'w1',
      currentQuantity: 12,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    product: _products[0],
    warehouse: _warehouse,
  ),
  InventoryStockRecord(
    item: InventoryItem(
      id: 'i2',
      productId: 'p2',
      warehouseId: 'w1',
      currentQuantity: 3,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    product: _products[1],
    warehouse: _warehouse,
  ),
];
