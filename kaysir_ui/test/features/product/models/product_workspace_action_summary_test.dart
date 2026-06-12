import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/product_workspace_action_summary.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut_intent.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('workspace action summary aggregates grouped readiness', () {
    final summary = ProductWorkspaceActionSummary.fromGroups(const [
      ProductWorkspaceActionGroup(
        id: 'catalog',
        title: 'Catalog',
        subtitle: 'Catalog work',
        shortcuts: [
          ProductWorkspaceShortcut(
            id: ProductWorkspaceShortcutId.catalog,
            title: 'Catalog',
            subtitle: 'Open catalog',
            status: 'Ready',
          ),
        ],
      ),
      ProductWorkspaceActionGroup(
        id: 'freshness',
        title: 'Freshness',
        subtitle: 'Freshness work',
        shortcuts: [
          ProductWorkspaceShortcut(
            id: ProductWorkspaceShortcutId.freshnessQueue,
            title: 'Freshness Queue',
            subtitle: 'Expiry work',
            status: 'Setup',
            isEnabled: false,
            disabledReason: 'Connect freshness route first',
          ),
        ],
      ),
      ProductWorkspaceActionGroup(
        id: 'empty',
        title: 'Empty',
        subtitle: 'No actions',
        shortcuts: [],
      ),
    ]);

    expect(summary.groupCount, 2);
    expect(summary.actionCount, 2);
    expect(summary.enabledActionCount, 1);
    expect(summary.gatedActionCount, 1);
    expect(summary.readyGroupCount, 1);
    expect(summary.partialGroupCount, 0);
    expect(summary.gatedGroupCount, 1);
    expect(
      summary.availability,
      ProductWorkspaceActionGroupAvailability.partial,
    );
    expect(summary.readinessLabel, 'Partial');
    expect(summary.readyActionLabel, '1/2 ready');
    expect(summary.groupCountLabel, '2 groups');
    expect(summary.setupActionLabel, '1 setup');
    expect(summary.readinessTooltip, '1 ready, 1 waiting for setup.');
    expect(summary.hasSetupFocus, isTrue);
    expect(
      summary.setupFocus?.actionId,
      ProductWorkspaceShortcutId.freshnessQueue,
    );
    expect(summary.setupFocus?.actionTitle, 'Freshness Queue');
    expect(summary.setupFocus?.groupTitle, 'Freshness');
    expect(summary.setupFocus?.hasRoutePath, isFalse);
    expect(summary.setupFocus?.label, 'Set up Freshness Queue');
    expect(
      summary.setupFocus?.tooltip,
      'Freshness: Freshness Queue - Connect freshness route first',
    );
  });

  test('workspace action summary prioritizes fully gated setup focus', () {
    final summary = ProductWorkspaceActionSummary.fromGroups(const [
      ProductWorkspaceActionGroup(
        id: 'catalog',
        title: 'Catalog',
        subtitle: 'Catalog work',
        shortcuts: [
          ProductWorkspaceShortcut(
            id: ProductWorkspaceShortcutId.catalog,
            title: 'Catalog',
            subtitle: 'Open catalog',
            status: 'Ready',
          ),
          ProductWorkspaceShortcut(
            id: ProductWorkspaceShortcutId.addProduct,
            title: 'Add Product',
            subtitle: 'Create product',
            status: 'Setup',
            isEnabled: false,
            disabledReason: 'Connect product form route',
          ),
        ],
      ),
      ProductWorkspaceActionGroup(
        id: 'freshness',
        title: 'Freshness',
        subtitle: 'Freshness work',
        shortcuts: [
          ProductWorkspaceShortcut(
            id: ProductWorkspaceShortcutId.freshnessQueue,
            title: 'Freshness Queue',
            subtitle: 'Expiry work',
            status: 'Setup',
            isEnabled: false,
            disabledReason: 'Connect freshness route first',
          ),
        ],
      ),
    ]);

    expect(summary.partialGroupCount, 1);
    expect(summary.gatedGroupCount, 1);
    expect(
      summary.setupFocus?.actionId,
      ProductWorkspaceShortcutId.freshnessQueue,
    );
    expect(summary.setupFocus?.actionTitle, 'Freshness Queue');
    expect(summary.setupFocus?.groupTitle, 'Freshness');
  });

  test('workspace action summary aggregates flat shortcuts', () {
    final summary = ProductWorkspaceActionSummary.fromShortcuts([
      const ProductWorkspaceShortcut(
        id: ProductWorkspaceShortcutId.catalog,
        title: 'Catalog',
        subtitle: 'Open catalog',
        status: 'Ready',
      ),
      ProductWorkspaceShortcut(
        id: ProductWorkspaceShortcutId.freshnessQueue,
        title: 'Freshness Queue',
        subtitle: 'Expiry work',
        status: 'Setup',
        setupIntent: ProductWorkspaceShortcutIntent.route(
          ProductRoutes.workspaceSetupUri(
            ProductWorkspaceSetupTarget.freshness,
          ),
        ),
        isEnabled: false,
        disabledReason: 'Connect freshness route first',
      ),
    ]);

    expect(summary.groupCount, 0);
    expect(summary.hasGroups, isFalse);
    expect(summary.actionCount, 2);
    expect(summary.enabledActionCount, 1);
    expect(summary.gatedActionCount, 1);
    expect(summary.hasGatedActions, isTrue);
    expect(
      summary.availability,
      ProductWorkspaceActionGroupAvailability.partial,
    );
    expect(summary.readyActionLabel, '1/2 ready');
    expect(
      summary.setupFocus?.actionId,
      ProductWorkspaceShortcutId.freshnessQueue,
    );
    expect(summary.setupFocus?.label, 'Set up Freshness Queue');
    expect(summary.setupFocus?.hasRoutePath, isTrue);
    expect(
      summary.setupFocus?.routePath,
      ProductRoutes.workspaceSetupUri(ProductWorkspaceSetupTarget.freshness),
    );
    expect(
      summary.setupFocus?.tooltip,
      'Freshness Queue - Connect freshness route first',
    );
  });

  test('workspace action summary keeps empty launchpads explicit', () {
    final summary = ProductWorkspaceActionSummary.fromShortcuts(const []);

    expect(summary.hasActions, isFalse);
    expect(summary.availability, ProductWorkspaceActionGroupAvailability.gated);
    expect(summary.readinessLabel, 'Setup needed');
    expect(summary.readyActionLabel, 'No actions');
    expect(summary.readinessTooltip, 'No workspace actions are enabled yet.');
    expect(summary.hasSetupFocus, isFalse);
  });
}
