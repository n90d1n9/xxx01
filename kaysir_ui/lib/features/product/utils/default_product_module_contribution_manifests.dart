import '../models/management_pack.dart';
import '../models/product_availability_rule_authoring.dart';
import '../models/management_module_brief.dart';
import '../models/management_suite_destination.dart';
import '../models/product_module_contribution_manifest.dart';
import '../models/product_workspace_overview.dart';
import '../models/product_workspace_action_contribution.dart';
import '../models/product_workspace_recommendation.dart';
import '../product_routes.dart';
import 'default_product_line_module_manifests.dart';
import 'product_workspace_setup_readiness_evaluators.dart';

final productFreshnessModuleContributionManifest =
    ProductModuleContributionManifest(
      id: 'freshness_operations',
      title: 'Freshness operations',
      description:
          'Expiry, batch, and pull-from-shelf hooks for fresh goods packs.',
      isActive: _supportsFreshnessOperations,
      activeReasonLabel: 'Freshness, expiry, or batch capability matched',
      inactiveReasonLabel:
          'Requires freshness, expiry, or batch product capabilities',
      actionContributions: [freshnessProductWorkspaceActionContribution],
      setupReadinessContributions: [
        freshnessProductWorkspaceSetupReadinessContribution,
      ],
      recommendationContributions: [
        freshnessProductWorkspaceRecommendationContribution,
      ],
      moduleBriefResolvers: [
        ProductManagementModuleBriefResolver(
          id: 'freshness_availability_brief_action',
          title: 'Freshness selling gates',
          description:
              'Routes availability next actions to freshness queue review.',
          destination: ProductManagementSuiteDestination.availabilityManagement,
          buildAction: _freshnessAvailabilityBriefAction,
        ),
      ],
      availabilityRuleTemplateContributions: [
        freshnessProductAvailabilityRuleTemplateContribution,
      ],
    );

const freshnessProductAvailabilityRuleTemplateContribution =
    ProductAvailabilityRuleTemplateContribution(
      id: 'freshness_availability_templates',
      title: 'Freshness availability templates',
      isActive: _supportsFreshnessOperations,
      templates: [
        ProductAvailabilityRuleTemplate(
          id: ProductAvailabilityRuleTemplateId.freshShelf,
          title: 'Fresh shelf',
          subtitle: 'Fresh goods selling with expiry-aware stock gates.',
          attributes: {
            'available_channels': 'POS, Online Store',
            'sales_status': 'active',
            'stock_policy': 'in_stock_only',
            'fulfillment_modes': 'pickup, delivery',
            'freshness_status': 'Fresh',
          },
        ),
        ProductAvailabilityRuleTemplate(
          id: ProductAvailabilityRuleTemplateId.freshnessHold,
          title: 'Freshness hold',
          subtitle: 'Pause selling while freshness or batch checks run.',
          attributes: {
            'availability_status': 'paused',
            'availability_window': 'freshness_hold',
            'freshness_status': 'Pull',
          },
        ),
      ],
    );

final defaultCoreProductModuleContributionManifests = [
  productFreshnessModuleContributionManifest,
];

final defaultProductModuleContributionManifests = [
  ...defaultCoreProductModuleContributionManifests,
  ...defaultProductLineModuleContributionManifests,
];

ProductManagementModuleBriefAction _freshnessAvailabilityBriefAction(
  ProductWorkspaceOverview overview,
) {
  return ProductManagementModuleBriefAction(
    id: 'freshness_availability_gates',
    label: 'Review freshness selling gates',
    detail: overview.launchQueueLabel,
    destination: ProductManagementSuiteDestination.freshnessReview,
    tone:
        overview.hasAttention
            ? ProductManagementModuleBriefActionTone.warning
            : ProductManagementModuleBriefActionTone.info,
    routePath: ProductRoutes.freshnessReviewPath,
    contextLabel: 'Freshness operations',
  );
}

bool _supportsFreshnessOperations(ProductManagementPack pack) {
  return pack.hasCapability(ProductManagementCapability.freshnessQueue) ||
      pack.hasCapability(ProductManagementCapability.expiryTracking) ||
      pack.hasCapability(ProductManagementCapability.batchTracking);
}
