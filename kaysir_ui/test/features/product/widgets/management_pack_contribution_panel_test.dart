import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_bundle.dart';
import 'package:kaysir/features/product/models/product_module_contribution_activation_summary.dart';
import 'package:kaysir/features/product/models/product_module_contribution_manifest.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';
import 'package:kaysir/features/product/widgets/management_pack_contribution_panel.dart';

void main() {
  testWidgets('pack contribution panel renders contract and hook catalog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackContributionPanel(bundle: _bundle),
        ),
      ),
    );

    expect(find.text('Pack contribution bundle'), findsOneWidget);
    expect(
      find.textContaining('Grocery Fresh Goods | Grocery and fresh goods'),
      findsOneWidget,
    );
    expect(find.text('9 fields'), findsOneWidget);
    expect(find.text('4 required fields'), findsOneWidget);
    expect(find.text('1 channel pack'), findsOneWidget);
    expect(find.text('5/5 active hooks'), findsOneWidget);
    expect(find.text('0 registry issues'), findsNothing);
    expect(find.text('Module registry health'), findsNothing);
    expect(find.text('All (0)'), findsNothing);
    expect(find.text('Data contract'), findsOneWidget);
    expect(find.text('Behavior contract'), findsOneWidget);
    expect(find.textContaining('SKU, Category'), findsOneWidget);
    expect(find.text('Grocery Fresh Goods Channels'), findsOneWidget);
    expect(find.text('Module diagnostics'), findsOneWidget);
    expect(
      find.textContaining('Freshness, expiry, or batch capability matched'),
      findsNWidgets(2),
    );
    expect(find.text('5 hooks'), findsNWidgets(2));
    expect(find.text('Hook coverage'), findsOneWidget);
    expect(find.text('Workspace actions'), findsNWidgets(2));
    expect(find.text('Setup readiness'), findsNWidgets(2));
    expect(find.text('Recommendations'), findsNWidgets(2));
    expect(find.text('Module brief actions'), findsNWidgets(2));
    expect(find.text('Availability templates'), findsNWidgets(2));
    expect(find.text('1/1 active'), findsNWidgets(10));
    expect(find.text('1 output'), findsNWidgets(8));
    expect(find.text('2 outputs'), findsNWidgets(2));
    expect(find.text('Extension hook catalog'), findsOneWidget);
    expect(find.text('Module coverage'), findsOneWidget);
    expect(find.text('All modules active'), findsOneWidget);
    expect(find.text('1/1 modules active'), findsOneWidget);
    expect(find.text('5/5 hooks active'), findsOneWidget);
    expect(
      find.textContaining('Freshness operations'),
      findsAtLeastNWidgets(5),
    );
    expect(find.text('5/5 active'), findsOneWidget);
    expect(find.text('Freshness control'), findsOneWidget);
    expect(find.text('Freshness Readiness'), findsOneWidget);
    expect(find.text('Prepare freshness data'), findsOneWidget);
    expect(find.text('Freshness selling gates'), findsOneWidget);
    expect(find.text('Freshness availability templates'), findsOneWidget);
    expect(find.textContaining('Fresh shelf +1 more'), findsOneWidget);
  });

  testWidgets('pack contribution panel keeps inactive hooks inspectable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackContributionPanel(bundle: _coreBundle),
        ),
      ),
    );

    expect(find.text('0/5 active hooks'), findsOneWidget);
    expect(find.text('Module diagnostics'), findsOneWidget);
    expect(
      find.textContaining(
        'Requires freshness, expiry, or batch product capabilities',
      ),
      findsNWidgets(2),
    );
    expect(find.text('5 hooks'), findsNWidgets(2));
    expect(find.text('Hook coverage'), findsOneWidget);
    expect(find.text('0/1 active'), findsNWidgets(10));
    expect(find.text('0 outputs'), findsNWidgets(10));
    expect(find.text('Extension hook catalog'), findsOneWidget);
    expect(find.text('Module coverage'), findsOneWidget);
    expect(find.text('No active modules'), findsOneWidget);
    expect(find.text('0/1 modules active'), findsOneWidget);
    expect(find.text('0/5 hooks active'), findsOneWidget);
    expect(find.text('1 inactive module'), findsOneWidget);
    expect(
      find.textContaining('Freshness operations'),
      findsAtLeastNWidgets(5),
    );
    expect(find.text('0/5 active'), findsOneWidget);
    expect(find.text('Freshness control'), findsOneWidget);
    expect(find.text('Freshness Readiness'), findsOneWidget);
    expect(find.text('Prepare freshness data'), findsOneWidget);
    expect(find.text('Freshness selling gates'), findsOneWidget);
    expect(find.text('Freshness availability templates'), findsOneWidget);
    expect(find.text('Inactive'), findsAtLeastNWidgets(5));
    expect(
      find.textContaining('Pack capability inactive'),
      findsAtLeastNWidgets(3),
    );
    expect(find.textContaining('Pack setup target inactive'), findsOneWidget);
  });

  testWidgets('pack contribution panel surfaces duplicate hook diagnostics', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackContributionPanel(
            bundle: _duplicateHookBundle,
          ),
        ),
      ),
    );

    expect(find.text('Duplicate hook diagnostics'), findsOneWidget);
    expect(find.text('Registry review'), findsOneWidget);
    expect(find.text('Module registry health'), findsOneWidget);
    expect(find.text('2 warnings'), findsOneWidget);
    expect(find.text('2 registry issues'), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Errors (0)'), findsOneWidget);
    expect(find.text('Warnings (2)'), findsOneWidget);
    expect(find.text('2 duplicate hooks'), findsOneWidget);
    expect(
      find.text('Workspace action / freshness_queue'),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.text('Module brief action / shared_brief_action'),
      findsOneWidget,
    );
    expect(find.text('Freshness A, Freshness B'), findsNWidgets(2));
    expect(find.text('2 sources'), findsNWidgets(2));
    expect(
      find.textContaining(
        'Give "freshness_queue" a unique workspace action id',
      ),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining(
        'Give "shared_brief_action" a unique module brief action id',
      ),
      findsOneWidget,
    );
  });

  testWidgets('pack contribution panel surfaces ignored manifest diagnostics', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackContributionPanel(
            bundle: _ignoredManifestBundle,
          ),
        ),
      ),
    );

    expect(find.text('Ignored module manifests'), findsOneWidget);
    expect(find.text('Registry blocked'), findsOneWidget);
    expect(find.text('Module registry health'), findsOneWidget);
    expect(find.text('2 errors'), findsOneWidget);
    expect(find.text('2 registry issues'), findsOneWidget);
    expect(find.text('All (2)'), findsOneWidget);
    expect(find.text('Errors (2)'), findsOneWidget);
    expect(find.text('Warnings (0)'), findsOneWidget);
    expect(find.text('2 ignored manifests'), findsOneWidget);
    expect(
      find.text('Duplicate module id / freshness_operations'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Blank module id / Blank module'), findsOneWidget);
    expect(
      find.textContaining(
        'Duplicate freshness module was ignored because Freshness operations',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Blank module was ignored because its module id is blank.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Rename Duplicate freshness module or merge it with Freshness operations',
      ),
      findsAtLeastNWidgets(1),
    );
    expect(
      find.textContaining(
        'Set a stable non-empty manifest id before registering Blank module.',
      ),
      findsOneWidget,
    );
  });
}

final _bundle = ProductManagementPackContributionBundle(
  managementPack: groceryFreshGoodsProductManagementPack,
  workspaceActionGroups: const [
    ProductWorkspaceActionGroup(
      id: productWorkspaceCatalogActionGroupId,
      title: 'Catalog & review',
      subtitle: 'Maintain product data and resolve catalog health issues',
      shortcuts: [
        ProductWorkspaceShortcut(
          id: ProductWorkspaceShortcutId.catalog,
          title: 'Product Catalog',
          subtitle: 'Review products',
          status: 'Ready',
        ),
      ],
    ),
    ProductWorkspaceActionGroup(
      id: productWorkspaceFreshnessActionGroupId,
      title: 'Freshness control',
      subtitle: 'Track expiry and batch-sensitive workflows',
      shortcuts: [
        ProductWorkspaceShortcut(
          id: ProductWorkspaceShortcutId.freshnessQueue,
          title: 'Freshness Queue',
          subtitle: 'Review freshness',
          status: 'Pack setup',
          isEnabled: false,
        ),
      ],
    ),
  ],
  actionContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_queue',
      kind: ProductManagementPackContributionKind.workspaceAction,
      title: 'Freshness control',
      detailLabel: '1 action across 1 group',
      statusLabel: 'Active',
      isActive: true,
      outputCount: 1,
      outputLabels: ['Freshness control'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  setupReadinessContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_readiness',
      kind: ProductManagementPackContributionKind.setupReadiness,
      title: 'Freshness Readiness',
      detailLabel: '1 setup target monitored',
      statusLabel: 'Monitoring',
      isActive: true,
      outputCount: 1,
      outputLabels: ['Freshness'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  recommendationContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_data_setup',
      kind: ProductManagementPackContributionKind.recommendation,
      title: 'Prepare freshness data',
      detailLabel: '1 recommended step',
      statusLabel: 'Active',
      isActive: true,
      outputCount: 1,
      outputLabels: ['Prepare freshness data'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  moduleBriefContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_availability_brief_action',
      kind: ProductManagementPackContributionKind.moduleBriefAction,
      title: 'Freshness selling gates',
      detailLabel:
          'Routes availability next actions to freshness queue review.',
      statusLabel: 'Active',
      isActive: true,
      outputCount: 1,
      outputLabels: ['Availability Rules'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  availabilityTemplateContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_availability_templates',
      kind: ProductManagementPackContributionKind.availabilityTemplate,
      title: 'Freshness availability templates',
      detailLabel: '2 templates',
      statusLabel: 'Active',
      isActive: true,
      outputCount: 2,
      outputLabels: ['Fresh shelf', 'Freshness hold'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  moduleActivationSummaries: const [
    ProductModuleContributionActivationSummary(
      id: 'freshness_operations',
      title: 'Freshness operations',
      description:
          'Expiry, batch, and pull-from-shelf hooks for fresh goods packs.',
      isActive: true,
      reasonLabel: 'Freshness, expiry, or batch capability matched',
      actionContributionCount: 1,
      setupReadinessContributionCount: 1,
      recommendationContributionCount: 1,
      moduleBriefResolverCount: 1,
      availabilityTemplateContributionCount: 1,
    ),
  ],
);

final _coreBundle = ProductManagementPackContributionBundle(
  managementPack: coreProductManagementPack,
  workspaceActionGroups: const [],
  actionContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_queue',
      kind: ProductManagementPackContributionKind.workspaceAction,
      title: 'Freshness control',
      detailLabel: 'Pack capability inactive',
      statusLabel: 'Inactive',
      isActive: false,
      outputCount: 0,
      outputLabels: ['Freshness control'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  setupReadinessContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_readiness',
      kind: ProductManagementPackContributionKind.setupReadiness,
      title: 'Freshness Readiness',
      detailLabel: 'Pack setup target inactive',
      statusLabel: 'Inactive',
      isActive: false,
      outputCount: 0,
      outputLabels: ['Freshness'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  recommendationContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_data_setup',
      kind: ProductManagementPackContributionKind.recommendation,
      title: 'Prepare freshness data',
      detailLabel: 'Pack capability inactive',
      statusLabel: 'Inactive',
      isActive: false,
      outputCount: 0,
      outputLabels: ['Prepare freshness data'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  moduleBriefContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_availability_brief_action',
      kind: ProductManagementPackContributionKind.moduleBriefAction,
      title: 'Freshness selling gates',
      detailLabel: 'Pack inactive',
      statusLabel: 'Inactive',
      isActive: false,
      outputCount: 0,
      outputLabels: ['Availability Rules'],
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  availabilityTemplateContributions: [
    ProductManagementPackContributionSummary(
      id: 'freshness_availability_templates',
      kind: ProductManagementPackContributionKind.availabilityTemplate,
      title: 'Freshness availability templates',
      detailLabel: 'Pack capability inactive',
      statusLabel: 'Inactive',
      isActive: false,
      outputCount: 0,
      sourceId: 'freshness_operations',
      sourceTitle: 'Freshness operations',
    ),
  ],
  moduleActivationSummaries: const [
    ProductModuleContributionActivationSummary(
      id: 'freshness_operations',
      title: 'Freshness operations',
      description:
          'Expiry, batch, and pull-from-shelf hooks for fresh goods packs.',
      isActive: false,
      reasonLabel: 'Requires freshness, expiry, or batch product capabilities',
      actionContributionCount: 1,
      setupReadinessContributionCount: 1,
      recommendationContributionCount: 1,
      moduleBriefResolverCount: 1,
      availabilityTemplateContributionCount: 1,
    ),
  ],
);

final _duplicateHookBundle = ProductManagementPackContributionBundle(
  managementPack: groceryFreshGoodsProductManagementPack,
  workspaceActionGroups: const [],
  actionContributions: const [],
  recommendationContributions: const [],
  duplicateHookDiagnostics: [
    ProductModuleContributionDuplicateHookDiagnostic(
      kind: ProductModuleContributionHookKind.action,
      hookId: 'freshness_queue',
      sources: const [
        ProductModuleContributionSource(
          id: 'freshness_a',
          title: 'Freshness A',
          description: 'First freshness module.',
        ),
        ProductModuleContributionSource(
          id: 'freshness_b',
          title: 'Freshness B',
          description: 'Second freshness module.',
        ),
      ],
    ),
    ProductModuleContributionDuplicateHookDiagnostic(
      kind: ProductModuleContributionHookKind.moduleBriefAction,
      hookId: 'shared_brief_action',
      sources: const [
        ProductModuleContributionSource(
          id: 'freshness_a',
          title: 'Freshness A',
          description: 'First freshness module.',
        ),
        ProductModuleContributionSource(
          id: 'freshness_b',
          title: 'Freshness B',
          description: 'Second freshness module.',
        ),
      ],
    ),
  ],
);

final _ignoredManifestBundle = ProductManagementPackContributionBundle(
  managementPack: groceryFreshGoodsProductManagementPack,
  workspaceActionGroups: const [],
  actionContributions: const [],
  recommendationContributions: const [],
  ignoredManifestDiagnostics: const [
    ProductModuleContributionIgnoredManifestDiagnostic(
      reason: ProductModuleContributionIgnoredManifestReason.duplicateId,
      source: ProductModuleContributionSource(
        id: 'freshness_operations',
        title: 'Duplicate freshness module',
        description: 'Duplicate module id.',
      ),
      existingSource: ProductModuleContributionSource(
        id: 'freshness_operations',
        title: 'Freshness operations',
        description: 'Original module.',
      ),
    ),
    ProductModuleContributionIgnoredManifestDiagnostic(
      reason: ProductModuleContributionIgnoredManifestReason.blankId,
      source: ProductModuleContributionSource(
        id: '',
        title: 'Blank module',
        description: 'Missing module id.',
      ),
    ),
  ],
);
