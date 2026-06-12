import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_action.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/utils/product_workspace_setup_readiness_evaluators.dart';

void main() {
  test('catalog evaluator marks complete freshness data ready', () {
    final registry = buildProductWorkspaceSetupReadinessEvaluatorRegistry(
      records: [
        _record(
          Product(
            id: 'p1',
            name: 'Milk',
            customAttributes: const {
              'expiry_date': '2026-08-01',
              'batch_number': 'B-01',
              'freshness_status': 'Monitor',
            },
          ),
        ),
      ],
    );

    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _activeFreshnessPrompt,
    ], registry: registry);

    expect(readiness.statusLabel, 'Ready');
    expect(readiness.progressLabel, '3/3 ready');
    expect(readiness.readyCount, 3);
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'expiry_date_data',
          )
          ?.reason,
      '1 product has expiry date data',
    );
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'batch_traceability',
          )
          ?.reason,
      '1 product has batch traceability',
    );
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'pull_from_shelf_workflow',
          )
          ?.reason,
      '1 product has freshness workflow signals',
    );
  });

  test('catalog evaluator reports active freshness data gaps', () {
    final registry = buildProductWorkspaceSetupReadinessEvaluatorRegistry(
      records: [_record(Product(id: 'p1', name: 'Milk'))],
    );

    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _activeFreshnessPrompt,
    ], registry: registry);

    expect(readiness.statusLabel, 'Needs setup');
    expect(readiness.progressLabel, '0/3 ready');
    expect(readiness.missingCount, 3);
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'expiry_date_data',
          )
          ?.reason,
      'Add expiry dates to freshness-sensitive products',
    );
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'batch_traceability',
          )
          ?.reason,
      'Add batch numbers to traceable products',
    );
    expect(
      readiness
          .evaluationForRequirement(
            targetId: 'freshness',
            requirementId: 'pull_from_shelf_workflow',
          )
          ?.reason,
      'Add shelf life or freshness status for pull-from-shelf work',
    );
  });

  test('catalog evaluator leaves inactive freshness target blocked', () {
    final registry = buildProductWorkspaceSetupReadinessEvaluatorRegistry(
      records: [
        _record(
          Product(
            id: 'p1',
            name: 'Milk',
            customAttributes: const {
              'expiry_date': '2026-08-01',
              'batch_number': 'B-01',
              'freshness_status': 'Monitor',
            },
          ),
        ),
      ],
    );

    final readiness = ProductWorkspaceSetupReadiness.fromPrompts([
      _inactiveFreshnessPrompt,
    ], registry: registry);

    expect(readiness.statusLabel, 'Blocked');
    expect(readiness.readyCount, 0);
    expect(readiness.blockedCount, 3);
  });
}

InventoryProductCatalogRecord _record(Product product) {
  return InventoryProductCatalogRecord(
    product: product,
    stockRecords: const [],
  );
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
    label: 'Review product pack',
    routePath: ProductRoutes.workspacePath,
    source: ProductWorkspaceSetupActionSource.inactiveTarget,
  ),
);
