import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/models/inventory_stock_record.dart';
import 'product.dart';
import 'product_catalog_quality.dart';
import 'product_channel_launch_priority.dart';
import 'management_pack.dart';
import 'sales_channel_profile_pack_overview.dart';
import 'sales_channel_profile_readiness.dart';
import 'sales_channel_readiness.dart';
import 'sales_channel_strategy_brief.dart';
import 'product_workspace_action_group.dart';
import 'product_workspace_action_registry.dart';
import 'product_workspace_action_summary.dart';
import 'product_workspace_recommendation.dart';

class ProductWorkspaceOverview {
  ProductWorkspaceOverview({
    required List<InventoryProductCatalogRecord> records,
    required this.summary,
    required this.qualitySummary,
    required List<ProductWorkspaceActionGroup> actionGroups,
    required this.actionSummary,
    required List<ProductSalesChannelProfile> channelProfiles,
    required this.channelProfile,
    required this.channelProfilePackOverview,
    required List<ProductSalesChannelReadiness> channelReadiness,
    required this.profileReadinessSummary,
    required List<ProductSalesChannelProfileReadinessOption>
    profileReadinessOptions,
    required List<ProductChannelLaunchPriority> launchPriorities,
    required this.strategyBrief,
    required List<ProductWorkspaceRecommendation> recommendations,
  }) : records = List.unmodifiable(records),
       actionGroups = List.unmodifiable(actionGroups),
       channelProfiles = List.unmodifiable(channelProfiles),
       channelReadiness = List.unmodifiable(channelReadiness),
       profileReadinessOptions = List.unmodifiable(profileReadinessOptions),
       launchPriorities = List.unmodifiable(launchPriorities),
       recommendations = List.unmodifiable(recommendations);

  final List<InventoryProductCatalogRecord> records;
  final InventoryProductCatalogSummary summary;
  final ProductCatalogQualitySummary qualitySummary;
  final List<ProductWorkspaceActionGroup> actionGroups;
  final ProductWorkspaceActionSummary actionSummary;
  final List<ProductSalesChannelProfile> channelProfiles;
  final ProductSalesChannelProfile channelProfile;
  final ProductSalesChannelProfilePackOverview channelProfilePackOverview;
  final List<ProductSalesChannelReadiness> channelReadiness;
  final ProductSalesChannelProfileReadinessSummary profileReadinessSummary;
  final List<ProductSalesChannelProfileReadinessOption> profileReadinessOptions;
  final List<ProductChannelLaunchPriority> launchPriorities;
  final ProductSalesChannelStrategyBrief strategyBrief;
  final List<ProductWorkspaceRecommendation> recommendations;

  bool get hasAttention => summary.attentionProductCount > 0;

  bool get hasCatalogQualityIssues => qualitySummary.totalIssueCount > 0;

  ProductChannelLaunchPriority? get primaryLaunchPriority {
    if (launchPriorities.isEmpty) return null;

    return launchPriorities.first;
  }

  String get attentionLabel {
    final count = summary.attentionProductCount;
    if (count == 0) return 'No attention queue';
    if (count == 1) return '1 product needs attention';

    return '$count products need attention';
  }

  String get catalogQualityLabel {
    return '${qualitySummary.completeCountLabel}, '
        '${qualitySummary.completePercent}% complete';
  }

  String get workflowReadinessLabel => actionSummary.readyActionLabel;

  String get launchQueueLabel => strategyBrief.nextQueueLabel;

  String get pulseSubtitle {
    return '${channelProfile.title} | ${profileReadinessSummary.coverageLabel} '
        '| $attentionLabel';
  }
}

ProductWorkspaceOverview buildProductWorkspaceOverview({
  required List<Product> products,
  required List<InventoryStockRecord> stockRecords,
  required ProductWorkspaceActionRegistry actionRegistry,
  required ProductManagementPack managementPack,
  required List<ProductSalesChannelProfile> channelProfiles,
  required ProductSalesChannelProfile channelProfile,
  required ProductSalesChannelProfilePackOverview channelProfilePackOverview,
  List<ProductWorkspaceRecommendationContribution> recommendationContributions =
      const [],
}) {
  final records = buildInventoryProductCatalogRecords(
    products: products,
    stockRecords: stockRecords,
  );
  final summary = summarizeInventoryProductCatalogRecords(records);
  final actionGroups = actionRegistry.groupsFor(summary);
  final actionSummary = ProductWorkspaceActionSummary.fromGroups(actionGroups);
  final qualitySummary = summarizeProductCatalogQuality(
    records,
    pack: managementPack,
  );
  final channelReadiness = buildProductSalesChannelReadiness(
    records,
    definitions: channelProfile.definitions,
  );
  final profileReadinessSummary = summarizeProductSalesChannelProfileReadiness(
    channelReadiness,
  );
  final launchPriorities = buildProductChannelLaunchPriorities(
    channelReadiness,
  );
  final strategyBrief = buildProductSalesChannelStrategyBrief(
    profile: channelProfile,
    readiness: channelReadiness,
    summary: profileReadinessSummary,
    priorities: launchPriorities,
  );
  final recommendations = buildProductWorkspaceRecommendations(
    managementPack: managementPack,
    summary: summary,
    qualitySummary: qualitySummary,
    actionSummary: actionSummary,
    strategyBrief: strategyBrief,
    primaryLaunchPriority:
        launchPriorities.isEmpty ? null : launchPriorities.first,
    contributions: recommendationContributions,
  );

  return ProductWorkspaceOverview(
    records: records,
    summary: summary,
    qualitySummary: qualitySummary,
    actionGroups: actionGroups,
    actionSummary: actionSummary,
    channelProfiles: channelProfiles,
    channelProfile: channelProfile,
    channelProfilePackOverview: channelProfilePackOverview,
    channelReadiness: channelReadiness,
    profileReadinessSummary: profileReadinessSummary,
    profileReadinessOptions: buildProductSalesChannelProfileReadinessOptions(
      records,
      profiles: channelProfiles,
      selectedProfileId: channelProfile.id,
    ),
    launchPriorities: launchPriorities,
    strategyBrief: strategyBrief,
    recommendations: recommendations,
  );
}
