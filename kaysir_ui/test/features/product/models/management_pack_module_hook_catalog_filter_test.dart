import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_bundle.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_source_group.dart';
import 'package:kaysir/features/product/models/management_pack_module_hook_catalog_filter.dart';
import 'package:kaysir/features/product/models/management_pack_module_hook_catalog_result_summary.dart';
import 'package:kaysir/features/product/models/management_pack_module_hook_catalog_sort.dart';
import 'package:kaysir/features/product/models/product_module_contribution_activation_summary.dart';

void main() {
  test('module hook catalog filter matches activation and hook states', () {
    final groups = _groups;

    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
      ).map((group) => group.title),
      ['Active module', 'Inactive module', 'Diagnostic module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.active,
      ).map((group) => group.title),
      ['Active module', 'Diagnostic module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.inactive,
      ).map((group) => group.title),
      ['Inactive module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.noHooks,
      ).map((group) => group.title),
      ['Diagnostic module'],
    );
  });

  test('module hook catalog filter exposes match counts', () {
    final groups = _groups;

    expect(
      countProductManagementPackModuleHookCatalogFilterMatches(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
      ),
      3,
    );
    expect(
      countProductManagementPackModuleHookCatalogFilterMatches(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.active,
      ),
      2,
    );
    expect(
      countProductManagementPackModuleHookCatalogFilterMatches(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.inactive,
      ),
      1,
    );
    expect(
      countProductManagementPackModuleHookCatalogFilterMatches(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.noHooks,
      ),
      1,
    );
  });

  test('module hook catalog query matches module and contribution text', () {
    final groups = _groups;

    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        query: 'registered',
      ).map((group) => group.title),
      ['Diagnostic module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        query: 'inactive action',
      ).map((group) => group.title),
      ['Inactive module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.active,
        query: 'disabled',
      ),
      isEmpty,
    );
    expect(
      countProductManagementPackModuleHookCatalogFilterMatches(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.noHooks,
        query: 'diagnostic',
      ),
      1,
    );
  });

  test('module hook catalog kind filter matches contribution kinds', () {
    final groups = _kindGroups;

    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.workspaceAction,
      ).map((group) => group.title),
      ['Workspace module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.setupReadiness,
      ).map((group) => group.title),
      ['Readiness module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.recommendation,
      ).map((group) => group.title),
      ['Recommendation module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.moduleBriefAction,
      ).map((group) => group.title),
      ['Brief action module'],
    );
    expect(
      filterProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter:
            ProductManagementPackModuleHookKindFilter.availabilityTemplate,
      ).map((group) => group.title),
      ['Availability module'],
    );
    expect(
      countProductManagementPackModuleHookKindFilterMatches(
        groups: groups,
        kindFilter: ProductManagementPackModuleHookKindFilter.recommendation,
      ),
      1,
    );
    expect(
      countProductManagementPackModuleHookCatalogFilterMatches(
        groups: groups,
        filter: ProductManagementPackModuleHookCatalogFilter.active,
        kindFilter: ProductManagementPackModuleHookKindFilter.setupReadiness,
        query: 'inventory',
      ),
      1,
    );
  });

  test('module hook catalog detects active controls', () {
    expect(
      hasActiveProductManagementPackModuleHookCatalogControls(
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.all,
        query: '',
      ),
      isFalse,
    );
    expect(
      hasActiveProductManagementPackModuleHookCatalogControls(
        filter: ProductManagementPackModuleHookCatalogFilter.inactive,
        kindFilter: ProductManagementPackModuleHookKindFilter.all,
        query: '',
      ),
      isTrue,
    );
    expect(
      hasActiveProductManagementPackModuleHookCatalogControls(
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.recommendation,
        query: '',
      ),
      isTrue,
    );
    expect(
      hasActiveProductManagementPackModuleHookCatalogControls(
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.all,
        query: 'inventory',
      ),
      isTrue,
    );
    expect(
      hasActiveProductManagementPackModuleHookCatalogControls(
        filter: ProductManagementPackModuleHookCatalogFilter.all,
        kindFilter: ProductManagementPackModuleHookKindFilter.all,
        query: '',
        sort: ProductManagementPackModuleHookCatalogSort.alphabetical,
      ),
      isTrue,
    );
  });

  test('module hook catalog sort orders filtered groups', () {
    final groups = _groups;

    expect(
      sortProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        sort: ProductManagementPackModuleHookCatalogSort.registryOrder,
      ).map((group) => group.title),
      ['Active module', 'Inactive module', 'Diagnostic module'],
    );
    expect(
      sortProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        sort: ProductManagementPackModuleHookCatalogSort.activeFirst,
      ).map((group) => group.title),
      ['Active module', 'Diagnostic module', 'Inactive module'],
    );
    expect(
      sortProductManagementPackModuleHookCatalogGroups(
        groups: groups,
        sort: ProductManagementPackModuleHookCatalogSort.alphabetical,
      ).map((group) => group.title),
      ['Active module', 'Diagnostic module', 'Inactive module'],
    );
  });

  test('module hook catalog result summary labels visible results', () {
    const unfiltered = ProductManagementPackModuleHookCatalogResultSummary(
      totalCount: 3,
      visibleCount: 3,
      filter: ProductManagementPackModuleHookCatalogFilter.all,
      kindFilter: ProductManagementPackModuleHookKindFilter.all,
      query: '',
    );
    const filtered = ProductManagementPackModuleHookCatalogResultSummary(
      totalCount: 3,
      visibleCount: 1,
      filter: ProductManagementPackModuleHookCatalogFilter.inactive,
      kindFilter: ProductManagementPackModuleHookKindFilter.recommendation,
      query: 'launch',
    );
    const sorted = ProductManagementPackModuleHookCatalogResultSummary(
      totalCount: 3,
      visibleCount: 3,
      filter: ProductManagementPackModuleHookCatalogFilter.all,
      kindFilter: ProductManagementPackModuleHookKindFilter.all,
      query: '',
      sort: ProductManagementPackModuleHookCatalogSort.alphabetical,
    );

    expect(unfiltered.resultLabel, 'Showing all 3 modules');
    expect(unfiltered.contextLabel, 'Unfiltered');
    expect(filtered.resultLabel, 'Showing 1 of 3 modules');
    expect(filtered.contextLabel, 'Inactive + Recommendations + Search');
    expect(sorted.resultLabel, 'Showing 3 of 3 modules');
    expect(sorted.contextLabel, 'Sorted A-Z');
  });
}

final _groups = [
  ProductManagementPackContributionSourceGroup(
    id: 'active_module',
    title: 'Active module',
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'active_action',
        kind: ProductManagementPackContributionKind.workspaceAction,
        title: 'Active action',
        detailLabel: '1 action',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 1,
      ),
    ],
    activationSummary: const ProductModuleContributionActivationSummary(
      id: 'active_module',
      title: 'Active module',
      description: 'Active module test fixture.',
      isActive: true,
      reasonLabel: 'Enabled',
      actionContributionCount: 1,
      setupReadinessContributionCount: 0,
      recommendationContributionCount: 0,
    ),
  ),
  ProductManagementPackContributionSourceGroup(
    id: 'inactive_module',
    title: 'Inactive module',
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'inactive_action',
        kind: ProductManagementPackContributionKind.workspaceAction,
        title: 'Inactive action',
        detailLabel: 'Inactive',
        statusLabel: 'Inactive',
        isActive: false,
        outputCount: 0,
      ),
    ],
    activationSummary: const ProductModuleContributionActivationSummary(
      id: 'inactive_module',
      title: 'Inactive module',
      description: 'Inactive module test fixture.',
      isActive: false,
      reasonLabel: 'Disabled',
      actionContributionCount: 1,
      setupReadinessContributionCount: 0,
      recommendationContributionCount: 0,
    ),
  ),
  ProductManagementPackContributionSourceGroup(
    id: 'diagnostic_module',
    title: 'Diagnostic module',
    contributions: const [],
    activationSummary: const ProductModuleContributionActivationSummary(
      id: 'diagnostic_module',
      title: 'Diagnostic module',
      description: 'Diagnostic-only module test fixture.',
      isActive: true,
      reasonLabel: 'Registered',
      actionContributionCount: 0,
      setupReadinessContributionCount: 0,
      recommendationContributionCount: 0,
    ),
  ),
];

final _kindGroups = [
  ProductManagementPackContributionSourceGroup(
    id: 'workspace_module',
    title: 'Workspace module',
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'workspace_action',
        kind: ProductManagementPackContributionKind.workspaceAction,
        title: 'Workspace action',
        detailLabel: 'Open workspace action',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 1,
      ),
    ],
  ),
  ProductManagementPackContributionSourceGroup(
    id: 'readiness_module',
    title: 'Readiness module',
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'inventory_readiness',
        kind: ProductManagementPackContributionKind.setupReadiness,
        title: 'Inventory readiness',
        detailLabel: 'Validate inventory setup',
        statusLabel: 'Monitoring',
        isActive: true,
        outputCount: 1,
      ),
    ],
  ),
  ProductManagementPackContributionSourceGroup(
    id: 'recommendation_module',
    title: 'Recommendation module',
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'launch_recommendation',
        kind: ProductManagementPackContributionKind.recommendation,
        title: 'Launch recommendation',
        detailLabel: 'Recommend launch setup',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 1,
      ),
    ],
  ),
  ProductManagementPackContributionSourceGroup(
    id: 'brief_action_module',
    title: 'Brief action module',
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'availability_brief_action',
        kind: ProductManagementPackContributionKind.moduleBriefAction,
        title: 'Availability brief action',
        detailLabel: 'Overrides suite next action',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 1,
      ),
    ],
  ),
  ProductManagementPackContributionSourceGroup(
    id: 'availability_module',
    title: 'Availability module',
    contributions: [
      ProductManagementPackContributionSummary(
        id: 'availability_templates',
        kind: ProductManagementPackContributionKind.availabilityTemplate,
        title: 'Availability templates',
        detailLabel: '2 templates',
        statusLabel: 'Active',
        isActive: true,
        outputCount: 2,
      ),
    ],
  ),
];
