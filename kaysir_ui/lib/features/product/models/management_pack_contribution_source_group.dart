import 'management_pack_contribution_bundle.dart';
import 'management_pack_contribution_kind_section.dart';
import 'product_module_contribution_activation_summary.dart';

/// Module source group for contribution summaries and activation metadata.
class ProductManagementPackContributionSourceGroup {
  ProductManagementPackContributionSourceGroup({
    required this.id,
    required this.title,
    required List<ProductManagementPackContributionSummary> contributions,
    this.activationSummary,
  }) : contributions = List.unmodifiable(contributions);

  final String id;
  final String title;
  final List<ProductManagementPackContributionSummary> contributions;
  final ProductModuleContributionActivationSummary? activationSummary;

  int get contributionCount => contributions.length;
  int get activeContributionCount {
    return contributions.where((contribution) => contribution.isActive).length;
  }

  List<ProductManagementPackContributionKindSection> get kindSections {
    return groupProductManagementPackContributionsByKind(contributions);
  }

  bool get isModuleActive =>
      activationSummary?.isActive ?? hasActiveContributions;
  bool get hasActiveContributions => activeContributionCount > 0;
  bool get hasActivationSummary => activationSummary != null;

  String get statusLabel {
    return activationSummary?.statusLabel ??
        (hasActiveContributions ? 'Active' : 'Inactive');
  }

  String get reasonLabel {
    return activationSummary?.reasonLabel ??
        (hasActiveContributions
            ? 'Module hooks available for this pack'
            : 'Module hooks are registered but inactive for this pack');
  }

  String get mixLabel {
    return activationSummary?.mixLabel ?? contributionCountLabel;
  }

  String get contributionCountLabel {
    return _countLabel(contributionCount, 'hook');
  }

  String get activeCountLabel {
    if (contributionCount == 0) return 'No hooks';

    return '$activeContributionCount/$contributionCount active';
  }
}

extension ProductManagementPackContributionBundleSourceGroups
    on ProductManagementPackContributionBundle {
  List<ProductManagementPackContributionSourceGroup>
  get moduleContributionSourceGroups {
    return groupProductManagementPackContributionsBySource(
      moduleContributions,
      activationSummaries: moduleActivationSummaries,
    );
  }
}

/// Groups contribution summaries by their contributing module source.
List<ProductManagementPackContributionSourceGroup>
groupProductManagementPackContributionsBySource(
  List<ProductManagementPackContributionSummary> contributions, {
  List<ProductModuleContributionActivationSummary> activationSummaries =
      const [],
}) {
  final order = <String>[];
  final grouped = <String, List<ProductManagementPackContributionSummary>>{};
  final titles = <String, String>{};
  final activationById = <String, ProductModuleContributionActivationSummary>{};

  void ensureGroup(String id, String title) {
    grouped.putIfAbsent(id, () {
      order.add(id);
      titles[id] = title;

      return <ProductManagementPackContributionSummary>[];
    });
  }

  for (final summary in activationSummaries) {
    final key = _activationKey(summary);
    activationById.putIfAbsent(key, () => summary);
    ensureGroup(key, summary.title);
  }

  for (final contribution in contributions) {
    final key = _sourceKey(contribution);
    ensureGroup(key, contribution.sourceLabel);
    grouped[key]!.add(contribution);
  }

  return List.unmodifiable([
    for (final id in order)
      ProductManagementPackContributionSourceGroup(
        id: id,
        title: titles[id] ?? 'Unassigned module',
        contributions: grouped[id] ?? const [],
        activationSummary: activationById[id],
      ),
  ]);
}

String _activationKey(ProductModuleContributionActivationSummary summary) {
  final sourceId = summary.id.trim();
  if (sourceId.isNotEmpty) return sourceId;

  final title = summary.title.trim();
  if (title.isNotEmpty) return _sourceTitleKey(title);

  return '__unassigned_module__';
}

String _sourceKey(ProductManagementPackContributionSummary contribution) {
  final sourceId = contribution.sourceId?.trim();
  if (sourceId != null && sourceId.isNotEmpty) return sourceId;

  if (contribution.hasSource) {
    return _sourceTitleKey(contribution.sourceLabel);
  }

  return '__unassigned_module__';
}

String _sourceTitleKey(String title) {
  return 'source-title:${title.trim().toLowerCase()}';
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
