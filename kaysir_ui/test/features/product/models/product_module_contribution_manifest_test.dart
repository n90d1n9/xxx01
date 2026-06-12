import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_module_brief.dart';
import 'package:kaysir/features/product/models/management_suite_destination.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_workspace_action_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/utils/default_product_module_contribution_manifests.dart';
import 'package:kaysir/features/product/utils/product_workspace_setup_readiness_evaluators.dart';

void main() {
  test('module contribution registry exposes default manifests', () {
    final registry = ProductModuleContributionRegistry.fromManifests(
      defaultProductModuleContributionManifests,
    );

    expect(registry.manifestIds, [
      'freshness_operations',
      'coffee_counter_operations',
      'restaurant_menu_operations',
      'retail_assortment_operations',
      'kiosk_self_service_operations',
    ]);
    expect(registry.ignoredManifestCount, 0);
    expect(registry.hasDuplicateHookDiagnostics, isFalse);
    expect(registry.duplicateHookDiagnosticCountLabel, '0 duplicate hooks');
    expect(registry.actionContributions.map((item) => item.id), [
      productWorkspaceFreshnessContributionId,
      'coffee_counter_operations_actions',
      'restaurant_menu_operations_actions',
      'retail_assortment_operations_actions',
      'kiosk_self_service_operations_actions',
    ]);
    expect(registry.setupReadinessContributions.map((item) => item.id), [
      productWorkspaceFreshnessReadinessContributionId,
      'coffee_counter_operations_readiness',
      'restaurant_menu_operations_readiness',
      'retail_assortment_operations_readiness',
      'kiosk_self_service_operations_readiness',
    ]);
    expect(registry.recommendationContributions.map((item) => item.id), [
      productWorkspaceFreshnessRecommendationContributionId,
      'coffee_counter_operations_recommendations',
      'restaurant_menu_operations_recommendations',
      'retail_assortment_operations_recommendations',
      'kiosk_self_service_operations_recommendations',
    ]);
    expect(registry.moduleBriefResolvers.map((item) => item.destination), [
      ProductManagementSuiteDestination.availabilityManagement,
      ProductManagementSuiteDestination.variantManagement,
      ProductManagementSuiteDestination.relationshipManagement,
      ProductManagementSuiteDestination.assortmentPlanning,
      ProductManagementSuiteDestination.channelReadiness,
    ]);
    expect(
      registry.moduleBriefResolvers.first.contributionId,
      'freshness_availability_brief_action',
    );
    expect(
      registry
          .sourceForModuleBriefResolver(registry.moduleBriefResolvers.first)
          ?.title,
      'Freshness operations',
    );
    expect(
      registry.availabilityRuleTemplateContributions.map((item) => item.id),
      [
        'freshness_availability_templates',
        'coffee_counter_operations_availability_templates',
        'restaurant_menu_operations_availability_templates',
        'retail_assortment_operations_availability_templates',
        'kiosk_self_service_operations_availability_templates',
      ],
    );
    expect(
      registry
          .sourceForActionContribution(productWorkspaceFreshnessContributionId)
          ?.title,
      'Freshness operations',
    );
    expect(
      registry
          .sourceForSetupReadinessContribution(
            productWorkspaceFreshnessReadinessContributionId,
          )
          ?.title,
      'Freshness operations',
    );
    expect(
      registry
          .sourceForRecommendationContribution(
            productWorkspaceFreshnessRecommendationContributionId,
          )
          ?.title,
      'Freshness operations',
    );
    expect(
      registry
          .sourceForAvailabilityRuleTemplateContribution(
            'freshness_availability_templates',
          )
          ?.title,
      'Freshness operations',
    );
    expect(
      registry
          .activeManifestsFor(coreProductManagementPack)
          .map((manifest) => manifest.id),
      [
        'coffee_counter_operations',
        'restaurant_menu_operations',
        'retail_assortment_operations',
        'kiosk_self_service_operations',
      ],
    );
    expect(
      registry
          .moduleBriefResolversFor(coreProductManagementPack)
          .map((resolver) => resolver.destination),
      [
        ProductManagementSuiteDestination.variantManagement,
        ProductManagementSuiteDestination.relationshipManagement,
        ProductManagementSuiteDestination.assortmentPlanning,
        ProductManagementSuiteDestination.channelReadiness,
      ],
    );
    expect(
      registry
          .activeManifestsFor(groceryFreshGoodsProductManagementPack)
          .map((manifest) => manifest.id),
      ['freshness_operations'],
    );
    expect(
      registry
          .moduleBriefResolversFor(groceryFreshGoodsProductManagementPack)
          .map((resolver) => resolver.destination),
      [ProductManagementSuiteDestination.availabilityManagement],
    );
    final coreFreshnessSummary = registry
        .activationSummariesFor(coreProductManagementPack)
        .firstWhere((summary) => summary.id == 'freshness_operations');
    final coreCoffeeSummary = registry
        .activationSummariesFor(coreProductManagementPack)
        .firstWhere((summary) => summary.id == 'coffee_counter_operations');
    final groceryFreshnessSummary = registry
        .activationSummariesFor(groceryFreshGoodsProductManagementPack)
        .firstWhere((summary) => summary.id == 'freshness_operations');

    expect(coreFreshnessSummary.isActive, isFalse);
    expect(
      coreFreshnessSummary.reasonLabel,
      'Requires freshness, expiry, or batch product capabilities',
    );
    expect(coreFreshnessSummary.hookCountLabel, '5 hooks');
    expect(
      coreFreshnessSummary.mixLabel,
      '1 action, 1 readiness hook, 1 recommendation, 1 brief action, '
      '1 availability template',
    );
    expect(coreCoffeeSummary.isActive, isTrue);
    expect(
      coreCoffeeSummary.reasonLabel,
      'Coffee counter operations product-line module enabled',
    );
    expect(groceryFreshnessSummary.isActive, isTrue);
    expect(
      groceryFreshnessSummary.reasonLabel,
      'Freshness, expiry, or batch capability matched',
    );
    final freshnessTemplates =
        registry.availabilityRuleTemplateContributions.first.templates;
    expect(freshnessTemplates.map((template) => template.id), [
      ProductAvailabilityRuleTemplateId.freshShelf,
      ProductAvailabilityRuleTemplateId.freshnessHold,
    ]);
  });

  test('module contribution registry normalizes manifest source identity', () {
    final actionContribution = ProductWorkspaceActionContribution(
      id: ' coffee_actions ',
      isActive: (_) => true,
      buildGroups: (_, _) => const [],
    );
    final manifest = ProductModuleContributionManifest(
      id: ' coffee_bar ',
      title: ' ',
      description: ' Specialty counter setup. ',
      activeReasonLabel: ' Coffee module ready ',
      actionContributions: [actionContribution],
    );
    const duplicate = ProductModuleContributionManifest(
      id: 'coffee_bar',
      title: ' Coffee duplicate ',
      description: ' Duplicate module. ',
    );

    final registry = ProductModuleContributionRegistry.fromManifests([
      manifest,
      duplicate,
    ]);
    final source = registry.sourceForActionContribution('coffee_actions');
    final activationSummary =
        registry.activationSummariesFor(coreProductManagementPack).single;
    final ignoredDiagnostic = registry.ignoredManifestDiagnostics.single;

    expect(manifest.normalizedId, 'coffee_bar');
    expect(manifest.titleLabel, 'Coffee Bar');
    expect(manifest.descriptionLabel, 'Specialty counter setup.');
    expect(registry.manifestIds, ['coffee_bar']);
    expect(source?.id, 'coffee_bar');
    expect(source?.title, 'Coffee Bar');
    expect(source?.description, 'Specialty counter setup.');
    expect(activationSummary.id, 'coffee_bar');
    expect(activationSummary.title, 'Coffee Bar');
    expect(activationSummary.description, 'Specialty counter setup.');
    expect(activationSummary.reasonLabel, 'Coffee module ready');
    expect(ignoredDiagnostic.manifestLabel, 'coffee_bar');
    expect(ignoredDiagnostic.source.title, 'Coffee duplicate');
    expect(ignoredDiagnostic.existingSource?.title, 'Coffee Bar');
    expect(
      ignoredDiagnostic.message,
      'Coffee duplicate was ignored because Coffee Bar already registered '
      '"coffee_bar".',
    );
  });

  test('module contribution registry ignores duplicate or blank manifests', () {
    const manifest = ProductModuleContributionManifest(
      id: 'restaurant_menu',
      title: 'Restaurant menu',
      description: 'Menu setup and checkout hooks.',
    );
    const duplicate = ProductModuleContributionManifest(
      id: 'restaurant_menu',
      title: 'Duplicate restaurant menu',
      description: 'Should be ignored.',
    );
    const blank = ProductModuleContributionManifest(
      id: '',
      title: 'Blank module',
      description: 'Should be ignored.',
    );

    final registry = ProductModuleContributionRegistry.fromManifests([
      manifest,
      duplicate,
      blank,
    ]);

    expect(registry.manifestIds, ['restaurant_menu']);
    expect(registry.ignoredManifestCount, 2);
    expect(registry.hasIgnoredManifestDiagnostics, isTrue);
    expect(registry.ignoredManifestDiagnosticCountLabel, '2 ignored manifests');
    expect(
      registry.ignoredManifestDiagnostics.map(
        (diagnostic) => '${diagnostic.reasonLabel}:${diagnostic.manifestLabel}',
      ),
      ['Duplicate module id:restaurant_menu', 'Blank module id:Blank module'],
    );
    expect(
      registry.ignoredManifestDiagnostics.map(
        (diagnostic) => diagnostic.severityLabel,
      ),
      ['Error', 'Error'],
    );
    expect(
      registry.ignoredManifestDiagnostics.first.message,
      'Duplicate restaurant menu was ignored because Restaurant menu already '
      'registered "restaurant_menu".',
    );
    expect(
      registry.ignoredManifestDiagnostics.first.resolutionGuidance,
      'Rename Duplicate restaurant menu or merge it with Restaurant menu so '
      'every module manifest id stays unique.',
    );
    expect(
      registry.ignoredManifestDiagnostics.last.resolutionGuidance,
      'Set a stable non-empty manifest id before registering Blank module.',
    );
    expect(registry.manifests.single.title, 'Restaurant menu');
  });

  test('module contribution registry reports duplicate hook ids', () {
    final first = ProductModuleContributionManifest(
      id: 'freshness_a',
      title: 'Freshness A',
      description: 'First freshness module.',
      actionContributions: [freshnessProductWorkspaceActionContribution],
      moduleBriefResolvers: [
        ProductManagementModuleBriefResolver(
          id: 'shared_brief_action',
          destination: ProductManagementSuiteDestination.availabilityManagement,
          buildAction:
              (_) => const ProductManagementModuleBriefAction(
                id: 'shared_a',
                label: 'Shared A',
                detail: 'First shared action',
                destination:
                    ProductManagementSuiteDestination.availabilityManagement,
              ),
        ),
      ],
    );
    final second = ProductModuleContributionManifest(
      id: 'freshness_b',
      title: 'Freshness B',
      description: 'Second freshness module.',
      actionContributions: [freshnessProductWorkspaceActionContribution],
      moduleBriefResolvers: [
        ProductManagementModuleBriefResolver(
          id: 'shared_brief_action',
          destination: ProductManagementSuiteDestination.availabilityManagement,
          buildAction:
              (_) => const ProductManagementModuleBriefAction(
                id: 'shared_b',
                label: 'Shared B',
                detail: 'Second shared action',
                destination:
                    ProductManagementSuiteDestination.availabilityManagement,
              ),
        ),
      ],
    );

    final registry = ProductModuleContributionRegistry.fromManifests([
      first,
      second,
    ]);

    expect(registry.hasDuplicateHookDiagnostics, isTrue);
    expect(registry.duplicateHookDiagnosticCountLabel, '2 duplicate hooks');
    expect(
      registry.duplicateHookDiagnostics.map(
        (diagnostic) => '${diagnostic.kindLabel}:${diagnostic.hookId}',
      ),
      [
        'Workspace action:freshness_queue',
        'Module brief action:shared_brief_action',
      ],
    );
    expect(
      registry.duplicateHookDiagnostics.map(
        (diagnostic) => diagnostic.severityLabel,
      ),
      ['Warning', 'Warning'],
    );
    final actionDiagnostic = registry.duplicateHookDiagnostics.first;
    expect(actionDiagnostic.occurrenceCountLabel, '2 sources');
    expect(actionDiagnostic.sourceLabel, 'Freshness A, Freshness B');
    expect(
      actionDiagnostic.message,
      'Workspace action "freshness_queue" is registered by '
      'Freshness A, Freshness B',
    );
    expect(
      actionDiagnostic.resolutionGuidance,
      'Give "freshness_queue" a unique workspace action id in all but one '
      'module, or consolidate the shared behavior into a single module.',
    );
  });
}
