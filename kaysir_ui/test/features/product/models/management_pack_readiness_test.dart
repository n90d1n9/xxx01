import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_contribution_bundle.dart';
import 'package:kaysir/features/product/models/management_pack_readiness.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_action_summary.dart';

void main() {
  test('pack readiness blocks empty launch foundations', () {
    final readiness = buildProductManagementPackReadiness(
      bundle: _bundle(),
      qualitySummary: _quality(productCount: 0, completeProductCount: 0),
      profileReadinessSummary: _profileReadiness(
        readyProductSlotCount: 0,
        totalProductSlotCount: 0,
      ),
      actionSummary: _actions(actionCount: 0, enabledActionCount: 0),
    );

    expect(readiness.scorePercent, 15);
    expect(readiness.level, ProductManagementPackReadinessLevel.blocked);
    expect(readiness.statusLabel, 'Blocked');
    expect(readiness.primarySection?.id, 'data_contract');
    expect(readiness.primaryActionLabel, 'Review data');
    expect(readiness.sections.map((section) => section.id), [
      productManagementPackReadinessDataSectionId,
      productManagementPackReadinessChannelSectionId,
      productManagementPackReadinessWorkflowSectionId,
      productManagementPackReadinessExtensionSectionId,
    ]);
  });

  test('pack readiness becomes ready when all foundations are complete', () {
    final readiness = buildProductManagementPackReadiness(
      bundle: _bundle(),
      qualitySummary: _quality(productCount: 4, completeProductCount: 4),
      profileReadinessSummary: _profileReadiness(
        readyProductSlotCount: 12,
        totalProductSlotCount: 12,
        readyChannelCount: 3,
      ),
      actionSummary: _actions(actionCount: 6, enabledActionCount: 6),
    );

    expect(readiness.scorePercent, 100);
    expect(readiness.level, ProductManagementPackReadinessLevel.ready);
    expect(readiness.statusLabel, 'Ready');
    expect(readiness.scoreLabel, '100% ready');
  });

  test(
    'pack readiness treats active extension hooks without output as setup',
    () {
      final readiness = buildProductManagementPackReadiness(
        bundle: _bundle(
          contributions: [
            ProductManagementPackContributionSummary(
              id: 'freshness_queue',
              kind: ProductManagementPackContributionKind.workspaceAction,
              title: 'Freshness control',
              detailLabel: 'Ready when matching actions appear',
              statusLabel: 'Listening',
              isActive: true,
              outputCount: 0,
            ),
          ],
        ),
        qualitySummary: _quality(productCount: 4, completeProductCount: 4),
        profileReadinessSummary: _profileReadiness(
          readyProductSlotCount: 12,
          totalProductSlotCount: 12,
          readyChannelCount: 3,
        ),
        actionSummary: _actions(actionCount: 6, enabledActionCount: 6),
      );
      final extension = readiness.sections.singleWhere(
        (section) =>
            section.id == productManagementPackReadinessExtensionSectionId,
      );

      expect(readiness.scorePercent, 85);
      expect(readiness.level, ProductManagementPackReadinessLevel.improving);
      expect(extension.scorePercent, 0);
      expect(extension.detailLabel, '0/1 active hooks producing output');
    },
  );
}

ProductManagementPackContributionBundle _bundle({
  List<ProductManagementPackContributionSummary> contributions = const [],
}) {
  return ProductManagementPackContributionBundle(
    managementPack: coreProductManagementPack,
    workspaceActionGroups: const [],
    actionContributions: contributions,
    recommendationContributions: const [],
  );
}

ProductCatalogQualitySummary _quality({
  required int productCount,
  required int completeProductCount,
}) {
  return ProductCatalogQualitySummary(
    productCount: productCount,
    completeProductCount: completeProductCount,
    issueProductCount: productCount - completeProductCount,
    totalIssueCount: productCount - completeProductCount,
    issues: const [],
  );
}

ProductSalesChannelProfileReadinessSummary _profileReadiness({
  required int readyProductSlotCount,
  required int totalProductSlotCount,
  int readyChannelCount = 0,
}) {
  return ProductSalesChannelProfileReadinessSummary(
    channelCount: totalProductSlotCount == 0 ? 0 : 3,
    readyChannelCount: readyChannelCount,
    improvingChannelCount: 0,
    blockedChannelCount: totalProductSlotCount == 0 ? 0 : 3 - readyChannelCount,
    readyProductSlotCount: readyProductSlotCount,
    totalProductSlotCount: totalProductSlotCount,
    blockedProductSlotCount: totalProductSlotCount - readyProductSlotCount,
    topPriority: null,
  );
}

ProductWorkspaceActionSummary _actions({
  required int actionCount,
  required int enabledActionCount,
}) {
  return ProductWorkspaceActionSummary(
    groupCount: actionCount == 0 ? 0 : 2,
    actionCount: actionCount,
    enabledActionCount: enabledActionCount,
    gatedActionCount: actionCount - enabledActionCount,
    readyGroupCount:
        enabledActionCount == actionCount && actionCount > 0 ? 2 : 0,
    partialGroupCount:
        enabledActionCount > 0 && enabledActionCount < actionCount ? 1 : 0,
    gatedGroupCount: enabledActionCount == 0 && actionCount > 0 ? 2 : 0,
  );
}
