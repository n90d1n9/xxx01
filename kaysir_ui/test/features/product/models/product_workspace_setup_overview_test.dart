import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('setup overview summarizes prompt availability', () {
    final overview = ProductWorkspaceSetupOverview.fromPrompts([
      _activePrompt,
      _inactivePrompt,
      _customPrompt,
    ]);

    expect(overview.targetCount, 3);
    expect(overview.activeCount, 1);
    expect(overview.inactiveCount, 1);
    expect(overview.customCount, 1);
    expect(overview.pendingCount, 2);
    expect(overview.requiredRequirementCount, 5);
    expect(overview.urgentTargetCount, 1);
    expect(overview.plan.requirementCount, 5);
    expect(overview.plan.sectionCountLabel, '3 areas');
    expect(overview.readiness.totalCount, 5);
    expect(overview.readiness.blockedCount, 5);
    expect(overview.readiness.statusLabel, 'Blocked');
    expect(overview.readiness.progressLabel, '0/5 ready');
    expect(overview.readinessLabel, '1/3 active');
    expect(overview.targetCountLabel, '3 targets');
    expect(overview.activeCountLabel, '1 active');
    expect(overview.inactiveCountLabel, '1 not in pack');
    expect(overview.customCountLabel, '1 custom');
    expect(overview.requiredRequirementCountLabel, '5 requirements');
    expect(overview.urgentTargetCountLabel, '1 high priority');
    expect(overview.pendingCountLabel, '2 need attention');
    expect(overview.prompts.map((prompt) => prompt.targetId), [
      'freshness',
      'kiosk_bundle',
      'restaurant_menu',
    ]);
  });

  test('empty setup overview exposes stable labels', () {
    final overview = ProductWorkspaceSetupOverview.empty;

    expect(overview.isEmpty, isTrue);
    expect(overview.readiness.totalCount, 0);
    expect(overview.readiness.statusLabel, 'No requirements');
    expect(overview.readiness.progressLabel, 'No requirements');
    expect(overview.readinessLabel, 'No targets');
    expect(overview.targetCountLabel, '0 targets');
    expect(overview.pendingCountLabel, '0 need attention');
    expect(overview.requiredRequirementCountLabel, '0 requirements');
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
