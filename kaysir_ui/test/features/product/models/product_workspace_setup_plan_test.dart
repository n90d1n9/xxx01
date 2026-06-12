import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_plan.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('setup plan groups requirements by type', () {
    final plan = ProductWorkspaceSetupPlan.fromPrompts([
      _activePrompt,
      _inactivePrompt,
      _customPrompt,
    ]);

    expect(plan.isNotEmpty, isTrue);
    expect(plan.requirementCount, 5);
    expect(plan.targetCount, 2);
    expect(plan.estimatedMinutes, 30);
    expect(plan.requirementCountLabel, '5 requirements');
    expect(plan.targetCountLabel, '2 targets');
    expect(plan.sectionCountLabel, '3 areas');
    expect(plan.estimatedEffortLabel, '30 min');
    expect(plan.summaryLabel, '5 requirements across 2 targets');
    expect(plan.primarySection?.title, 'Data setup');
    expect(plan.sections.map((section) => section.title), [
      'Data setup',
      'Workflow setup',
      'Integration setup',
    ]);
    expect(plan.sections.first.requirementCountLabel, '2 requirements');
    expect(plan.sections.first.targetCountLabel, '1 target');
    expect(plan.sections.first.targetGroups.length, 1);
    expect(
      plan.sections.first.targetGroups.single.targetTitle,
      'Freshness control setup',
    );
    expect(
      plan.sections.first.targetGroups.single.requirementCountLabel,
      '2 requirements',
    );
    expect(plan.sections.first.primaryPrompt?.targetId, 'freshness');
    expect(
      plan.sections.first.primaryActionLabel,
      'Switch to Grocery Fresh Goods',
    );
    expect(
      plan.sections.first.primaryRequirement?.actionLabel,
      'Switch to Grocery Fresh Goods',
    );
  });

  test('empty setup plan exposes stable labels', () {
    final plan = ProductWorkspaceSetupPlan.empty;

    expect(plan.isEmpty, isTrue);
    expect(plan.requirementCount, 0);
    expect(plan.targetCount, 0);
    expect(plan.estimatedEffortLabel, 'Quick setup');
    expect(plan.summaryLabel, 'No setup requirements');
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
