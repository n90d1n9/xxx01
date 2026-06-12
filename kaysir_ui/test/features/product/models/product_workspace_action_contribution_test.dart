import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_action_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_action_group.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness_contribution.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/models/product_workspace_shortcut.dart';

void main() {
  test('workspace action contribution filters inactive outputs', () {
    final contribution = ProductWorkspaceActionContribution(
      id: 'coffee_bar',
      isActive: (pack) => false,
      setupTargets: const [_coffeeSetupTarget],
      setupReadinessContributions: [_coffeeReadinessContribution],
      buildGroups:
          (pack, summary) => const [
            ProductWorkspaceActionGroup(
              id: 'coffee_bar',
              title: 'Coffee bar',
              subtitle: 'Barista product setup',
              shortcuts: [
                ProductWorkspaceShortcut(
                  id: ProductWorkspaceShortcutId.catalog,
                  title: 'Menu catalog',
                  subtitle: 'Review drinks and modifiers',
                  status: 'Ready',
                ),
              ],
            ),
          ],
    );

    expect(contribution.normalizedId, 'coffee_bar');
    expect(contribution.isActiveFor(coreProductManagementPack), isFalse);
    expect(
      contribution.groupsFor(coreProductManagementPack, _summary),
      isEmpty,
    );
    expect(contribution.setupTargetsFor(coreProductManagementPack), isEmpty);
    expect(
      contribution.setupReadinessContributionsFor(coreProductManagementPack),
      isEmpty,
    );
  });

  test(
    'workspace action contribution keeps valid extension outputs immutable',
    () {
      const validGroup = ProductWorkspaceActionGroup(
        id: 'coffee_bar',
        title: 'Coffee bar',
        subtitle: 'Barista product setup',
        shortcuts: [
          ProductWorkspaceShortcut(
            id: ProductWorkspaceShortcutId.catalog,
            title: 'Menu catalog',
            subtitle: 'Review drinks and modifiers',
            status: 'Ready',
          ),
        ],
      );
      const emptyGroup = ProductWorkspaceActionGroup(
        id: 'empty',
        title: 'Empty',
        subtitle: 'Should not render',
        shortcuts: [],
      );
      const blankTarget = ProductWorkspaceSetupTarget(
        id: ' ',
        title: 'Blank setup',
        subtitle: 'Invalid target',
        actionLabel: 'Review blank',
      );
      final blankReadinessContribution =
          ProductWorkspaceSetupReadinessContribution(
            id: ' ',
            buildRegistry:
                (context) =>
                    const ProductWorkspaceSetupReadinessEvaluatorRegistry(),
          );
      final contribution = ProductWorkspaceActionContribution(
        id: ' coffee_bar ',
        isActive: (pack) => true,
        setupTargets: const [blankTarget, _coffeeSetupTarget],
        setupReadinessContributions: [
          blankReadinessContribution,
          _coffeeReadinessContribution,
        ],
        buildGroups: (pack, summary) => const [emptyGroup, validGroup],
      );

      final groups = contribution.groupsFor(
        coreProductManagementPack,
        _summary,
      );
      final setupTargets = contribution.setupTargetsFor(
        coreProductManagementPack,
      );
      final readinessContributions = contribution
          .setupReadinessContributionsFor(coreProductManagementPack);

      expect(contribution.normalizedId, 'coffee_bar');
      expect(contribution.hasSetupTargets, isTrue);
      expect(contribution.hasSetupReadinessContributions, isTrue);
      expect(contribution.isActiveFor(coreProductManagementPack), isTrue);
      expect(groups, [validGroup]);
      expect(setupTargets, [_coffeeSetupTarget]);
      expect(readinessContributions, [_coffeeReadinessContribution]);
      expect(() => groups.add(validGroup), throwsUnsupportedError);
      expect(() => setupTargets.clear(), throwsUnsupportedError);
      expect(() => readinessContributions.clear(), throwsUnsupportedError);
    },
  );
}

const _summary = InventoryProductCatalogSummary(
  productCount: 12,
  trackedProductCount: 9,
  inStockProductCount: 7,
  untrackedProductCount: 3,
  attentionProductCount: 5,
  totalQuantity: 80,
  totalInventoryValue: 1200,
  categoryCount: 4,
);

const _coffeeSetupTarget = ProductWorkspaceSetupTarget(
  id: 'coffee_bar_menu',
  title: 'Coffee bar menu setup',
  subtitle: 'Prepare menu items, modifiers, and barista stations.',
  actionLabel: 'Review menu setup',
);

final _coffeeReadinessContribution = ProductWorkspaceSetupReadinessContribution(
  id: 'coffee_bar_readiness',
  buildRegistry:
      (context) => const ProductWorkspaceSetupReadinessEvaluatorRegistry(),
);
