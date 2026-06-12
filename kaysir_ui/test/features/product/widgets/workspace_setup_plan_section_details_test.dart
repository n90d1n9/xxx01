import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_plan.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/widgets/workspace_setup_plan_section_details.dart';

void main() {
  testWidgets('setup plan section details render requirements and action', (
    tester,
  ) async {
    var pressed = false;
    const prompts = [_inactivePrompt];
    final section =
        ProductWorkspaceSetupPlan.fromPrompts(prompts).primarySection!;
    final readiness = ProductWorkspaceSetupReadiness.fromPrompts(prompts);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceSetupPlanSectionDetails(
            section: section,
            readiness: readiness,
            onActionPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Data setup details'), findsOneWidget);
    expect(find.text('2 requirements across 1 target'), findsOneWidget);
    expect(find.text('Expiry date data'), findsOneWidget);
    expect(find.text('Batch traceability'), findsOneWidget);
    expect(find.text('Freshness control setup'), findsAtLeastNWidgets(1));
    expect(find.text('Not in pack'), findsOneWidget);
    expect(find.text('2 requirements'), findsOneWidget);
    expect(find.text('Blocked'), findsAtLeastNWidgets(1));
    expect(find.text('0/2 ready'), findsAtLeastNWidgets(1));
    expect(
      find.text('Switch product pack to activate this setup target'),
      findsAtLeastNWidgets(1),
    );

    await tester.tap(find.text('Switch to Grocery Fresh Goods'));

    expect(pressed, isTrue);
  });
}

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
