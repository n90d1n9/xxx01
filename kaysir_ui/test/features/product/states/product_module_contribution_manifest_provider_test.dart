import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_suite_destination.dart';
import 'package:kaysir/features/product/models/product_workspace_action_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/management_module_brief_provider.dart';
import 'package:kaysir/features/product/states/product_module_contribution_manifest_provider.dart';
import 'package:kaysir/features/product/states/product_workspace_action_provider.dart';
import 'package:kaysir/features/product/states/product_workspace_recommendation_provider.dart';
import 'package:kaysir/features/product/states/product_workspace_setup_readiness_provider.dart';
import 'package:kaysir/features/product/utils/product_workspace_setup_readiness_evaluators.dart';

void main() {
  test('module contribution registry provider exposes default manifests', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    final registry = container.read(productModuleContributionRegistryProvider);
    final setupReadinessBundle = container.read(
      productWorkspaceSetupReadinessContributionBundleProvider,
    );

    expect(registry.manifestIds, [
      'freshness_operations',
      'coffee_counter_operations',
      'restaurant_menu_operations',
      'retail_assortment_operations',
      'kiosk_self_service_operations',
    ]);
    expect(
      container
          .read(productWorkspaceActionContributionsProvider)
          .map((contribution) => contribution.id),
      [
        productWorkspaceFreshnessContributionId,
        'coffee_counter_operations_actions',
        'restaurant_menu_operations_actions',
        'retail_assortment_operations_actions',
        'kiosk_self_service_operations_actions',
      ],
    );
    expect(setupReadinessBundle.contributionIds, [
      productWorkspaceFreshnessReadinessContributionId,
      'coffee_counter_operations_readiness',
      'restaurant_menu_operations_readiness',
      'retail_assortment_operations_readiness',
      'kiosk_self_service_operations_readiness',
    ]);
    expect(
      container
          .read(productWorkspaceRecommendationContributionsProvider)
          .map((contribution) => contribution.id),
      [
        productWorkspaceFreshnessRecommendationContributionId,
        'coffee_counter_operations_recommendations',
        'restaurant_menu_operations_recommendations',
        'retail_assortment_operations_recommendations',
        'kiosk_self_service_operations_recommendations',
      ],
    );
    expect(
      container
          .read(productManagementModuleBriefResolversProvider)
          .map((resolver) => resolver.destination),
      [
        ProductManagementSuiteDestination.variantManagement,
        ProductManagementSuiteDestination.relationshipManagement,
        ProductManagementSuiteDestination.assortmentPlanning,
        ProductManagementSuiteDestination.channelReadiness,
      ],
    );
  });

  test('module brief resolver provider follows active management pack', () {
    final container = ProviderContainer(
      overrides: [
        _memoryPreferencesRepositoryOverride(),
        productManagementPackProvider.overrideWithValue(
          groceryFreshGoodsProductManagementPack,
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container
          .read(productManagementModuleBriefResolversProvider)
          .map((resolver) => resolver.destination),
      [ProductManagementSuiteDestination.availabilityManagement],
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
