import '../../inventory/models/inventory_product_catalog.dart';
import '../product_routes.dart';
import '../utils/product_catalog_review_target.dart';
import 'product_catalog_quality.dart';
import 'product_channel_launch_priority.dart';
import 'management_pack.dart';
import 'sales_channel_strategy_brief.dart';
import 'product_workspace_action_group.dart';
import 'product_workspace_action_summary.dart';

/// Priority used to order product workspace recommendations.
enum ProductWorkspaceRecommendationPriority { critical, high, medium, ready }

/// Operator-facing next step surfaced by the product workspace.
class ProductWorkspaceRecommendation {
  const ProductWorkspaceRecommendation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.statusLabel,
    required this.priority,
    this.sourceLabel = 'Core',
    this.routePath,
  });

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String statusLabel;
  final ProductWorkspaceRecommendationPriority priority;
  final String sourceLabel;
  final String? routePath;

  String get normalizedId => id.trim();
  bool get hasTitle => title.trim().isNotEmpty;

  bool get canNavigate {
    final path = routePath?.trim();

    return path != null && path.isNotEmpty;
  }
}

const productWorkspaceFreshnessRecommendationContributionId =
    'freshness_data_setup';

const freshnessProductWorkspaceRecommendationContribution =
    ProductWorkspaceRecommendationContribution(
      id: productWorkspaceFreshnessRecommendationContributionId,
      isActive: _hasFreshnessRecommendations,
      buildRecommendations: _buildFreshnessRecommendations,
    );

const defaultProductWorkspaceRecommendationContributions = [
  freshnessProductWorkspaceRecommendationContribution,
];

typedef ProductWorkspaceRecommendationBuilder =
    List<ProductWorkspaceRecommendation> Function(
      ProductWorkspaceRecommendationContext context,
    );

/// Context passed to product modules when building workspace recommendations.
class ProductWorkspaceRecommendationContext {
  const ProductWorkspaceRecommendationContext({
    required this.managementPack,
    required this.summary,
    required this.qualitySummary,
    required this.actionSummary,
    required this.strategyBrief,
    this.primaryLaunchPriority,
  });

  final ProductManagementPack managementPack;
  final InventoryProductCatalogSummary summary;
  final ProductCatalogQualitySummary qualitySummary;
  final ProductWorkspaceActionSummary actionSummary;
  final ProductSalesChannelStrategyBrief strategyBrief;
  final ProductChannelLaunchPriority? primaryLaunchPriority;
}

/// Extension hook that contributes recommendations for a management pack.
class ProductWorkspaceRecommendationContribution {
  const ProductWorkspaceRecommendationContribution({
    required this.id,
    required this.buildRecommendations,
    this.isActive,
  });

  final String id;
  final ProductWorkspaceRecommendationBuilder buildRecommendations;
  final bool Function(ProductWorkspaceRecommendationContext context)? isActive;

  String get normalizedId => id.trim();

  bool isActiveFor(ProductWorkspaceRecommendationContext context) {
    return normalizedId.isNotEmpty && (isActive?.call(context) ?? true);
  }

  List<ProductWorkspaceRecommendation> recommendationsFor(
    ProductWorkspaceRecommendationContext context,
  ) {
    if (!isActiveFor(context)) return const [];

    return List.unmodifiable(
      buildRecommendations(context).where(
        (recommendation) =>
            recommendation.normalizedId.isNotEmpty && recommendation.hasTitle,
      ),
    );
  }
}

List<ProductWorkspaceRecommendation> buildProductWorkspaceRecommendations({
  required ProductManagementPack managementPack,
  required InventoryProductCatalogSummary summary,
  required ProductCatalogQualitySummary qualitySummary,
  required ProductWorkspaceActionSummary actionSummary,
  required ProductSalesChannelStrategyBrief strategyBrief,
  ProductChannelLaunchPriority? primaryLaunchPriority,
  List<ProductWorkspaceRecommendationContribution> contributions = const [],
  int limit = 4,
}) {
  if (limit <= 0) return const [];

  final recommendations = <ProductWorkspaceRecommendation>[];
  final context = ProductWorkspaceRecommendationContext(
    managementPack: managementPack,
    summary: summary,
    qualitySummary: qualitySummary,
    actionSummary: actionSummary,
    strategyBrief: strategyBrief,
    primaryLaunchPriority: primaryLaunchPriority,
  );
  final launchPriority =
      context.primaryLaunchPriority ?? context.strategyBrief.primaryPriority;

  if (launchPriority != null && launchPriority.hasIssues) {
    recommendations.add(
      ProductWorkspaceRecommendation(
        id: 'launch_queue',
        title: 'Clear launch queue',
        subtitle:
            '${launchPriority.readiness.title}: '
            '${launchPriority.actionLabel}',
        actionLabel: 'Open queue',
        statusLabel: launchPriority.statusLabel,
        priority: _priorityForLaunchPriority(launchPriority),
        routePath: ProductRoutes.catalogUriForReviewTarget(
          ProductCatalogReviewTarget.fromReadiness(launchPriority.readiness),
        ),
      ),
    );
  }

  final topQualityIssue = _topQualityIssue(context.qualitySummary);
  if (topQualityIssue != null) {
    recommendations.add(
      ProductWorkspaceRecommendation(
        id: 'catalog_setup',
        title: 'Fix catalog setup',
        subtitle: topQualityIssue.countLabel,
        actionLabel: 'Open setup',
        statusLabel: 'Setup',
        priority: ProductWorkspaceRecommendationPriority.high,
        routePath: ProductRoutes.catalogUriForReviewTarget(
          topQualityIssue.reviewTarget,
        ),
      ),
    );
  }

  if (context.summary.attentionProductCount > 0) {
    recommendations.add(
      ProductWorkspaceRecommendation(
        id: 'stock_attention',
        title: 'Review stock attention',
        subtitle: _attentionLabel(context.summary.attentionProductCount),
        actionLabel: 'Open attention',
        statusLabel: 'Attention',
        priority: ProductWorkspaceRecommendationPriority.medium,
        routePath: ProductRoutes.catalogUriForReviewTarget(
          const ProductCatalogReviewTarget(
            filter: InventoryProductCatalogFilter.attention,
            title: 'Attention Review',
          ),
        ),
      ),
    );
  }

  final setupFocus = context.actionSummary.setupFocus;
  if (setupFocus != null) {
    recommendations.add(
      ProductWorkspaceRecommendation(
        id: 'workflow_setup',
        title: 'Connect workflow',
        subtitle: setupFocus.tooltip,
        actionLabel: 'Review setup',
        statusLabel: context.actionSummary.readinessLabel,
        priority: _priorityForActionAvailability(
          context.actionSummary.availability,
        ),
      ),
    );
  }

  for (final contribution in contributions) {
    recommendations.addAll(contribution.recommendationsFor(context));
  }

  if (recommendations.isEmpty) {
    recommendations.add(
      ProductWorkspaceRecommendation(
        id: 'launch_ready',
        title: 'Review launch-ready catalog',
        subtitle: context.strategyBrief.operatorCueLabel,
        actionLabel: 'Open catalog',
        statusLabel: 'Ready',
        priority: ProductWorkspaceRecommendationPriority.ready,
        routePath: ProductRoutes.catalogPath,
      ),
    );
  }

  recommendations.sort(_compareRecommendations);

  return List.unmodifiable(recommendations.take(limit));
}

bool _hasFreshnessRecommendations(
  ProductWorkspaceRecommendationContext context,
) {
  return context.managementPack.hasCapability(
        ProductManagementCapability.freshnessQueue,
      ) ||
      context.managementPack.hasCapability(
        ProductManagementCapability.expiryTracking,
      ) ||
      context.managementPack.hasCapability(
        ProductManagementCapability.batchTracking,
      );
}

List<ProductWorkspaceRecommendation> _buildFreshnessRecommendations(
  ProductWorkspaceRecommendationContext context,
) {
  final issue = _topFreshnessIssue(context.qualitySummary);
  if (issue == null) return const [];

  final totalFreshnessIssueCount = _freshnessIssues(
    context.qualitySummary,
  ).fold(0, (total, issue) => total + issue.count);
  final issueLabel =
      totalFreshnessIssueCount == 1
          ? '1 freshness setup gap'
          : '$totalFreshnessIssueCount freshness setup gaps';

  return [
    ProductWorkspaceRecommendation(
      id: 'freshness_data_setup',
      title: 'Prepare freshness data',
      subtitle: '$issueLabel before fresh-goods selling',
      actionLabel: 'Open freshness',
      statusLabel: 'Freshness',
      sourceLabel: context.managementPack.title,
      priority: ProductWorkspaceRecommendationPriority.high,
      routePath: ProductRoutes.catalogUriForReviewTarget(
        issue.reviewTarget.copyWith(
          title: 'Freshness setup',
          reasonLabel: issue.label,
        ),
      ),
    ),
  ];
}

ProductCatalogQualityIssue? _topFreshnessIssue(
  ProductCatalogQualitySummary summary,
) {
  final issues = _freshnessIssues(summary);
  if (issues.isEmpty) return null;

  return issues.first;
}

List<ProductCatalogQualityIssue> _freshnessIssues(
  ProductCatalogQualitySummary summary,
) {
  return [
    for (final issue in summary.activeIssues)
      if (_isFreshnessField(issue.packField)) issue,
  ];
}

bool _isFreshnessField(ProductManagementPackField? field) {
  if (field == null) return false;

  return switch (field.capability) {
    ProductManagementCapability.expiryTracking ||
    ProductManagementCapability.batchTracking ||
    ProductManagementCapability.weightedInventory ||
    ProductManagementCapability.freshnessQueue => true,
    ProductManagementCapability.catalogBasics ||
    ProductManagementCapability.scanReadiness ||
    ProductManagementCapability.stockTracking ||
    ProductManagementCapability.omniChannelReadiness => false,
  };
}

ProductCatalogQualityIssue? _topQualityIssue(
  ProductCatalogQualitySummary summary,
) {
  final issues = summary.activeIssues;
  if (issues.isEmpty) return null;

  return issues.first;
}

ProductWorkspaceRecommendationPriority _priorityForLaunchPriority(
  ProductChannelLaunchPriority priority,
) {
  return switch (priority.level) {
    ProductChannelLaunchPriorityLevel.blocked =>
      ProductWorkspaceRecommendationPriority.critical,
    ProductChannelLaunchPriorityLevel.improving =>
      ProductWorkspaceRecommendationPriority.high,
    ProductChannelLaunchPriorityLevel.ready =>
      ProductWorkspaceRecommendationPriority.ready,
  };
}

ProductWorkspaceRecommendationPriority _priorityForActionAvailability(
  ProductWorkspaceActionGroupAvailability availability,
) {
  return switch (availability) {
    ProductWorkspaceActionGroupAvailability.gated =>
      ProductWorkspaceRecommendationPriority.high,
    ProductWorkspaceActionGroupAvailability.partial =>
      ProductWorkspaceRecommendationPriority.medium,
    ProductWorkspaceActionGroupAvailability.ready =>
      ProductWorkspaceRecommendationPriority.ready,
  };
}

int _compareRecommendations(
  ProductWorkspaceRecommendation left,
  ProductWorkspaceRecommendation right,
) {
  final priorityComparison = left.priority.index.compareTo(
    right.priority.index,
  );
  if (priorityComparison != 0) return priorityComparison;

  return left.title.compareTo(right.title);
}

String _attentionLabel(int count) {
  if (count == 1) return '1 product needs attention';

  return '$count products need attention';
}
