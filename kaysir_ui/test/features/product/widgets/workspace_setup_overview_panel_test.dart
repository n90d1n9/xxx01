import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/widgets/workspace_setup_overview_panel.dart';
import 'package:kaysir/features/product/widgets/workspace_setup_plan_section_details.dart';

void main() {
  testWidgets('setup overview panel renders prompts and delegates actions', (
    tester,
  ) async {
    ProductWorkspaceSetupPrompt? selectedPrompt;
    final overview = ProductWorkspaceSetupOverview.fromPrompts([
      _activePrompt,
      _inactivePrompt,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductWorkspaceSetupOverviewPanel(
              overview: overview,
              onActionSelected: (prompt) => selectedPrompt = prompt,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Setup targets'), findsOneWidget);
    expect(find.text('Blocked'), findsAtLeastNWidgets(1));
    expect(find.text('0/3 ready'), findsOneWidget);
    expect(find.text('0/2 ready'), findsAtLeastNWidgets(1));
    expect(find.text('1/2 active'), findsOneWidget);
    expect(find.text('1 needs attention'), findsOneWidget);
    expect(find.text('1 high priority'), findsOneWidget);
    expect(find.text('3 requirements'), findsOneWidget);
    expect(find.text('3 requirements across 1 target'), findsOneWidget);
    expect(find.text('2 areas'), findsOneWidget);
    expect(find.text('2 targets'), findsOneWidget);
    expect(find.text('Data setup'), findsOneWidget);
    expect(find.text('Workflow setup'), findsOneWidget);
    expect(find.text('Data setup details'), findsOneWidget);
    expect(find.text('Freshness control setup'), findsAtLeastNWidgets(1));
    expect(find.text('Restaurant menu setup'), findsOneWidget);
    expect(find.text('Not in pack'), findsAtLeastNWidgets(1));
    expect(find.text('Active setup'), findsOneWidget);
    expect(find.text('Pack switch'), findsOneWidget);
    expect(find.text('Fallback path'), findsOneWidget);
    expect(find.text('High priority'), findsOneWidget);
    expect(find.text('Medium priority'), findsOneWidget);
    expect(find.text('18 min'), findsAtLeastNWidgets(1));
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('Expiry date data'), findsAtLeastNWidgets(1));
    expect(find.text('Batch traceability'), findsAtLeastNWidgets(1));
    expect(find.text('Pull-from-shelf workflow'), findsOneWidget);

    await tester.tap(find.text('Workflow setup'));
    await tester.pumpAndSettle();

    expect(selectedPrompt, isNull);
    expect(find.text('Workflow setup details'), findsOneWidget);

    final detailsAction = find.descendant(
      of: find.byType(ProductWorkspaceSetupPlanSectionDetails),
      matching: find.text('Switch to Grocery Fresh Goods'),
    );
    await tester.tap(detailsAction);

    expect(selectedPrompt?.targetId, 'freshness');
  });

  testWidgets('setup overview panel renders empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceSetupOverviewPanel(
            overview: ProductWorkspaceSetupOverview.empty,
            onActionSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('No setup targets'), findsOneWidget);
    expect(find.text('Setup targets'), findsOneWidget);
  });
}

const _restaurantMenuTarget = ProductWorkspaceSetupTarget(
  id: 'restaurant_menu',
  title: 'Restaurant menu setup',
  subtitle: 'Prepare dine-in menu metadata.',
  actionLabel: 'Review menu setup',
);

const _activePrompt = ProductWorkspaceSetupPrompt(
  target: _restaurantMenuTarget,
  action: ProductWorkspaceSetupAction(
    targetId: 'restaurant_menu',
    label: 'Review menu setup',
    routePath: ProductRoutes.catalogPath,
    source: ProductWorkspaceSetupActionSource.fallback,
  ),
);

const _inactivePrompt = ProductWorkspaceSetupPrompt(
  target: ProductWorkspaceSetupTarget.freshness,
  availability: ProductWorkspaceSetupTargetAvailability.inactive,
  action: ProductWorkspaceSetupAction(
    targetId: 'freshness',
    label: 'Switch to Grocery Fresh Goods',
    routePath: ProductRoutes.workspacePath,
    source: ProductWorkspaceSetupActionSource.inactiveTarget,
    activation: ProductWorkspaceSetupActivation(
      targetId: 'freshness',
      packId: ProductManagementPackId.groceryFreshGoods,
      packTitle: 'Grocery Fresh Goods',
    ),
  ),
);
