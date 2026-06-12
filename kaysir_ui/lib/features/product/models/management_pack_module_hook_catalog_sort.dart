import 'management_pack_contribution_source_group.dart';

/// Sort options available in the management-pack module hook catalog.
enum ProductManagementPackModuleHookCatalogSort {
  registryOrder,
  activeFirst,
  mostHooks,
  alphabetical,
}

extension ProductManagementPackModuleHookCatalogSortDetails
    on ProductManagementPackModuleHookCatalogSort {
  String get label {
    switch (this) {
      case ProductManagementPackModuleHookCatalogSort.registryOrder:
        return 'Registry order';
      case ProductManagementPackModuleHookCatalogSort.activeFirst:
        return 'Active first';
      case ProductManagementPackModuleHookCatalogSort.mostHooks:
        return 'Most hooks';
      case ProductManagementPackModuleHookCatalogSort.alphabetical:
        return 'A-Z';
    }
  }

  String get activeFilterLabel {
    switch (this) {
      case ProductManagementPackModuleHookCatalogSort.registryOrder:
        return 'Registry order';
      case ProductManagementPackModuleHookCatalogSort.activeFirst:
        return 'Active first';
      case ProductManagementPackModuleHookCatalogSort.mostHooks:
        return 'Most hooks';
      case ProductManagementPackModuleHookCatalogSort.alphabetical:
        return 'A-Z';
    }
  }
}

/// Sorts module hook groups for display without mutating registry order.
List<ProductManagementPackContributionSourceGroup>
sortProductManagementPackModuleHookCatalogGroups({
  required List<ProductManagementPackContributionSourceGroup> groups,
  required ProductManagementPackModuleHookCatalogSort sort,
}) {
  if (sort == ProductManagementPackModuleHookCatalogSort.registryOrder) {
    return List.unmodifiable(groups);
  }

  final sorted = groups.toList(growable: false)..sort((left, right) {
    switch (sort) {
      case ProductManagementPackModuleHookCatalogSort.registryOrder:
        return 0;
      case ProductManagementPackModuleHookCatalogSort.activeFirst:
        return _chainComparisons([
          () => _compareBoolDesc(left.isModuleActive, right.isModuleActive),
          () => _compareIntDesc(
            left.activeContributionCount,
            right.activeContributionCount,
          ),
          () =>
              _compareIntDesc(left.contributionCount, right.contributionCount),
          () => _compareTitle(left, right),
        ]);
      case ProductManagementPackModuleHookCatalogSort.mostHooks:
        return _chainComparisons([
          () =>
              _compareIntDesc(left.contributionCount, right.contributionCount),
          () => _compareIntDesc(
            left.activeContributionCount,
            right.activeContributionCount,
          ),
          () => _compareBoolDesc(left.isModuleActive, right.isModuleActive),
          () => _compareTitle(left, right),
        ]);
      case ProductManagementPackModuleHookCatalogSort.alphabetical:
        return _compareTitle(left, right);
    }
  });

  return List.unmodifiable(sorted);
}

int _chainComparisons(List<int Function()> comparisons) {
  for (final compare in comparisons) {
    final result = compare();
    if (result != 0) return result;
  }

  return 0;
}

int _compareBoolDesc(bool left, bool right) {
  if (left == right) return 0;

  return left ? -1 : 1;
}

int _compareIntDesc(int left, int right) {
  return right.compareTo(left);
}

int _compareTitle(
  ProductManagementPackContributionSourceGroup left,
  ProductManagementPackContributionSourceGroup right,
) {
  final titleCompare = left.title.toLowerCase().compareTo(
    right.title.toLowerCase(),
  );
  if (titleCompare != 0) return titleCompare;

  return left.id.compareTo(right.id);
}
