import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_plan.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/widgets/workspace_setup_plan_strip.dart';

void main() {
  testWidgets('setup plan strip renders grouped setup areas', (tester) async {
    ProductWorkspaceSetupPlanSection? selectedSection;
    final plan = ProductWorkspaceSetupPlan.fromPrompts([
      _inactivePrompt,
      _customPrompt,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductWorkspaceSetupPlanStrip(
            plan: plan,
            onSectionSelected: (section) => selectedSection = section,
          ),
        ),
      ),
    );

    expect(find.text('5 requirements across 2 targets'), findsOneWidget);
    expect(find.text('3 areas'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('Data setup'), findsOneWidget);
    expect(find.text('Workflow setup'), findsOneWidget);
    expect(find.text('Integration setup'), findsOneWidget);
    expect(find.text('2 requirements'), findsAtLeastNWidgets(1));
    expect(find.text('1 requirement'), findsOneWidget);
    expect(find.text('Switch to Grocery Fresh Goods'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Data setup'));

    expect(selectedSection?.type, ProductWorkspaceSetupRequirementType.data);
    expect(selectedSection?.primaryPrompt?.targetId, 'freshness');
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

final _customPrompt = ProductWorkspaceSetupPrompt(
  target: ProductWorkspaceSetupTarget.custom('kiosk_bundle'),
  availability: ProductWorkspaceSetupTargetAvailability.custom,
  action: const ProductWorkspaceSetupAction(
    targetId: 'kiosk_bundle',
    label: 'Open setup',
    routePath: ProductRoutes.catalogPath,
    source: ProductWorkspaceSetupActionSource.fallback,
  ),
);
