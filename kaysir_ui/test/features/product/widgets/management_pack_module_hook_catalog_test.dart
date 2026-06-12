import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_bundle.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_source_group.dart';
import 'package:kaysir/features/product/models/product_module_contribution_activation_summary.dart';
import 'package:kaysir/features/product/widgets/management_pack_module_hook_catalog.dart';

void main() {
  testWidgets('module hook catalog filters module groups', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: _groups),
        ),
      ),
    );

    expect(find.text('Active module'), findsOneWidget);
    expect(find.text('Inactive module'), findsOneWidget);
    expect(find.text('Diagnostic module'), findsOneWidget);
    expect(find.text('Active filters'), findsNothing);
    expect(
      find.textContaining('Showing all 3 modules | Unfiltered'),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Inactive'));
    await tester.pump();

    expect(find.text('Active module'), findsNothing);
    expect(find.text('Inactive module'), findsOneWidget);
    expect(find.text('Diagnostic module'), findsNothing);
    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Status Inactive'), findsOneWidget);
    expect(
      find.textContaining('Showing 1 of 3 modules | Inactive'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Clear module status filter'));
    await tester.pump();

    expect(find.text('Active module'), findsOneWidget);
    expect(find.text('Inactive module'), findsOneWidget);
    expect(find.text('Diagnostic module'), findsOneWidget);
    expect(find.text('Active filters'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'No hooks'));
    await tester.pump();

    expect(find.text('Active module'), findsNothing);
    expect(find.text('Inactive module'), findsNothing);
    expect(find.text('Diagnostic module'), findsOneWidget);
    expect(
      find.text('No hook outputs registered for this module'),
      findsOneWidget,
    );
  });

  testWidgets('module hook catalog searches module and hook text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: _groups),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'inactive action');
    await tester.pump();

    expect(find.text('Active module'), findsNothing);
    expect(find.text('Inactive module'), findsOneWidget);
    expect(find.text('Diagnostic module'), findsNothing);

    await tester.tap(find.byTooltip('Clear module search'));
    await tester.pump();

    expect(find.text('Active module'), findsOneWidget);
    expect(find.text('Inactive module'), findsOneWidget);
    expect(find.text('Diagnostic module'), findsOneWidget);
  });

  testWidgets('module hook catalog filters by hook type', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: _kindGroups),
        ),
      ),
    );

    expect(find.text('Workspace module'), findsOneWidget);
    expect(find.text('Readiness module'), findsOneWidget);
    expect(find.text('Recommendation module'), findsOneWidget);
    expect(find.text('Brief action module'), findsOneWidget);

    await tester.tap(find.textContaining('All hook types').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recommendations (1)').last);
    await tester.pumpAndSettle();

    expect(find.text('Workspace module'), findsNothing);
    expect(find.text('Readiness module'), findsNothing);
    expect(find.text('Recommendation module'), findsOneWidget);
    expect(find.text('Brief action module'), findsNothing);
    expect(
      find.textContaining('Showing 1 of 4 modules | Recommendations'),
      findsOneWidget,
    );
  });

  testWidgets('module hook catalog resets combined controls', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: _kindGroups),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'launch');
    await tester.pump();
    await tester.tap(find.textContaining('All hook types').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recommendations (1)').last);
    await tester.pumpAndSettle();

    expect(find.text('Recommendation module'), findsOneWidget);
    expect(find.text('Workspace module'), findsNothing);
    expect(find.byTooltip('Reset module filters'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset module filters'));
    await tester.pumpAndSettle();

    expect(find.text('Workspace module'), findsOneWidget);
    expect(find.text('Readiness module'), findsOneWidget);
    expect(find.text('Recommendation module'), findsOneWidget);
    expect(find.text('Brief action module'), findsOneWidget);
    expect(find.byTooltip('Reset module filters'), findsNothing);
    expect(find.textContaining('All hook types'), findsOneWidget);
  });

  testWidgets('module hook catalog clears individual active filter chips', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: _kindGroups),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'launch');
    await tester.pump();
    await tester.tap(find.textContaining('All hook types').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recommendations (1)').last);
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsOneWidget);
    expect(find.text('Hook type Recommendations'), findsOneWidget);
    expect(find.text('Search "launch"'), findsOneWidget);
    expect(find.text('Recommendation module'), findsOneWidget);
    expect(find.text('Workspace module'), findsNothing);
    expect(find.text('Brief action module'), findsNothing);

    await tester.tap(find.byTooltip('Clear module hook type filter'));
    await tester.pumpAndSettle();

    expect(find.text('Hook type Recommendations'), findsNothing);
    expect(find.text('Search "launch"'), findsOneWidget);
    expect(find.text('Recommendation module'), findsOneWidget);
    expect(find.text('Workspace module'), findsNothing);
    expect(find.text('Brief action module'), findsNothing);

    await tester.tap(find.byTooltip('Clear module search filter'));
    await tester.pumpAndSettle();

    expect(find.text('Active filters'), findsNothing);
    expect(find.text('Workspace module'), findsOneWidget);
    expect(find.text('Readiness module'), findsOneWidget);
    expect(find.text('Recommendation module'), findsOneWidget);
    expect(find.text('Brief action module'), findsOneWidget);
  });

  testWidgets('module hook catalog sorts modules and clears sort chip', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: _groups),
        ),
      ),
    );

    expect(
      _topOf(tester, 'Inactive module') < _topOf(tester, 'Diagnostic module'),
      isTrue,
    );

    await tester.tap(find.text('Registry order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A-Z').last);
    await tester.pumpAndSettle();

    expect(find.text('Sort A-Z'), findsOneWidget);
    expect(
      find.textContaining('Showing 3 of 3 modules | Sorted A-Z'),
      findsOneWidget,
    );
    expect(
      _topOf(tester, 'Diagnostic module') < _topOf(tester, 'Inactive module'),
      isTrue,
    );

    await tester.tap(find.byTooltip('Clear module sort'));
    await tester.pumpAndSettle();

    expect(find.text('Sort A-Z'), findsNothing);
    expect(find.text('Active filters'), findsNothing);
    expect(
      _topOf(tester, 'Inactive module') < _topOf(tester, 'Diagnostic module'),
      isTrue,
    );
  });

  testWidgets('module hook catalog renders empty filtered state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: [_groups.first]),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Inactive'));
    await tester.pump();

    expect(find.text('No modules match this filter'), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, 'Reset module filters'),
      findsOneWidget,
    );
    expect(find.text('Active module'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Reset module filters'));
    await tester.pumpAndSettle();

    expect(find.text('No modules match this filter'), findsNothing);
    expect(find.text('Active module'), findsOneWidget);
  });

  testWidgets('module hook catalog renders empty search and filter state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackModuleHookCatalog(groups: _groups),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'registered');
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Inactive'));
    await tester.pump();

    expect(
      find.text('No modules match this search and filter'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextButton, 'Reset module filters'),
      findsOneWidget,
    );
    expect(find.text('Diagnostic module'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'Reset module filters'));
    await tester.pumpAndSettle();

    expect(find.text('No modules match this search and filter'), findsNothing);
    expect(find.text('Active module'), findsOneWidget);
    expect(find.text('Inactive module'), findsOneWidget);
    expect(find.text('Diagnostic module'), findsOneWidget);
  });
}

double _topOf(WidgetTester tester, String text) {
  return tester.getTopLeft(find.text(text)).dy;
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
];
