import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('default evaluator blocks inactive setup requirements', () {
    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _inactiveFreshnessPrompt,
    ]);

    expect(readiness.totalCount, 3);
    expect(readiness.requiredCount, 3);
    expect(readiness.blockedCount, 3);
    expect(readiness.missingCount, 0);
    expect(readiness.readyCount, 0);
    expect(readiness.statusLabel, 'Blocked');
    expect(readiness.progressLabel, '0/3 ready');
    expect(readiness.actionableCountLabel, '3 actions');
    expect(readiness.readyPercent, 0);
    expect(
      readiness.evaluations.map((evaluation) => evaluation.reason).toSet(),
      {'Switch product pack to activate this setup target'},
    );
    expect(readiness.evaluationsForTarget('freshness'), hasLength(3));
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'expiry_date_data',
          )
          ?.statusLabel,
      'Blocked',
    );
    expect(
      readiness.evaluationsForType(ProductWorkspaceSetupRequirementType.data),
      hasLength(2),
    );
  });

  test('default evaluator marks active requirements as missing', () {
    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _activeFreshnessPrompt,
    ]);

    expect(readiness.totalCount, 3);
    expect(readiness.missingCount, 3);
    expect(readiness.blockedCount, 0);
    expect(readiness.statusLabel, 'Needs setup');
    expect(readiness.progressLabel, '0/3 ready');
    expect(
      readiness.primaryEvaluation?.reason,
      'Requirement needs a module evaluator',
    );
  });

  test('default evaluator keeps optional requirements out of actions', () {
    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _optionalPrompt,
    ]);

    expect(readiness.totalCount, 1);
    expect(readiness.requiredCount, 0);
    expect(readiness.optionalCount, 1);
    expect(readiness.actionableCount, 0);
    expect(readiness.statusLabel, 'Ready');
    expect(readiness.progressLabel, '1 optional');
    expect(readiness.readyPercent, 1);
  });

  test('default evaluator blocks custom setup requirements', () {
    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _customPrompt,
    ]);

    expect(readiness.totalCount, 2);
    expect(readiness.blockedCount, 2);
    expect(readiness.statusLabel, 'Blocked');
    expect(readiness.progressLabel, '0/2 ready');
    expect(
      readiness.evaluations.map((evaluation) => evaluation.reason).toSet(),
      {'Custom setup target needs module wiring'},
    );
  });

  test('registry allows modules to mark target requirements ready', () {
    final registry = ProductWorkspaceSetupReadinessEvaluatorRegistry(
      targetRequirementEvaluators: {
        ProductWorkspaceSetupReadinessEvaluatorRegistry.targetRequirementKey(
              'freshness',
              'expiry_date_data',
            ):
            (context) => ProductWorkspaceSetupRequirementEvaluation.fromContext(
              context: context,
              status: ProductWorkspaceSetupRequirementStatus.ready,
              reason: 'Expiry feed connected',
            ),
      },
    );

    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _activeFreshnessPrompt,
    ], registry: registry);

    expect(readiness.totalCount, 3);
    expect(readiness.readyCount, 1);
    expect(readiness.missingCount, 2);
    expect(readiness.statusLabel, 'Needs setup');
    expect(readiness.progressLabel, '1/3 ready');
    expect(readiness.primaryEvaluation?.statusLabel, 'Missing');
    expect(
      readiness.evaluations
          .singleWhere(
            (evaluation) => evaluation.requirement.id == 'expiry_date_data',
          )
          .reason,
      'Expiry feed connected',
    );
  });

  test('combined registry keeps later module evaluators authoritative', () {
    final key =
        ProductWorkspaceSetupReadinessEvaluatorRegistry.targetRequirementKey(
          'freshness',
          'expiry_date_data',
        );
    final registry = ProductWorkspaceSetupReadinessEvaluatorRegistry.combine([
      ProductWorkspaceSetupReadinessEvaluatorRegistry(
        targetRequirementEvaluators: {
          key:
              (context) =>
                  ProductWorkspaceSetupRequirementEvaluation.fromContext(
                    context: context,
                    status: ProductWorkspaceSetupRequirementStatus.missing,
                    reason: 'Earlier module gap',
                  ),
        },
      ),
      ProductWorkspaceSetupReadinessEvaluatorRegistry(
        targetRequirementEvaluators: {
          key:
              (context) =>
                  ProductWorkspaceSetupRequirementEvaluation.fromContext(
                    context: context,
                    status: ProductWorkspaceSetupRequirementStatus.ready,
                    reason: 'Later module ready',
                  ),
        },
      ),
    ]);

    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _activeFreshnessPrompt,
    ], registry: registry);

    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'expiry_date_data',
          )
          ?.reason,
      'Later module ready',
    );
    expect(readiness.readyCount, 1);
    expect(readiness.missingCount, 2);
  });
}

const _activeFreshnessPrompt = ProductWorkspaceSetupPrompt(
  target: ProductWorkspaceSetupTarget.freshness,
  action: ProductWorkspaceSetupAction(
    targetId: 'freshness',
    label: 'Review freshness data',
    routePath: ProductRoutes.catalogPath,
    source: ProductWorkspaceSetupActionSource.fallback,
  ),
);

const _inactiveFreshnessPrompt = ProductWorkspaceSetupPrompt(
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

const _optionalTarget = ProductWorkspaceSetupTarget(
  id: 'optional_merchandising',
  title: 'Optional merchandising setup',
  subtitle: 'Prepare optional merchandising metadata.',
  actionLabel: 'Review merchandising setup',
  requirements: [
    ProductWorkspaceSetupRequirement(
      id: 'shelf_tags',
      label: 'Shelf tags',
      type: ProductWorkspaceSetupRequirementType.workflow,
      required: false,
    ),
  ],
);

const _optionalPrompt = ProductWorkspaceSetupPrompt(
  target: _optionalTarget,
  action: ProductWorkspaceSetupAction(
    targetId: 'optional_merchandising',
    label: 'Review merchandising setup',
    routePath: ProductRoutes.catalogPath,
    source: ProductWorkspaceSetupActionSource.fallback,
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
