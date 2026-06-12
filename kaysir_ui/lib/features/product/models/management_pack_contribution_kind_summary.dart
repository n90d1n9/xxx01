import 'management_pack_contribution_bundle.dart';

/// Count summary for one contribution kind in a management pack bundle.
class ProductManagementPackContributionKindSummary {
  const ProductManagementPackContributionKindSummary({
    required this.kind,
    required this.totalCount,
    required this.activeCount,
    required this.outputCount,
  });

  final ProductManagementPackContributionKind kind;
  final int totalCount;
  final int activeCount;
  final int outputCount;

  bool get hasContributions => totalCount > 0;
  bool get hasActiveContributions => activeCount > 0;

  String get title => kind.pluralLabel;
  String get activeCountLabel => '$activeCount/$totalCount active';
  String get outputCountLabel => _countLabel(outputCount, 'output');
}

extension ProductManagementPackContributionBundleKindSummary
    on ProductManagementPackContributionBundle {
  List<ProductManagementPackContributionKindSummary> get kindSummaries {
    return summarizeProductManagementPackContributionKinds(moduleContributions);
  }
}

/// Summarizes contribution counts and outputs by contribution kind.
List<ProductManagementPackContributionKindSummary>
summarizeProductManagementPackContributionKinds(
  List<ProductManagementPackContributionSummary> contributions,
) {
  final summaries = <ProductManagementPackContributionKindSummary>[];

  for (final kind in ProductManagementPackContributionKind.values) {
    final matching = contributions
        .where((contribution) => contribution.kind == kind)
        .toList(growable: false);
    if (matching.isEmpty) continue;

    summaries.add(
      ProductManagementPackContributionKindSummary(
        kind: kind,
        totalCount: matching.length,
        activeCount:
            matching.where((contribution) => contribution.isActive).length,
        outputCount: matching.fold<int>(
          0,
          (total, contribution) => total + contribution.outputCount,
        ),
      ),
    );
  }

  return List.unmodifiable(summaries);
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
