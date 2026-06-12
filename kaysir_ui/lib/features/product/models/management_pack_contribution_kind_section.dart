import 'management_pack_contribution_bundle.dart';

/// Source-group subsection containing contributions of the same kind.
class ProductManagementPackContributionKindSection {
  ProductManagementPackContributionKindSection({
    required this.kind,
    required List<ProductManagementPackContributionSummary> contributions,
  }) : contributions = List.unmodifiable(contributions);

  final ProductManagementPackContributionKind kind;
  final List<ProductManagementPackContributionSummary> contributions;

  int get contributionCount => contributions.length;
  int get activeContributionCount {
    return contributions.where((contribution) => contribution.isActive).length;
  }

  int get outputCount {
    return contributions.fold(
      0,
      (total, contribution) => total + contribution.outputCount,
    );
  }

  bool get hasActiveContributions => activeContributionCount > 0;

  String get title => kind.pluralLabel;
  String get activeCountLabel {
    return '$activeContributionCount/$contributionCount active';
  }

  String get outputCountLabel {
    return _countLabel(outputCount, 'output');
  }
}

/// Groups contribution summaries into ordered kind sections.
List<ProductManagementPackContributionKindSection>
groupProductManagementPackContributionsByKind(
  List<ProductManagementPackContributionSummary> contributions,
) {
  final sections = <ProductManagementPackContributionKindSection>[];

  for (final kind in ProductManagementPackContributionKind.values) {
    final matching = contributions
        .where((contribution) => contribution.kind == kind)
        .toList(growable: false);
    if (matching.isEmpty) continue;

    sections.add(
      ProductManagementPackContributionKindSection(
        kind: kind,
        contributions: matching,
      ),
    );
  }

  return List.unmodifiable(sections);
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
