import '../../inventory/models/inventory_product_catalog.dart';
import 'product_workspace_setup_readiness.dart';

/// Builds readiness evaluators from the latest product catalog records.
typedef ProductWorkspaceSetupReadinessRegistryBuilder =
    ProductWorkspaceSetupReadinessEvaluatorRegistry Function(
      ProductWorkspaceSetupReadinessContributionContext context,
    );

/// Catalog snapshot passed to contributed setup-readiness evaluators.
class ProductWorkspaceSetupReadinessContributionContext {
  ProductWorkspaceSetupReadinessContributionContext({
    required List<InventoryProductCatalogRecord> records,
  }) : records = List.unmodifiable(records);

  final List<InventoryProductCatalogRecord> records;
}

/// Extension hook that contributes readiness evaluators for setup targets.
class ProductWorkspaceSetupReadinessContribution {
  const ProductWorkspaceSetupReadinessContribution({
    required this.id,
    required this.buildRegistry,
    this.targetIds = const [],
  });

  final String id;
  final ProductWorkspaceSetupReadinessRegistryBuilder buildRegistry;
  final List<String> targetIds;

  String get normalizedId => id.trim();

  List<String> get normalizedTargetIds {
    final seenIds = <String>{};
    final normalizedIds = <String>[];

    for (final targetId in targetIds) {
      final normalizedId = targetId.trim();
      if (normalizedId.isEmpty || seenIds.contains(normalizedId)) continue;

      seenIds.add(normalizedId);
      normalizedIds.add(normalizedId);
    }

    return List.unmodifiable(normalizedIds);
  }

  bool get hasTargetScope => normalizedTargetIds.isNotEmpty;

  bool coversAnyTarget(Set<String> activeTargetIds) {
    if (!hasTargetScope) return true;

    final normalizedActiveTargetIds =
        activeTargetIds
            .map((targetId) => targetId.trim())
            .where((targetId) => targetId.isNotEmpty)
            .toSet();

    return normalizedTargetIds.any(normalizedActiveTargetIds.contains);
  }

  ProductWorkspaceSetupReadinessEvaluatorRegistry registryFor(
    ProductWorkspaceSetupReadinessContributionContext context,
  ) {
    return buildRegistry(context);
  }
}

/// Deduplicated setup-readiness contribution collection used by providers.
class ProductWorkspaceSetupReadinessContributionBundle {
  factory ProductWorkspaceSetupReadinessContributionBundle({
    required List<ProductWorkspaceSetupReadinessContribution> contributions,
  }) {
    final merged = _mergeContributions(contributions);

    return ProductWorkspaceSetupReadinessContributionBundle._(
      contributions: merged,
      ignoredContributionCount: contributions.length - merged.length,
    );
  }

  ProductWorkspaceSetupReadinessContributionBundle._({
    required List<ProductWorkspaceSetupReadinessContribution> contributions,
    required this.ignoredContributionCount,
  }) : contributions = List.unmodifiable(contributions);

  final List<ProductWorkspaceSetupReadinessContribution> contributions;
  final int ignoredContributionCount;

  bool get isEmpty => contributions.isEmpty;
  bool get isNotEmpty => contributions.isNotEmpty;
  int get contributionCount => contributions.length;

  List<String> get contributionIds {
    return List.unmodifiable(
      contributions.map((contribution) => contribution.normalizedId),
    );
  }

  String get contributionCountLabel {
    return _countLabel(contributionCount, 'contribution');
  }

  String get ignoredContributionCountLabel {
    return _countLabel(ignoredContributionCount, 'ignored contribution');
  }

  ProductWorkspaceSetupReadinessEvaluatorRegistry registryFor(
    ProductWorkspaceSetupReadinessContributionContext context,
  ) {
    return ProductWorkspaceSetupReadinessEvaluatorRegistry.combine([
      for (final contribution in contributions)
        contribution.registryFor(context),
    ]);
  }
}

List<ProductWorkspaceSetupReadinessContribution> _mergeContributions(
  List<ProductWorkspaceSetupReadinessContribution> contributions,
) {
  final seenIds = <String>{};
  final merged = <ProductWorkspaceSetupReadinessContribution>[];

  for (final contribution in contributions) {
    final normalizedId = contribution.normalizedId;
    if (normalizedId.isEmpty || seenIds.contains(normalizedId)) continue;

    seenIds.add(normalizedId);
    merged.add(contribution);
  }

  return merged;
}

String _countLabel(int count, String singular) {
  return count == 1 ? '1 $singular' : '$count ${singular}s';
}
