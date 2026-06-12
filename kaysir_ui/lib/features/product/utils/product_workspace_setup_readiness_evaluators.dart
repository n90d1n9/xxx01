import '../../inventory/models/inventory_product_catalog.dart';
import '../models/management_pack.dart';
import '../models/product_workspace_setup_readiness_contribution.dart';
import '../models/product_workspace_setup_readiness.dart';
import '../models/product_workspace_setup_target.dart';

const productWorkspaceFreshnessReadinessContributionId = 'freshness_readiness';

const freshnessProductWorkspaceSetupReadinessContribution =
    ProductWorkspaceSetupReadinessContribution(
      id: productWorkspaceFreshnessReadinessContributionId,
      targetIds: [productWorkspaceFreshnessSetupTargetId],
      buildRegistry:
          _buildFreshnessProductWorkspaceSetupReadinessEvaluatorRegistry,
    );

const defaultProductWorkspaceSetupReadinessContributions = [
  freshnessProductWorkspaceSetupReadinessContribution,
];

ProductWorkspaceSetupReadinessEvaluatorRegistry
_buildFreshnessProductWorkspaceSetupReadinessEvaluatorRegistry(
  ProductWorkspaceSetupReadinessContributionContext context,
) {
  return buildProductWorkspaceFreshnessReadinessEvaluatorRegistry(
    records: context.records,
  );
}

ProductWorkspaceSetupReadinessEvaluatorRegistry
buildProductWorkspaceSetupReadinessEvaluatorRegistry({
  required List<InventoryProductCatalogRecord> records,
  List<ProductWorkspaceSetupReadinessContribution>? contributions,
}) {
  final context = ProductWorkspaceSetupReadinessContributionContext(
    records: records,
  );
  final bundle = ProductWorkspaceSetupReadinessContributionBundle(
    contributions:
        contributions ?? defaultProductWorkspaceSetupReadinessContributions,
  );

  return bundle.registryFor(context);
}

ProductWorkspaceSetupReadinessEvaluatorRegistry
buildProductWorkspaceFreshnessReadinessEvaluatorRegistry({
  required List<InventoryProductCatalogRecord> records,
}) {
  final freshness = ProductWorkspaceFreshnessReadinessSnapshot.fromRecords(
    records,
  );

  return ProductWorkspaceSetupReadinessEvaluatorRegistry(
    targetRequirementEvaluators: {
      ProductWorkspaceSetupReadinessEvaluatorRegistry.targetRequirementKey(
            productWorkspaceFreshnessSetupTargetId,
            'expiry_date_data',
          ):
          freshness.evaluateExpiryDateData,
      ProductWorkspaceSetupReadinessEvaluatorRegistry.targetRequirementKey(
            productWorkspaceFreshnessSetupTargetId,
            'batch_traceability',
          ):
          freshness.evaluateBatchTraceability,
      ProductWorkspaceSetupReadinessEvaluatorRegistry.targetRequirementKey(
            productWorkspaceFreshnessSetupTargetId,
            'pull_from_shelf_workflow',
          ):
          freshness.evaluatePullFromShelfWorkflow,
    },
  );
}

class ProductWorkspaceFreshnessReadinessSnapshot {
  const ProductWorkspaceFreshnessReadinessSnapshot({
    required this.productCount,
    required this.expiryDateProductCount,
    required this.batchNumberProductCount,
    required this.workflowSignalProductCount,
  });

  factory ProductWorkspaceFreshnessReadinessSnapshot.fromRecords(
    List<InventoryProductCatalogRecord> records,
  ) {
    var expiryDateProductCount = 0;
    var batchNumberProductCount = 0;
    var workflowSignalProductCount = 0;

    for (final record in records) {
      if (_hasAttribute(record, ProductManagementFieldId.expiryDate)) {
        expiryDateProductCount += 1;
      }
      if (_hasAttribute(record, ProductManagementFieldId.batchNumber)) {
        batchNumberProductCount += 1;
      }
      if (_hasAttribute(record, ProductManagementFieldId.freshnessStatus) ||
          _hasAttribute(record, ProductManagementFieldId.shelfLifeDays)) {
        workflowSignalProductCount += 1;
      }
    }

    return ProductWorkspaceFreshnessReadinessSnapshot(
      productCount: records.length,
      expiryDateProductCount: expiryDateProductCount,
      batchNumberProductCount: batchNumberProductCount,
      workflowSignalProductCount: workflowSignalProductCount,
    );
  }

  final int productCount;
  final int expiryDateProductCount;
  final int batchNumberProductCount;
  final int workflowSignalProductCount;

  ProductWorkspaceSetupRequirementEvaluation evaluateExpiryDateData(
    ProductWorkspaceSetupRequirementEvaluationContext context,
  ) {
    return _evaluateActiveFreshnessRequirement(
      context: context,
      ready: expiryDateProductCount > 0,
      readyReason: _countReason(
        expiryDateProductCount,
        'product has expiry date data',
        'products have expiry date data',
      ),
      missingReason: _missingReason(
        emptyCatalog: 'Add products before evaluating expiry date data',
        setupGap: 'Add expiry dates to freshness-sensitive products',
      ),
    );
  }

  ProductWorkspaceSetupRequirementEvaluation evaluateBatchTraceability(
    ProductWorkspaceSetupRequirementEvaluationContext context,
  ) {
    return _evaluateActiveFreshnessRequirement(
      context: context,
      ready: batchNumberProductCount > 0,
      readyReason: _countReason(
        batchNumberProductCount,
        'product has batch traceability',
        'products have batch traceability',
      ),
      missingReason: _missingReason(
        emptyCatalog: 'Add products before evaluating batch traceability',
        setupGap: 'Add batch numbers to traceable products',
      ),
    );
  }

  ProductWorkspaceSetupRequirementEvaluation evaluatePullFromShelfWorkflow(
    ProductWorkspaceSetupRequirementEvaluationContext context,
  ) {
    return _evaluateActiveFreshnessRequirement(
      context: context,
      ready: workflowSignalProductCount > 0,
      readyReason: _countReason(
        workflowSignalProductCount,
        'product has freshness workflow signals',
        'products have freshness workflow signals',
      ),
      missingReason: _missingReason(
        emptyCatalog: 'Add products before evaluating freshness workflow',
        setupGap: 'Add shelf life or freshness status for pull-from-shelf work',
      ),
    );
  }

  ProductWorkspaceSetupRequirementEvaluation
  _evaluateActiveFreshnessRequirement({
    required ProductWorkspaceSetupRequirementEvaluationContext context,
    required bool ready,
    required String readyReason,
    required String missingReason,
  }) {
    if (!context.requirement.required ||
        context.prompt.isInactive ||
        context.prompt.isCustom) {
      return defaultProductWorkspaceSetupRequirementEvaluator(context);
    }

    return ProductWorkspaceSetupRequirementEvaluation.fromContext(
      context: context,
      status:
          ready
              ? ProductWorkspaceSetupRequirementStatus.ready
              : ProductWorkspaceSetupRequirementStatus.missing,
      reason: ready ? readyReason : missingReason,
    );
  }

  String _missingReason({
    required String emptyCatalog,
    required String setupGap,
  }) {
    return productCount == 0 ? emptyCatalog : setupGap;
  }
}

String _countReason(int count, String singular, String plural) {
  if (count == 1) return '1 $singular';

  return '$count $plural';
}

bool _hasAttribute(
  InventoryProductCatalogRecord record,
  ProductManagementFieldId fieldId,
) {
  final value = record.product.customAttributes[fieldId.value];

  return value != null && value.trim().isNotEmpty;
}
