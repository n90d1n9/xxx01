import 'management_pack_contribution_bundle.dart';
import 'management_pack_contribution_source_group.dart';
import 'management_pack_module_hook_catalog_sort.dart';

/// Status filters available in the management-pack module hook catalog.
enum ProductManagementPackModuleHookCatalogFilter {
  all,
  active,
  inactive,
  noHooks,
}

extension ProductManagementPackModuleHookCatalogFilterDetails
    on ProductManagementPackModuleHookCatalogFilter {
  String get label {
    switch (this) {
      case ProductManagementPackModuleHookCatalogFilter.all:
        return 'All';
      case ProductManagementPackModuleHookCatalogFilter.active:
        return 'Active';
      case ProductManagementPackModuleHookCatalogFilter.inactive:
        return 'Inactive';
      case ProductManagementPackModuleHookCatalogFilter.noHooks:
        return 'No hooks';
    }
  }

  bool matches(ProductManagementPackContributionSourceGroup group) {
    switch (this) {
      case ProductManagementPackModuleHookCatalogFilter.all:
        return true;
      case ProductManagementPackModuleHookCatalogFilter.active:
        return group.isModuleActive;
      case ProductManagementPackModuleHookCatalogFilter.inactive:
        return !group.isModuleActive;
      case ProductManagementPackModuleHookCatalogFilter.noHooks:
        return group.contributionCount == 0;
    }
  }
}

/// Hook-type filters available in the management-pack module hook catalog.
enum ProductManagementPackModuleHookKindFilter {
  all,
  workspaceAction,
  setupReadiness,
  recommendation,
  moduleBriefAction,
  availabilityTemplate,
}

extension ProductManagementPackModuleHookKindFilterDetails
    on ProductManagementPackModuleHookKindFilter {
  String get label {
    switch (this) {
      case ProductManagementPackModuleHookKindFilter.all:
        return 'All hook types';
      case ProductManagementPackModuleHookKindFilter.workspaceAction:
        return 'Workspace actions';
      case ProductManagementPackModuleHookKindFilter.setupReadiness:
        return 'Setup readiness';
      case ProductManagementPackModuleHookKindFilter.recommendation:
        return 'Recommendations';
      case ProductManagementPackModuleHookKindFilter.moduleBriefAction:
        return 'Module brief actions';
      case ProductManagementPackModuleHookKindFilter.availabilityTemplate:
        return 'Availability templates';
    }
  }

  ProductManagementPackContributionKind? get contributionKind {
    switch (this) {
      case ProductManagementPackModuleHookKindFilter.all:
        return null;
      case ProductManagementPackModuleHookKindFilter.workspaceAction:
        return ProductManagementPackContributionKind.workspaceAction;
      case ProductManagementPackModuleHookKindFilter.setupReadiness:
        return ProductManagementPackContributionKind.setupReadiness;
      case ProductManagementPackModuleHookKindFilter.recommendation:
        return ProductManagementPackContributionKind.recommendation;
      case ProductManagementPackModuleHookKindFilter.moduleBriefAction:
        return ProductManagementPackContributionKind.moduleBriefAction;
      case ProductManagementPackModuleHookKindFilter.availabilityTemplate:
        return ProductManagementPackContributionKind.availabilityTemplate;
    }
  }

  bool matches(ProductManagementPackContributionSourceGroup group) {
    final kind = contributionKind;
    if (kind == null) return true;

    return group.kindSections.any((section) => section.kind == kind);
  }
}

/// Applies status, kind, and search filters to module hook groups.
List<ProductManagementPackContributionSourceGroup>
filterProductManagementPackModuleHookCatalogGroups({
  required List<ProductManagementPackContributionSourceGroup> groups,
  required ProductManagementPackModuleHookCatalogFilter filter,
  ProductManagementPackModuleHookKindFilter kindFilter =
      ProductManagementPackModuleHookKindFilter.all,
  String query = '',
}) {
  return List.unmodifiable(
    groups.where(
      (group) =>
          filter.matches(group) &&
          kindFilter.matches(group) &&
          matchesProductManagementPackModuleHookCatalogQuery(
            group: group,
            query: query,
          ),
    ),
  );
}

/// Counts groups matching a status filter under the current catalog controls.
int countProductManagementPackModuleHookCatalogFilterMatches({
  required List<ProductManagementPackContributionSourceGroup> groups,
  required ProductManagementPackModuleHookCatalogFilter filter,
  ProductManagementPackModuleHookKindFilter kindFilter =
      ProductManagementPackModuleHookKindFilter.all,
  String query = '',
}) {
  return filterProductManagementPackModuleHookCatalogGroups(
    groups: groups,
    filter: filter,
    kindFilter: kindFilter,
    query: query,
  ).length;
}

/// Counts groups matching a hook-kind filter under the current controls.
int countProductManagementPackModuleHookKindFilterMatches({
  required List<ProductManagementPackContributionSourceGroup> groups,
  required ProductManagementPackModuleHookKindFilter kindFilter,
  ProductManagementPackModuleHookCatalogFilter filter =
      ProductManagementPackModuleHookCatalogFilter.all,
  String query = '',
}) {
  return filterProductManagementPackModuleHookCatalogGroups(
    groups: groups,
    filter: filter,
    kindFilter: kindFilter,
    query: query,
  ).length;
}

/// Whether any catalog filter, sort, or search control differs from default.
bool hasActiveProductManagementPackModuleHookCatalogControls({
  required ProductManagementPackModuleHookCatalogFilter filter,
  required ProductManagementPackModuleHookKindFilter kindFilter,
  required String query,
  ProductManagementPackModuleHookCatalogSort sort =
      ProductManagementPackModuleHookCatalogSort.registryOrder,
}) {
  return filter != ProductManagementPackModuleHookCatalogFilter.all ||
      kindFilter != ProductManagementPackModuleHookKindFilter.all ||
      sort != ProductManagementPackModuleHookCatalogSort.registryOrder ||
      query.trim().isNotEmpty;
}

/// Returns whether a module hook group matches the search query.
bool matchesProductManagementPackModuleHookCatalogQuery({
  required ProductManagementPackContributionSourceGroup group,
  required String query,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  final searchableText =
      [
        group.id,
        group.title,
        group.statusLabel,
        group.reasonLabel,
        group.mixLabel,
        group.contributionCountLabel,
        group.activeCountLabel,
        group.activationSummary?.description,
        for (final section in group.kindSections) ...[
          section.title,
          section.activeCountLabel,
          section.outputCountLabel,
          for (final contribution in section.contributions) ...[
            contribution.id,
            contribution.title,
            contribution.detailLabel,
            contribution.statusLabel,
            contribution.kindLabel,
            contribution.sourceLabel,
            contribution.outputPreviewLabel,
            ...contribution.outputLabels,
          ],
        ],
      ].whereType<String>().join(' ').toLowerCase();

  return searchableText.contains(normalizedQuery);
}
