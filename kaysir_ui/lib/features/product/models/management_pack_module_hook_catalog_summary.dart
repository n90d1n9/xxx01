import 'management_pack_contribution_source_group.dart';

/// Aggregate module and hook coverage shown above the hook catalog.
class ProductManagementPackModuleHookCatalogSummary {
  ProductManagementPackModuleHookCatalogSummary({
    required List<ProductManagementPackContributionSourceGroup> groups,
  }) : groups = List.unmodifiable(groups);

  final List<ProductManagementPackContributionSourceGroup> groups;

  int get moduleCount => groups.length;
  int get activeModuleCount {
    return groups.where((group) => group.isModuleActive).length;
  }

  int get inactiveModuleCount => moduleCount - activeModuleCount;
  int get contributionCount {
    return groups.fold(0, (total, group) => total + group.contributionCount);
  }

  int get activeContributionCount {
    return groups.fold(
      0,
      (total, group) => total + group.activeContributionCount,
    );
  }

  int get inactiveContributionCount {
    return contributionCount - activeContributionCount;
  }

  bool get hasModules => moduleCount > 0;
  bool get hasInactiveModules => inactiveModuleCount > 0;
  bool get hasActiveModules => activeModuleCount > 0;

  String get moduleCoverageLabel {
    if (!hasModules) return 'No modules';

    return '$activeModuleCount/$moduleCount modules active';
  }

  String get hookCoverageLabel {
    if (contributionCount == 0) return 'No hooks';

    return '$activeContributionCount/$contributionCount hooks active';
  }

  String get inactiveModuleCountLabel {
    return _countLabel(inactiveModuleCount, 'inactive module');
  }

  String get statusLabel {
    if (!hasModules) return 'No modules registered';
    if (!hasActiveModules) return 'No active modules';
    if (hasInactiveModules) return 'Partial module coverage';

    return 'All modules active';
  }
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}
