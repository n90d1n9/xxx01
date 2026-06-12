import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart'
    as inventory_products;
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_action_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/product_workspace_action_provider.dart';
import 'package:kaysir/features/product/states/product_workspace_setup_readiness_provider.dart';
import 'package:kaysir/features/product/states/product_workspace_setup_target_provider.dart';

void main() {
  test('workspace action registry provider exposes core action groups', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    final groups = container
        .read(productWorkspaceActionRegistryProvider)
        .groupsFor(_summary);

    expect(groups.map((group) => group.id), [
      productWorkspaceManagementActionGroupId,
      productWorkspaceCatalogActionGroupId,
      productWorkspaceStockActionGroupId,
      productWorkspaceAuditActionGroupId,
      'coffee_counter_operations_workflow',
      'restaurant_menu_operations_workflow',
      'retail_assortment_operations_workflow',
      'kiosk_self_service_operations_workflow',
    ]);
    expect(
      groups.any((group) => group.id == productWorkspaceFreshnessActionGroupId),
      isFalse,
    );
  });

  test(
    'workspace action registry follows active product management pack',
    () async {
      final container = ProviderContainer(
        overrides: [
          productManagementPacksProvider.overrideWithValue([
            coreProductManagementPack,
            groceryFreshGoodsProductManagementPack,
          ]),
          _memoryPreferencesRepositoryOverride(),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(productManagementPackIdProvider.notifier)
          .selectPack(ProductManagementPackId.groceryFreshGoods);

      final groups = container
          .read(productWorkspaceActionRegistryProvider)
          .groupsFor(_summary);
      final freshnessGroup = groups.singleWhere(
        (group) => group.id == productWorkspaceFreshnessActionGroupId,
      );
      final freshnessQueueShortcut = freshnessGroup.shortcuts.singleWhere(
        (shortcut) => shortcut.id == ProductWorkspaceShortcutId.freshnessQueue,
      );

      expect(
        container.read(productManagementPackProvider),
        groceryFreshGoodsProductManagementPack,
      );
      expect(freshnessGroup.title, 'Freshness control');
      expect(freshnessGroup.shortcuts.map((shortcut) => shortcut.id), [
        ProductWorkspaceShortcutId.freshnessReview,
        ProductWorkspaceShortcutId.freshnessQueue,
      ]);
      expect(freshnessQueueShortcut.isDisabled, isTrue);
      expect(
        freshnessQueueShortcut.disabledReason,
        'Connect a freshness workflow route to enable',
      );
      expect(
        freshnessQueueShortcut.setupRoutePath,
        ProductRoutes.workspaceSetupUri(ProductWorkspaceSetupTarget.freshness),
      );
      expect(groups.map((group) => group.id), [
        productWorkspaceManagementActionGroupId,
        productWorkspaceCatalogActionGroupId,
        productWorkspaceStockActionGroupId,
        productWorkspaceFreshnessActionGroupId,
        productWorkspaceAuditActionGroupId,
      ]);
    },
  );

  test('workspace action registry respects pinned product pack fallback', () {
    final container = ProviderContainer(
      overrides: [
        productManagementPacksProvider.overrideWithValue([
          coreProductManagementPack,
          groceryFreshGoodsProductManagementPack,
        ]),
        productManagementFallbackPackIdProvider.overrideWithValue(
          ProductManagementPackId.coreCatalog,
        ),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    final groups = container
        .read(productWorkspaceActionRegistryProvider)
        .groupsFor(_summary);

    expect(
      container.read(productManagementPackProvider),
      coreProductManagementPack,
    );
    expect(
      groups.any((group) => group.id == productWorkspaceFreshnessActionGroupId),
      isFalse,
    );
  });

  test('workspace action registry accepts custom group contributors', () {
    final customContribution = ProductWorkspaceActionContribution(
      id: 'batch_control',
      isActive: (pack) => true,
      buildGroups:
          (pack, summary) => [
            const ProductWorkspaceActionGroup(
              id: 'batch_control',
              title: 'Batch control',
              subtitle: 'Product pack contributed traceability actions',
              shortcuts: [
                ProductWorkspaceShortcut(
                  id: ProductWorkspaceShortcutId.freshnessQueue,
                  title: 'Batch Review',
                  subtitle: 'Review batch labels before selling',
                  status: 'Custom',
                  isEnabled: false,
                  disabledReason: 'Custom workflow is not connected yet',
                ),
              ],
            ),
          ],
    );
    final container = ProviderContainer(
      overrides: [
        productWorkspaceActionContributionsProvider.overrideWithValue([
          customContribution,
        ]),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    final groups = container
        .read(productWorkspaceActionRegistryProvider)
        .groupsFor(_summary);
    final batchGroup = groups.singleWhere(
      (group) => group.id == 'batch_control',
    );

    expect(groups.map((group) => group.id), [
      productWorkspaceManagementActionGroupId,
      productWorkspaceCatalogActionGroupId,
      productWorkspaceStockActionGroupId,
      productWorkspaceAuditActionGroupId,
      'batch_control',
    ]);
    expect(batchGroup.title, 'Batch control');
    expect(batchGroup.shortcuts.single.title, 'Batch Review');
    expect(
      groups.any((group) => group.id == productWorkspaceFreshnessActionGroupId),
      isFalse,
    );
  });

  test('workspace setup target registry accepts contribution targets', () {
    const restaurantTarget = ProductWorkspaceSetupTarget(
      id: 'restaurant_menu',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata before checkout launch.',
      actionLabel: 'Review menu setup',
      recommendationId: 'restaurant_menu_setup',
    );
    final customContribution = ProductWorkspaceActionContribution(
      id: 'restaurant_menu',
      isActive: (pack) => true,
      setupTargets: const [restaurantTarget],
      buildGroups: (pack, summary) => const [],
    );
    final container = ProviderContainer(
      overrides: [
        productWorkspaceActionContributionsProvider.overrideWithValue([
          customContribution,
        ]),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    final targets = container.read(productWorkspaceSetupTargetsProvider);
    final activeTargets = container.read(
      productWorkspaceActiveSetupTargetsProvider,
    );
    final activations = container.read(
      productWorkspaceSetupActivationsProvider,
    );
    final registry = container.read(
      productWorkspaceSetupTargetRegistryProvider,
    );
    final overview = container.read(productWorkspaceSetupOverviewProvider);
    final customTarget = registry.resolve('restaurant_menu');
    final freshnessResolution = registry.resolveWithAvailability('freshness');
    final customResolution = registry.resolveWithAvailability(
      'restaurant_menu',
    );
    final unknownTarget = registry.resolve('retail_bundle');

    expect(targets, contains(ProductWorkspaceSetupTarget.freshness));
    expect(targets, contains(restaurantTarget));
    expect(activeTargets, contains(restaurantTarget));
    expect(
      activations.any(
        (activation) =>
            activation.targetId == 'restaurant_menu' &&
            activation.packTitle == coreProductManagementPack.title &&
            activation.packFocusLabel ==
                coreProductManagementPack.operatorFocusLabel,
      ),
      isTrue,
    );
    expect(customTarget, restaurantTarget);
    expect(customTarget?.recommendationId, 'restaurant_menu_setup');
    expect(freshnessResolution?.isInactive, isTrue);
    expect(customResolution?.isActive, isTrue);
    expect(unknownTarget?.isCustom, isTrue);
    expect(unknownTarget?.title, 'Retail Bundle setup');
    expect(overview.activeCount, 1);
    expect(overview.inactiveCount, 1);
    expect(overview.prompts.map((prompt) => prompt.targetId), [
      'freshness',
      'restaurant_menu',
    ]);
  });

  test('workspace setup providers normalize contributed target ids', () {
    const restaurantTarget = ProductWorkspaceSetupTarget(
      id: ' restaurant_menu ',
      title: 'Restaurant menu setup',
      subtitle: 'Prepare dine-in menu metadata before checkout launch.',
      actionLabel: 'Review menu setup',
    );
    const duplicateRestaurantTarget = ProductWorkspaceSetupTarget(
      id: 'restaurant_menu',
      title: 'Restaurant menu setup duplicate',
      subtitle: 'Duplicate setup target should be ignored.',
      actionLabel: 'Review duplicate setup',
    );
    final customContribution = ProductWorkspaceActionContribution(
      id: 'restaurant_menu',
      isActive: (pack) => true,
      setupTargets: const [restaurantTarget, duplicateRestaurantTarget],
      buildGroups: (pack, summary) => const [],
    );
    final container = ProviderContainer(
      overrides: [
        productManagementPacksProvider.overrideWithValue([
          coreProductManagementPack,
          groceryFreshGoodsProductManagementPack,
        ]),
        productWorkspaceActionContributionsProvider.overrideWithValue([
          customContribution,
        ]),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    final targets =
        container
            .read(productWorkspaceSetupTargetsProvider)
            .where((target) => target.normalizedId == 'restaurant_menu')
            .toList();
    final activeTargets =
        container
            .read(productWorkspaceActiveSetupTargetsProvider)
            .where((target) => target.normalizedId == 'restaurant_menu')
            .toList();
    final activations =
        container
            .read(productWorkspaceSetupActivationsProvider)
            .where((activation) => activation.targetId == 'restaurant_menu')
            .toList();
    final overview = container.read(productWorkspaceSetupOverviewProvider);
    final prompt = overview.prompts.singleWhere(
      (prompt) => prompt.targetId == 'restaurant_menu',
    );

    expect(targets, hasLength(1));
    expect(activeTargets, hasLength(1));
    expect(
      activations.map((activation) => activation.packId),
      unorderedEquals([
        ProductManagementPackId.coreCatalog,
        ProductManagementPackId.groceryFreshGoods,
      ]),
    );
    expect(prompt.isInactive, isFalse);
    expect(prompt.targetId, 'restaurant_menu');
  });

  test('workspace setup overview uses catalog readiness evaluators', () async {
    final container = ProviderContainer(
      overrides: [
        productManagementPacksProvider.overrideWithValue([
          coreProductManagementPack,
          groceryFreshGoodsProductManagementPack,
        ]),
        inventory_products.productsProvider.overrideWith(
          (ref) => _SeededInventoryProducts([
            Product(
              id: 'milk',
              name: 'Milk',
              sku: 'MLK-001',
              category: 'Dairy',
              description: 'Fresh milk',
              price: 25000,
              barcode: '8991001',
              customAttributes: const {
                'expiry_date': '2026-08-01',
                'batch_number': 'B-01',
                'freshness_status': 'Monitor',
              },
            ),
          ]),
        ),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(productManagementPackIdProvider.notifier)
        .selectPack(ProductManagementPackId.groceryFreshGoods);

    final overview = container.read(productWorkspaceSetupOverviewProvider);
    final freshnessPrompt = overview.prompts.singleWhere(
      (prompt) => prompt.targetId == 'freshness',
    );
    final freshnessEvaluations = overview.readiness.evaluationsForTarget(
      'freshness',
    );

    expect(overview.activeCount, 1);
    expect(overview.inactiveCount, 4);
    expect(freshnessPrompt.isInactive, isFalse);
    expect(freshnessEvaluations, hasLength(3));
    expect(
      freshnessEvaluations.map((evaluation) => evaluation.statusLabel),
      everyElement('Ready'),
    );
    expect(overview.readiness.statusLabel, 'Blocked');
    expect(overview.readiness.progressLabel, '3/15 ready');
    expect(overview.readiness.readyCount, 3);
    expect(overview.readiness.blockedCount, 12);
  });

  test('workspace setup overview accepts custom readiness contributions', () {
    const target = ProductWorkspaceSetupTarget(
      id: 'self_serve_labels',
      title: 'Self-serve labels setup',
      subtitle: 'Prepare labels before kiosk rollout.',
      actionLabel: 'Review labels',
      requirements: [
        ProductWorkspaceSetupRequirement(
          id: 'label_template',
          label: 'Label template',
          type: ProductWorkspaceSetupRequirementType.workflow,
        ),
      ],
    );
    final readinessContribution = ProductWorkspaceSetupReadinessContribution(
      id: 'self_serve_label_readiness',
      buildRegistry:
          (context) => ProductWorkspaceSetupReadinessEvaluatorRegistry(
            targetRequirementEvaluators: {
              ProductWorkspaceSetupReadinessEvaluatorRegistry.targetRequirementKey(
                    'self_serve_labels',
                    'label_template',
                  ):
                  (context) =>
                      ProductWorkspaceSetupRequirementEvaluation.fromContext(
                        context: context,
                        status: ProductWorkspaceSetupRequirementStatus.ready,
                        reason: 'Label template configured',
                      ),
            },
          ),
    );
    final contribution = ProductWorkspaceActionContribution(
      id: 'self_serve_labels',
      isActive: (pack) => true,
      setupTargets: const [target],
      setupReadinessContributions: [readinessContribution],
      buildGroups: (pack, summary) => const [],
    );
    final container = ProviderContainer(
      overrides: [
        productWorkspaceActionContributionsProvider.overrideWithValue([
          contribution,
        ]),
        _memoryPreferencesRepositoryOverride(),
      ],
    );
    addTearDown(container.dispose);

    final bundle = container.read(
      productWorkspaceSetupReadinessContributionBundleProvider,
    );
    final overview = container.read(productWorkspaceSetupOverviewProvider);

    expect(bundle.contributionIds, contains('self_serve_label_readiness'));
    expect(bundle.ignoredContributionCount, 0);
    expect(overview.activeCount, 1);
    expect(overview.readiness.readyCount, 1);
    expect(
      overview.readiness
          .evaluationForRequirement(
            targetId: 'self_serve_labels',
            requirementId: 'label_template',
          )
          ?.reason,
      'Label template configured',
    );
  });
}

dynamic _memoryPreferencesRepositoryOverride() {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
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

class _SeededInventoryProducts extends inventory_products.ProductsNotifier {
  _SeededInventoryProducts(List<Product> products) {
    state = products;
  }
}
