import '../../inventory/models/inventory_product_catalog.dart';
import '../product_routes.dart';
import '../utils/product_catalog_review_target.dart';
import 'product_catalog_quality.dart';
import 'management_suite_destination.dart';
import 'product_workspace_overview.dart';
import 'product_workspace_recommendation.dart';

/// Visual priority for a product management module brief action.
enum ProductManagementModuleBriefActionTone { info, success, warning, danger }

/// Contextual next action shown by the product management suite brief.
class ProductManagementModuleBriefAction {
  const ProductManagementModuleBriefAction({
    required this.id,
    required this.label,
    required this.detail,
    required this.destination,
    this.tone = ProductManagementModuleBriefActionTone.info,
    this.routePath,
    this.contextLabel = '',
  });

  final String id;
  final String label;
  final String detail;
  final ProductManagementSuiteDestination destination;
  final ProductManagementModuleBriefActionTone tone;
  final String? routePath;
  final String contextLabel;

  bool get hasRoutePath => routePath != null && routePath!.trim().isNotEmpty;
  bool get hasContextLabel => contextLabel.trim().isNotEmpty;
}

/// Resolves a module-specific brief action from the shared product overview.
typedef ProductManagementModuleBriefActionBuilder =
    ProductManagementModuleBriefAction Function(
      ProductWorkspaceOverview overview,
    );

/// Registry entry that owns brief action behavior and diagnostics metadata.
class ProductManagementModuleBriefResolver {
  const ProductManagementModuleBriefResolver({
    required this.destination,
    required this.buildAction,
    this.id = '',
    this.title = '',
    this.description = '',
  });

  final ProductManagementSuiteDestination destination;
  final ProductManagementModuleBriefActionBuilder buildAction;
  final String id;
  final String title;
  final String description;

  String get contributionId {
    final normalizedId = id.trim();
    if (normalizedId.isNotEmpty) return normalizedId;

    return 'module_brief_${destination.name}';
  }

  bool get hasTitle => title.trim().isNotEmpty;
  bool get hasDescription => description.trim().isNotEmpty;

  ProductManagementModuleBriefAction resolve(
    ProductWorkspaceOverview overview,
  ) {
    return buildAction(overview);
  }
}

/// Extensible registry for product management module brief actions.
class ProductManagementModuleBriefRegistry {
  ProductManagementModuleBriefRegistry({
    required List<ProductManagementModuleBriefResolver> resolvers,
  }) : resolvers = List.unmodifiable(resolvers);

  final List<ProductManagementModuleBriefResolver> resolvers;

  /// Returns a registry with destination-matched resolvers replaced or added.
  ProductManagementModuleBriefRegistry mergedWith(
    Iterable<ProductManagementModuleBriefResolver> overrides,
  ) {
    final resolverByDestination = {
      for (final resolver in resolvers) resolver.destination: resolver,
    };

    for (final resolver in overrides) {
      resolverByDestination[resolver.destination] = resolver;
    }

    return ProductManagementModuleBriefRegistry(
      resolvers: resolverByDestination.values.toList(growable: false),
    );
  }

  ProductManagementModuleBriefAction resolve({
    required ProductManagementSuiteDestination activeDestination,
    required ProductWorkspaceOverview overview,
  }) {
    for (final resolver in resolvers) {
      if (resolver.destination == activeDestination) {
        return resolver.resolve(overview);
      }
    }

    return _fallbackAction(activeDestination, overview);
  }
}

final defaultProductManagementModuleBriefRegistry =
    ProductManagementModuleBriefRegistry(
      resolvers: [
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.strategy,
          buildAction: _strategyAction,
        ),
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.pricingManagement,
          buildAction: _pricingAction,
        ),
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.availabilityManagement,
          buildAction: _channelLaunchAction,
        ),
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.channelReadiness,
          buildAction: _channelLaunchAction,
        ),
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.setupTargets,
          buildAction: _setupAction,
        ),
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.packContracts,
          buildAction: _packContractsAction,
        ),
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.catalog,
          buildAction: _catalogAction,
        ),
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.freshnessReview,
          buildAction: _freshnessAction,
        ),
      ],
    );

ProductManagementModuleBriefAction _strategyAction(
  ProductWorkspaceOverview overview,
) {
  return ProductManagementModuleBriefAction(
    id: 'strategy_channel_plan',
    label: overview.strategyBrief.actionButtonLabel,
    detail: overview.strategyBrief.nextActionLabel,
    destination: ProductManagementSuiteDestination.channelReadiness,
    tone: _channelActionTone(overview),
    routePath: _channelPriorityRoutePath(overview),
    contextLabel: 'Channel strategy',
  );
}

ProductManagementModuleBriefAction _pricingAction(
  ProductWorkspaceOverview overview,
) {
  final missingPriceIssue = _activeQualityIssueById(overview, 'missingPrice');
  if (missingPriceIssue != null) {
    return ProductManagementModuleBriefAction(
      id: 'pricing_missing_price',
      label: 'Review missing prices',
      detail: missingPriceIssue.countLabel,
      destination: ProductManagementSuiteDestination.catalog,
      tone: ProductManagementModuleBriefActionTone.warning,
      routePath: ProductRoutes.catalogUriForReviewTarget(
        missingPriceIssue.reviewTarget,
      ),
      contextLabel: 'Catalog quality',
    );
  }

  return ProductManagementModuleBriefAction(
    id: 'pricing_coverage',
    label: 'Review pricing coverage',
    detail: overview.catalogQualityLabel,
    destination: ProductManagementSuiteDestination.pricingManagement,
    tone:
        overview.hasCatalogQualityIssues
            ? ProductManagementModuleBriefActionTone.info
            : ProductManagementModuleBriefActionTone.success,
    contextLabel: 'Pricing',
  );
}

ProductManagementModuleBriefAction _channelLaunchAction(
  ProductWorkspaceOverview overview,
) {
  return ProductManagementModuleBriefAction(
    id: 'channel_launch_queue',
    label: overview.strategyBrief.actionButtonLabel,
    detail: overview.strategyBrief.nextActionLabel,
    destination: ProductManagementSuiteDestination.channelReadiness,
    tone: _channelActionTone(overview),
    routePath: _channelPriorityRoutePath(overview),
    contextLabel: 'Channel readiness',
  );
}

ProductManagementModuleBriefAction _setupAction(
  ProductWorkspaceOverview overview,
) {
  final setupFocus = overview.actionSummary.setupFocus;
  if (setupFocus != null) {
    return ProductManagementModuleBriefAction(
      id: 'setup_focus_${setupFocus.actionId.name}',
      label: setupFocus.label,
      detail: setupFocus.tooltip,
      destination: ProductManagementSuiteDestination.setupTargets,
      tone: ProductManagementModuleBriefActionTone.warning,
      routePath: setupFocus.routePath,
      contextLabel: 'Workflow setup',
    );
  }

  return ProductManagementModuleBriefAction(
    id: 'setup_readiness',
    label: 'Review setup readiness',
    detail: overview.workflowReadinessLabel,
    destination: ProductManagementSuiteDestination.setupTargets,
    tone: ProductManagementModuleBriefActionTone.success,
    routePath: ProductRoutes.setupTargetsPath,
    contextLabel: 'Setup readiness',
  );
}

ProductManagementModuleBriefAction _packContractsAction(
  ProductWorkspaceOverview overview,
) {
  final fieldIssue = _activePackFieldIssue(overview);

  return ProductManagementModuleBriefAction(
    id: 'pack_contracts_required_fields',
    label:
        overview.hasCatalogQualityIssues
            ? 'Review required fields'
            : 'Review pack contract',
    detail: overview.catalogQualityLabel,
    destination: ProductManagementSuiteDestination.packContracts,
    tone:
        overview.hasCatalogQualityIssues
            ? ProductManagementModuleBriefActionTone.warning
            : ProductManagementModuleBriefActionTone.success,
    routePath:
        fieldIssue == null
            ? ProductRoutes.packContractsPath
            : ProductRoutes.catalogUriForReviewTarget(fieldIssue.reviewTarget),
    contextLabel: 'Pack contract',
  );
}

ProductManagementModuleBriefAction _catalogAction(
  ProductWorkspaceOverview overview,
) {
  final primaryIssue = _primaryQualityIssue(overview);
  if (primaryIssue != null) {
    return ProductManagementModuleBriefAction(
      id: 'catalog_${primaryIssue.id}',
      label: 'Fix ${primaryIssue.label}',
      detail: primaryIssue.countLabel,
      destination: ProductManagementSuiteDestination.catalog,
      tone: ProductManagementModuleBriefActionTone.warning,
      routePath: ProductRoutes.catalogUriForReviewTarget(
        primaryIssue.reviewTarget,
      ),
      contextLabel: 'Catalog quality',
    );
  }

  return _fallbackAction(ProductManagementSuiteDestination.catalog, overview);
}

ProductManagementModuleBriefAction _freshnessAction(
  ProductWorkspaceOverview overview,
) {
  final freshnessIssue = _activePackFieldIssue(overview);
  if (freshnessIssue != null) {
    return ProductManagementModuleBriefAction(
      id: 'freshness_${freshnessIssue.id}',
      label: 'Review ${freshnessIssue.packField!.label.toLowerCase()}',
      detail: freshnessIssue.countLabel,
      destination: ProductManagementSuiteDestination.freshnessReview,
      tone: ProductManagementModuleBriefActionTone.warning,
      routePath: ProductRoutes.catalogUriForReviewTarget(
        freshnessIssue.reviewTarget,
      ),
      contextLabel: 'Freshness setup',
    );
  }

  return ProductManagementModuleBriefAction(
    id: 'freshness_queue',
    label: 'Review freshness queue',
    detail: overview.launchQueueLabel,
    destination: ProductManagementSuiteDestination.freshnessReview,
    tone:
        overview.hasAttention
            ? ProductManagementModuleBriefActionTone.warning
            : ProductManagementModuleBriefActionTone.info,
    routePath: ProductRoutes.freshnessReviewPath,
    contextLabel: 'Freshness queue',
  );
}

ProductManagementModuleBriefAction _fallbackAction(
  ProductManagementSuiteDestination activeDestination,
  ProductWorkspaceOverview overview,
) {
  final recommendation = _primaryNavigableRecommendation(overview);
  if (recommendation != null) {
    return ProductManagementModuleBriefAction(
      id: 'recommendation_${recommendation.id}',
      label: recommendation.actionLabel,
      detail: recommendation.subtitle,
      destination: _destinationForRoutePath(
        recommendation.routePath!,
        fallback: activeDestination,
      ),
      tone: _recommendationActionTone(recommendation.priority),
      routePath: recommendation.routePath,
      contextLabel: _recommendationContextLabel(recommendation),
    );
  }

  if (overview.hasAttention) {
    return ProductManagementModuleBriefAction(
      id: 'attention_queue',
      label: 'Review attention queue',
      detail: overview.attentionLabel,
      destination: ProductManagementSuiteDestination.catalog,
      tone: ProductManagementModuleBriefActionTone.warning,
      routePath: ProductRoutes.catalogUriForReviewTarget(
        const ProductCatalogReviewTarget(
          filter: InventoryProductCatalogFilter.attention,
          title: 'Attention Review',
        ),
      ),
      contextLabel: 'Attention',
    );
  }

  return ProductManagementModuleBriefAction(
    id: 'catalog_readiness',
    label: 'Review catalog readiness',
    detail: overview.catalogQualityLabel,
    destination: activeDestination,
    tone: ProductManagementModuleBriefActionTone.success,
    routePath: null,
    contextLabel: 'Catalog readiness',
  );
}

String _recommendationContextLabel(
  ProductWorkspaceRecommendation recommendation,
) {
  final statusLabel = recommendation.statusLabel.trim();
  final sourceLabel = recommendation.sourceLabel.trim();
  if (statusLabel.isEmpty) return sourceLabel;
  if (sourceLabel.isEmpty) return statusLabel;

  return '$statusLabel / $sourceLabel';
}

String? _channelPriorityRoutePath(ProductWorkspaceOverview overview) {
  final priority = overview.strategyBrief.primaryPriority;
  if (priority == null) return null;

  return ProductRoutes.catalogUriForChannelReadiness(priority.readiness);
}

ProductManagementModuleBriefActionTone _channelActionTone(
  ProductWorkspaceOverview overview,
) {
  final priority = overview.strategyBrief.primaryPriority;
  if (priority == null) return ProductManagementModuleBriefActionTone.info;

  return priority.hasIssues
      ? ProductManagementModuleBriefActionTone.warning
      : ProductManagementModuleBriefActionTone.success;
}

ProductCatalogQualityIssue? _activeQualityIssueById(
  ProductWorkspaceOverview overview,
  String id,
) {
  for (final issue in overview.qualitySummary.activeIssues) {
    if (issue.id == id) return issue;
  }

  return null;
}

ProductWorkspaceRecommendation? _primaryNavigableRecommendation(
  ProductWorkspaceOverview overview,
) {
  for (final recommendation in overview.recommendations) {
    if (recommendation.canNavigate) return recommendation;
  }

  return null;
}

ProductManagementSuiteDestination _destinationForRoutePath(
  String routePath, {
  required ProductManagementSuiteDestination fallback,
}) {
  final path = Uri.parse(routePath).path;

  return switch (path) {
    ProductRoutes.catalogPath => ProductManagementSuiteDestination.catalog,
    ProductRoutes.strategyPath => ProductManagementSuiteDestination.strategy,
    ProductRoutes.assortmentPlanningPath =>
      ProductManagementSuiteDestination.assortmentPlanning,
    ProductRoutes.categoryManagementPath =>
      ProductManagementSuiteDestination.categoryManagement,
    ProductRoutes.pricingManagementPath =>
      ProductManagementSuiteDestination.pricingManagement,
    ProductRoutes.sourcingManagementPath =>
      ProductManagementSuiteDestination.sourcingManagement,
    ProductRoutes.lifecycleManagementPath =>
      ProductManagementSuiteDestination.lifecycleManagement,
    ProductRoutes.variantManagementPath =>
      ProductManagementSuiteDestination.variantManagement,
    ProductRoutes.relationshipManagementPath =>
      ProductManagementSuiteDestination.relationshipManagement,
    ProductRoutes.availabilityManagementPath =>
      ProductManagementSuiteDestination.availabilityManagement,
    ProductRoutes.channelReadinessPath =>
      ProductManagementSuiteDestination.channelReadiness,
    ProductRoutes.setupTargetsPath =>
      ProductManagementSuiteDestination.setupTargets,
    ProductRoutes.packContractsPath =>
      ProductManagementSuiteDestination.packContracts,
    ProductRoutes.freshnessReviewPath =>
      ProductManagementSuiteDestination.freshnessReview,
    ProductRoutes.addProductPath =>
      ProductManagementSuiteDestination.addProduct,
    ProductRoutes.stockMovementsPath =>
      ProductManagementSuiteDestination.stockMovements,
    ProductRoutes.addStockMovementPath =>
      ProductManagementSuiteDestination.addStockMovement,
    ProductRoutes.stockOpnamePath =>
      ProductManagementSuiteDestination.stockOpname,
    ProductRoutes.scanProductPath =>
      ProductManagementSuiteDestination.scanProduct,
    ProductRoutes.discrepancyReportPath =>
      ProductManagementSuiteDestination.discrepancyReport,
    _ => fallback,
  };
}

ProductManagementModuleBriefActionTone _recommendationActionTone(
  ProductWorkspaceRecommendationPriority priority,
) {
  return switch (priority) {
    ProductWorkspaceRecommendationPriority.critical =>
      ProductManagementModuleBriefActionTone.danger,
    ProductWorkspaceRecommendationPriority.high =>
      ProductManagementModuleBriefActionTone.warning,
    ProductWorkspaceRecommendationPriority.medium =>
      ProductManagementModuleBriefActionTone.warning,
    ProductWorkspaceRecommendationPriority.ready =>
      ProductManagementModuleBriefActionTone.success,
  };
}

ProductCatalogQualityIssue? _primaryQualityIssue(
  ProductWorkspaceOverview overview,
) {
  for (final issue in overview.qualitySummary.activeIssues) {
    return issue;
  }

  return null;
}

ProductCatalogQualityIssue? _activePackFieldIssue(
  ProductWorkspaceOverview overview,
) {
  for (final issue in overview.qualitySummary.activeIssues) {
    if (issue.packField != null) return issue;
  }

  return null;
}
