import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness_contribution.dart';

void main() {
  test(
    'readiness contribution bundle keeps first valid contribution by id',
    () {
      final bundle = ProductWorkspaceSetupReadinessContributionBundle(
        contributions: [
          _contribution(' alpha '),
          _contribution(''),
          _contribution('alpha'),
          _contribution(' beta '),
        ],
      );

      expect(bundle.isNotEmpty, isTrue);
      expect(bundle.contributionCount, 2);
      expect(bundle.ignoredContributionCount, 2);
      expect(bundle.contributionIds, ['alpha', 'beta']);
      expect(bundle.contributionCountLabel, '2 contributions');
      expect(bundle.ignoredContributionCountLabel, '2 ignored contributions');
    },
  );

  test('readiness contribution normalizes target scopes', () {
    final contribution = _contribution(
      ' coffee_readiness ',
      targetIds: [' coffee_menu ', '', 'coffee_menu', 'barista_station'],
    );
    final globalContribution = _contribution('global', targetIds: [' ']);

    expect(contribution.normalizedId, 'coffee_readiness');
    expect(contribution.normalizedTargetIds, [
      'coffee_menu',
      'barista_station',
    ]);
    expect(contribution.hasTargetScope, isTrue);
    expect(contribution.coversAnyTarget({' coffee_menu '}), isTrue);
    expect(contribution.coversAnyTarget({'kiosk_bundle'}), isFalse);
    expect(
      () => contribution.normalizedTargetIds.add('another_target'),
      throwsUnsupportedError,
    );
    expect(globalContribution.hasTargetScope, isFalse);
    expect(globalContribution.coversAnyTarget(const {}), isTrue);
  });

  test('readiness contribution bundle composes registries', () {
    final bundle = ProductWorkspaceSetupReadinessContributionBundle(
      contributions: [
        ProductWorkspaceSetupReadinessContribution(
          id: 'alpha',
          buildRegistry:
              (context) => ProductWorkspaceSetupReadinessEvaluatorRegistry(
                requirementEvaluators: {
                  'alpha_requirement':
                      (context) =>
                          ProductWorkspaceSetupRequirementEvaluation.fromContext(
                            context: context,
                            status:
                                ProductWorkspaceSetupRequirementStatus.ready,
                            reason: 'Alpha ready',
                          ),
                },
              ),
        ),
        ProductWorkspaceSetupReadinessContribution(
          id: 'beta',
          buildRegistry:
              (context) => ProductWorkspaceSetupReadinessEvaluatorRegistry(
                requirementEvaluators: {
                  'beta_requirement':
                      (context) =>
                          ProductWorkspaceSetupRequirementEvaluation.fromContext(
                            context: context,
                            status:
                                ProductWorkspaceSetupRequirementStatus.ready,
                            reason: 'Beta ready',
                          ),
                },
              ),
        ),
      ],
    );

    final registry = bundle.registryFor(
      ProductWorkspaceSetupReadinessContributionContext(records: const []),
    );

    expect(registry.requirementEvaluators.keys, {
      'alpha_requirement',
      'beta_requirement',
    });
  });
}

ProductWorkspaceSetupReadinessContribution _contribution(
  String id, {
  List<String> targetIds = const [],
}) {
  return ProductWorkspaceSetupReadinessContribution(
    id: id,
    targetIds: targetIds,
    buildRegistry:
        (context) => const ProductWorkspaceSetupReadinessEvaluatorRegistry(),
  );
}
